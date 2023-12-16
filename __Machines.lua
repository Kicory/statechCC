require("MachineProperties")
require("MultiblockMachines")
require("__ThreadingHelpers")
require("__Helpers")

--[[
MachineList scheme:
machineList = {
	[machineType] = {
		[machineName] = {						--> "MachineInfo"
			wrapped = [object],

			hasFluid = true/false,

			hasItem = true/false,

			getBasePower = function,
			isBusy = function,

			-------------------
			fluidInputs/Outputs = {},			--> Multiblock Machine only (or nil)
			itemInput/Output = [string],		--> Multiblock Machine only (or nil)
			-------------------
			singleBlockMachineName = [string]	--> Singleblock Machine only (or nil)
			-------------------
		},
		...
	},
	...
}
]]

--[[
Factory Schedule example:
{
	[machineName] = {					--> "Craft Schedule"
		unitInput = recipe.unitInput,		-- basic information
		unitOutput = recipe.unitOutput,		-- For tracking output catalogue
		rank = recipe.rank,					-- for sorting
		dispName = recipe.dispName,			-- for debug.

		itemInput = [hatchName:string],		-- Multiblock machine only
		fluidInputs = {						-- Multiblock machine only
			[hatchName:string],
			[hatchName:string],
			...
		}
	},
	...
}
]]

M = {}

local machineList = nil
local machineNames = nil
--------------------------------------------
local function checkStorageEmpty(hatchName)
	return (next(peripheral.call(hatchName, "items")) == nil)
end

local function checkTankEmpty(tankName)
	local tankIsEmpty = true
	for _, tank in pairs(peripheral.call(tankName, "tanks")) do
		tankIsEmpty = tankIsEmpty and (tank.name == Fluid.empty)
	end
	return tankIsEmpty
end

local function checkTanksEmpty(hatchNames)
	return TH.allAnd(TH.checkPredicate(checkTankEmpty, table.unpack(hatchNames)))
end

--- Returns true if the machine is empty.
---@param info any
---@return boolean the machine is completely empty.
local function isEmptyMachine(info)

	local predicates = {}
	if (info.singleBlockMachineName ~= nil) then
		-- Single block machine case
		local machineName = info.singleBlockMachineName
		if (info.hasItem) then
			predicates[#predicates + 1] = function() return checkStorageEmpty(machineName) end
		end
		if (info.hasFluid) then
			predicates[#predicates + 1] = function() return checkTankEmpty(machineName) end
		end
		return TH.allAnd(TH.checkAll(table.unpack(predicates)))
	end

	-- Multi-block machine case (can have multiple hatches)
	if (info.hasItem) then
		predicates[#predicates + 1] = function() return checkStorageEmpty(info.itemInput) end
		predicates[#predicates + 1] = function() return checkStorageEmpty(info.itemOutput) end
	end
	if (info.hasFluid) then
		predicates[#predicates + 1] = function() return checkTanksEmpty(info.fluidInputs) end
		predicates[#predicates + 1] = function() return checkTanksEmpty(info.fluidOutputs) end
	end

	return TH.allAnd(TH.checkAll(table.unpack(predicates)))
end
--------------------------------------------
local function itemFitsCount(storageName, itemID, amt)
	local curItems = peripheral.call(storageName, "items")
	for _, slot in pairs(curItems) do
		if itemID == slot.name then
			return math.floor((slot.maxCount - slot.count) / amt)
		end
	end
	return 0
end

local function fluidFitsTankCount(tankName, fluidID, amt)
	local tanks = peripheral.call(tankName, "tanks")
	for _, tank in pairs(tanks) do
		if fluidID == tank.name then
			return math.floor((tank.capacity - tank.amount) / amt)
		end
	end
	return 0
end

local function fluidFitCount(hatchNames, fluidID, amt)
	local fitCounts = {}
	for _, hatchName in ipairs(hatchNames) do
		fitCounts[#fitCounts + 1] = function() return fluidFitsTankCount(hatchName) end
	end
	return TH.allMin(TH.checkAll(table.unpack(fitCounts)))
end

--- Returns true if the machine can accept unit input of recipe.
---@param recipe table Recipe to check
---@param info table machineInfo
---@return boolean
local function unitInputFitCount(recipe, info)
	local unitInput = recipe.unitInput
	local fitCounts = {}

	if (info.singleBlockMachineName ~= nil) then
		-- Singleblock machine case
		local name = info.singleBlockMachineName
		for itemID, amt in pairs(unitInput.item or {}) do
			fitCounts[#fitCounts + 1] = function() return itemFitsCount(name, itemID, amt) end
		end
		for fluidID, amt in pairs(unitInput.fluid or {}) do
			fitCounts[#fitCounts + 1] = function() return fluidFitsTankCount(name, fluidID, amt) end
		end
	else
		-- Multiblock machine case
		for itemID, amt in pairs(unitInput.item or {}) do
			fitCounts[#fitCounts + 1] = function() return itemFitsCount(info.itemInput, itemID, amt) end
		end
		for fluidID, amt in pairs(unitInput.fluid or {}) do
			fitCounts[#fitCounts + 1] = function() return fluidFitCount(info.fluidInputs, fluidID, amt) end
		end
	end

	return TH.allMin(TH.checkAll(table.unpack(fitCounts)))
end
--------------------------------------------
local function getCraftingSpeed(info)
	local ci = info.wrapped.getCraftingInformation()
	local base = ci.baseRecipeCost
	local curr = ci.currentRecipeCost
	if base ~= nil and curr ~= nil then
		return curr / base
	else
		return 1
	end
end

local function getMachineReadiness(machineInfo, recipe)
	local empty, fitUnits, minPowOk, craftSp = table.unpack(TH.checkAll(
		function() return isEmptyMachine(machineInfo) end,
		function() return unitInputFitCount(recipe, machineInfo) end,
		function() return recipe.machineFilter(machineInfo) end,
		function() return getCraftingSpeed(machineInfo) end
	))
	return empty, fitUnits, minPowOk, craftSp
end

local function canCraftNow(machineInfo, recipe)
	local empty, fits, minPow = table.unpack(TH.checkAll(
		function() return isEmptyMachine(machineInfo) end,
		function() return unitInputFitCount(recipe, machineInfo) end,
		function() return recipe.machineFilter(machineInfo) end))
	return minPow and (empty or fits)
end

local function markMachine(machineName, info, req, readiness, states)
	local resultSchedule = states.resultSchedule
	local afterFeedCtlg = states.afterFeedCtlg
	local expectedOutputCtlg = states.expectedOutputCtlg

	local recipe = req.recipe
	local isEmpty, fitCount, minPowOk, craftingSpeed = table.unpack(readiness)
	
	-- No requirements (This happens when other machines already took all requirements...)
	if req.required == 0 then return end
	
	-- Calulate numbers to try input on machine.
	local countTry = 0
	
	req.expInput = req.expInput or 1
	if not minPowOk then return
	elseif isEmpty then countTry = 1
	elseif fitCount == 0 then return
	else countTry = math.min(fitCount, req.required, math.max(math.floor(req.expInput), math.ceil(craftingSpeed))) end
	
	-- Drop if machine is already occupied by higher rank.
	local previousRecipe = resultSchedule[machineName]
	if previousRecipe and recipe.rank > previousRecipe.rank then return end

	-- Calculate actual craftable unit count
	local actualScheduled = St.tryUse(afterFeedCtlg, recipe.unitInput, countTry)
	if actualScheduled == 0 then return end

	local inputScheduled = Helper.makeMultipliedIO(recipe.unitInput, actualScheduled)
	local outputScheduled = Helper.makeMultipliedIO(recipe.unitOutput, actualScheduled)

	-- Do schedule
	resultSchedule[machineName] = {
		unitInput = inputScheduled,			-- Basic information
		unitOutput = outputScheduled,		-- For tracking output catalogue
		rank = recipe.rank,					-- for preemption
		dispName = recipe.dispName,			-- for debug
		itemInput = info.itemInput,			-- Multiblock machine only
		fluidInputs = info.fluidInputs,		-- Multiblock machine only
	}

	-- Mark scheduled
	req.required = req.required - actualScheduled

	-- Add result to expectedOutputCtlg
	for id, amt in pairs(Helper.IO2Catalogue(outputScheduled)) do
		expectedOutputCtlg[id] = (expectedOutputCtlg[id] or 0) + amt
	end

	-- Increase exponential input criteria
	req.expInput = req.expInput * 1.5
end

local function makeCraftSchedule(req, states)
	local machineReadinessList = {}
	local readinessReporters = {}
	local function reportReadiness(machineName, info, recipe)
		local isEmpty, fitCount, minPowOk, craftingSpeed = getMachineReadiness(info, req.recipe)
		-- List of four values
		machineReadinessList[machineName] = {isEmpty, fitCount, minPowOk, craftingSpeed}
	end
	for _, machineType in ipairs(req.recipe.machineTypes) do
		for _, machineName in ipairs(machineNames[machineType]) do
			readinessReporters[#readinessReporters + 1] = function() reportReadiness(machineName, machineList[machineType][machineName], req.recipe) end
		end
	end
	-- Get all machine readinesses before actual scheduling.
	parallel.waitForAll(table.unpack(readinessReporters))


	-- From here, every scheduling is "sequential."
	local alreadyScheduledCtlg = states.expectedOutputCtlg

	-- Other recipe already fullfilled the requirements of production
	local recipeOutput = req.recipe.unitOutput
	local globalRequiredFullfilled = Helper.divideCtlg(alreadyScheduledCtlg, Helper.IO2Catalogue(recipeOutput))
	req.required = math.max(req.required - globalRequiredFullfilled, 0)

	for _, machineType in ipairs(req.recipe.machineTypes) do
		for _, machineName in ipairs(machineNames[machineType]) do
			markMachine(machineName, machineList[machineType][machineName], req, machineReadinessList[machineName], states)
		end
	end
end
--------------------------------------------
function M.refreshMachines()
	local machineTypes = {}
	for _, v in pairs(Machine) do
		machineTypes[#machineTypes + 1] = v
	end

	machineList = {}
	machineNames = {}

	local function registerMachine(machineType, machineName, machineWrapped)
		local machineInfo = {
			wrapped = machineWrapped,
		}

		machineInfo.hasFluid = peripheral.hasType(machineName, PpType.fluidStorage)
		machineInfo.hasItem = peripheral.hasType(machineName, PpType.itemStorage)

		if (peripheral.hasType(machineName, PpType.miCrafter)) then
			machineInfo.getBasePower = function() return machineWrapped.getCraftingInformation().maxRecipeCost end
			machineInfo.isBusy = machineWrapped.isBusy
		end
		-- Multi-block machines do not have this field
		machineInfo.singleBlockMachineName = machineName

		machineList[machineType][machineName] = machineInfo
		table.insert(machineNames[machineType], machineName)

		-- return for filter
		return false
	end

	-- Find peripherals
	for _, machineType in pairs(machineTypes) do
		machineList[machineType] = {}
		machineNames[machineType] = {}
		peripheral.find(machineType, function(machineName, machineWrapped) registerMachine(machineType, machineName, machineWrapped) end)
	end

	-- Add multiblock machines manually
	for machineType, bigMachines in pairs(BigMachines) do
		machineList[machineType] = {}
		machineNames[machineType] = {}
		for machineName, machineInfo in pairs(bigMachines) do
			machineInfo.wrapped = peripheral.wrap(machineName)
			machineInfo.getBasePower = function() return machineInfo.wrapped.getCraftingInformation().maxRecipeCost end
			machineInfo.isBusy = machineInfo.wrapped.isBusy
			machineList[machineType][machineName] = machineInfo
			table.insert(machineNames[machineType], machineName)
		end
	end
end

---@param recipesList table Recipes to check fit in
---@return table
function M.makeFactoryCraftSchedule(craftReqs, afterFeedCtlg)
	assert(afterFeedCtlg ~= nil)

	local resultSchedule = {}
	local expectedOutputCtlg = {}
	local states = {
		resultSchedule = resultSchedule,
		afterFeedCtlg = afterFeedCtlg,
		expectedOutputCtlg = expectedOutputCtlg,
	}
	local scheduleMakers = {}
	for _, req in ipairs(craftReqs) do
		scheduleMakers[#scheduleMakers + 1] = function() makeCraftSchedule(req, states) end
	end

	St.clearLackingMaterialsSet()
	parallel.waitForAll(table.unpack(scheduleMakers))

	return resultSchedule
end
--------------------------------------------
function M.getProperFluidHatches(craftSchedule)
	assert(craftSchedule.fluidInputs ~= nil, "This is only for multiblock machines")
	local hatches = craftSchedule.fluidInputs or {}
	local fluids = craftSchedule.unitInput.fluid or {}
	local funcs = {}
	local fitResult = {}

	local function makeFeedFluidInfo(fluidID, amt)
		return {
			fluidID = fluidID,
			amt = amt,
		}
	end

	funcs[#funcs + 1] = function()
		if checkTanksEmpty(hatches) then
			-- Wherever fluid goes.
			local hatchIdx = 1
			for fluidID, amt in pairs(fluids) do
				fitResult[hatches[hatchIdx]] = makeFeedFluidInfo(fluidID, amt)
				hatchIdx = hatchIdx + 1
			end
		end
	end

	for fluidID, amt in pairs(fluids) do
		for _, hatch in ipairs(hatches) do
			funcs[#funcs + 1] = function()
				if fluidFitsTankCount(hatch, fluidID, amt) then
					fitResult[hatch] = makeFeedFluidInfo(fluidID, amt)
				end
			end
		end
	end

	parallel.waitForAll(table.unpack(funcs))

	return fitResult
end
----------------------------------------------
--- Harvest from machines and save to buffer AE system.
function M.harvestToBuffer(bufferAE)
	local pullItem = bufferAE.pullItem
	local function pullEveryItem(storageName, machineType)
		TH.doMany(function() pullItem(storageName) end, Property.OutputItemSlotCount[machineType])
	end
	local pullFluid = bufferAE.pullFluid
	local function pullEveryFluid(tankName, machineType)
		TH.doMany(function() pullFluid(tankName) end, Property.OutputFluidSlotCount[machineType])
	end
	local bufferPullers = {}

	for machineType, machines in pairs(machineList) do
		for name, info in pairs(machines) do
			if info.singleBlockMachineName then
				if info.hasItem then
					bufferPullers[#bufferPullers + 1] = function() pullEveryItem(name, machineType) end
				end
				if info.hasFluid then
					bufferPullers[#bufferPullers + 1] = function() pullEveryFluid(name, machineType) end
				end
			else
				if info.hasItem then
					-- Output slots of "Highly Advanced Item Output Hatch" is 15.
					bufferPullers[#bufferPullers + 1] = function() TH.doMany(function() pullItem(info.itemOutput) end, 15) end
				end
				if info.hasFluid then
					-- Fluid hatchs always have one tank, so it's OK...
					bufferPullers[#bufferPullers + 1] = function() TH.checkPredicate(pullFluid, table.unpack(info.fluidOutputs)) end
				end
			end
		end
	end
	parallel.waitForAll(table.unpack(bufferPullers))
end

--- Send buffer contents to main AE system. 2 ticks function
---@param bufferAE table
---@param bufferStorages table List of item storages connected to bufferAE network
---@param bufferTanks table list of fluid storages connected to bufferAE network
---@param mainAE table Main AE network
---@return table Harvested materials catalogue
function M.harvestFromBuffer(bufferAE, bufferStorages, bufferTanks, mainAE)
	local harvestedCtlg = {}

	local harvestedItems
	local harvestedTanks
	harvestedItems, harvestedTanks = table.unpack(TH.checkAll(bufferAE.items, bufferAE.tanks))

	for _, item in ipairs(harvestedItems) do
		harvestedCtlg[item.technicalName] = item.count
	end
	for _, tank in ipairs(harvestedTanks) do
		harvestedCtlg[tank.name] = tank.amount
	end
	
	local pullItem = mainAE.pullItem
	local function pullEveryItem(storageName)
		-- Configurable Chest / normal single Chest slot number = 27
		TH.doMany(function() pullItem(storageName) end, 27)
	end
	local pullFluid = mainAE.pullFluid
	local function pullEveryFluid(tankName)
		-- Configurable Tank slot number: 9
		TH.doMany(function() pullFluid(tankName) end, 9)
	end
	local mainPullers = {}

	for _, storageName in ipairs(bufferStorages) do
		mainPullers[#mainPullers + 1] = function() pullEveryItem(storageName) end
	end
	
	for _, tankName in ipairs(bufferTanks) do
		mainPullers[#mainPullers + 1] = function() pullEveryFluid(tankName) end
	end

	parallel.waitForAll(table.unpack(mainPullers))
	return harvestedCtlg
end

--- Feed entire factory items and fluids for craft. Can take 1 tick or 2 ticks.
---@param scd table Schedule
---@param fromAE table Source of item/fluids
---@return table "fed" = Catalogue of all fed materials // "expected" = Catalogue of expected outputs
function M.feedFactory(scd, fromAE)
	local fedCtlg = {}
	local expectedOutputCtlg = {}

	local function feedItem(storageName, itemID, limit)
		local fedCount = fromAE.pushItem(storageName, itemID, limit)
		assert(fedCount == limit, storageName .. " -- " .. itemID .. " should fed: " .. limit .. ", actual: " .. fedCount)
		fedCtlg[itemID] = (fedCtlg[itemID] or 0) + fedCount
	end
	local function feedFluid(tankName, fluidID, limit)
		local fedAmt = fromAE.pushFluid(tankName, limit, fluidID)
		assert(fedAmt == limit)
		fedCtlg[fluidID] = (fedCtlg[fluidID] or 0) + fedAmt
	end

	local function feedMachine(name, craftScd)
		local itemTarget = craftScd.itemInput or name
		local singleFeedJobs = {}
		for itemID, count in pairs(craftScd.unitInput.item or {}) do
			singleFeedJobs[#singleFeedJobs + 1] = function() feedItem(itemTarget, itemID, count) end
		end
		
		if craftScd.fluidInputs == nil then
			-- Singleblock machine
			for fluidID, amt in pairs(craftScd.unitInput.fluid or {}) do
				singleFeedJobs[#singleFeedJobs + 1] = function() feedFluid(name, fluidID, amt) end
			end
		else
			-- Multiblock machine
			local hatchMatches = M.getProperFluidHatches(craftScd) --> 1 tick
			for hatch, fluidFeedInfo in pairs(hatchMatches) do
				singleFeedJobs[#singleFeedJobs + 1] = function() feedFluid(hatch, fluidFeedInfo.fluidID, fluidFeedInfo.amt) end
			end
		end
	
		for itemID, count in pairs(craftScd.unitOutput.item or {}) do
			expectedOutputCtlg[itemID] = (expectedOutputCtlg[itemID] or 0) + count
		end
		for fluidID, amt in pairs(craftScd.unitOutput.fluid or {}) do
			expectedOutputCtlg[fluidID] = (expectedOutputCtlg[fluidID] or 0) + amt
		end
		parallel.waitForAll(table.unpack(singleFeedJobs))
	end

	local feedJobs = {}
	for name, craftScd in pairs(scd) do
		feedJobs[#feedJobs + 1] = function() feedMachine(name, craftScd) end
	end

	parallel.waitForAll(table.unpack(feedJobs)) --> 1 tick
	return {
		fed = fedCtlg, 
		expected = expectedOutputCtlg
	}
end

--- func desc
---@param factoryScd table Schedule
---@param bufferAE table
---@param bufferStorages table List of item storages connected to bufferAE network
---@param bufferTanks table list of fluid storages connected to bufferAE network
---@param mainAE table Main AE network
---@return table Harvested materials catalogue
---@return table Catalogue of all fed materials
---@return table Catalogue of expected outputs
function M.moveMaterials(factoryScd, bufferAE, bufferStorages, bufferTanks, mainAE)
	local harvestedCtlg, feedResult
	harvestedCtlg, feedResult = table.unpack(TH.checkAll(
		function() return M.harvestFromBuffer(bufferAE, bufferStorages, bufferTanks, mainAE) end,
		function() return M.feedFactory(factoryScd, mainAE) end
	))
	local fedCtlg = feedResult.fed
	local expectedCtlg = feedResult.expected
	return harvestedCtlg, fedCtlg, expectedCtlg
end
----------------------------------------------
----------------------------------------------

function M.printMachineList()
	Helper.printPretty(machineList)
end

function M.printFactoryCraftSchedule(recipesList, ctlgCopy)
	local cur = os.clock()
	local ttt = Helper.serializeTable(M.makeFactoryCraftSchedule(recipesList, ctlgCopy))
	ttt = ttt .. "\n\n ... This took " .. os.clock() - cur .. " seconds."
	Helper.printPretty(ttt)
end