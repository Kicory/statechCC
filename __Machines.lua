local MachineProperty = require("MachineProperties")
local BigMachines = require("MultiblockMachines")
local TH = require("__ThreadingHelpers")
local Helper = require("__Helpers")
local Ctlg = require("__Catalouge")
local St = require("__Storage")
local Dict = require("Dict")

local Fluid = Dict.Fluid
local Item = Dict.Item
local Machine = Dict.Machine
local OutputHatchList = Dict.OutputHatchList
local PpType = Dict.PpType
local OddMaxCount = Dict.OddMaxCount


local M = {}

local machineList = nil
local machineNames = nil
local factoryStatus = nil
local paraCostLimit = 257
local maxTryWhenEmpty = 2
--------------------------------------------
local function refreshMachines()
	local singleBlockMachineTypes = {}
	for _, v in pairs(Machine) do
		singleBlockMachineTypes[#singleBlockMachineTypes + 1] = v
	end
	
	for _, v in ipairs(OutputHatchList) do
		singleBlockMachineTypes[#singleBlockMachineTypes + 1] = v
	end

	machineList = {}
	machineNames = {}
	factoryStatus = {}

	local function registerMachine(machineType, machineName, machineWrapped)
		local info = {
			wrapped = machineWrapped,
		}

		info.hasFluid = peripheral.hasType(machineName, PpType.fluidStorage)
		info.hasItem = peripheral.hasType(machineName, PpType.itemStorage)

		if (peripheral.hasType(machineName, PpType.miCrafter)) then
			info.getCraftingInfo = machineWrapped.getCraftingInformation
			info.isBusy = machineWrapped.isBusy
		end
		-- Multi-block machines do not have this field
		info.singleBlockMachineName = machineName

		machineList[machineType][machineName] = info
		table.insert(machineNames[machineType], machineName)

		-- return for filter
		return false
	end

	-- Find peripherals
	for _, machineType in pairs(singleBlockMachineTypes) do
		machineList[machineType] = {}
		machineNames[machineType] = {}
		peripheral.find(machineType, function(machineName, machineWrapped) registerMachine(machineType, machineName, machineWrapped) end)
	end

	-- Add multiblock machines manually
	for machineType, bigMachinesOfType in pairs(BigMachines) do
		machineList[machineType] = {}
		machineNames[machineType] = {}
		for machineName, info in pairs(bigMachinesOfType) do
			info.wrapped = peripheral.wrap(machineName)
			info.getCraftingInfo = info.wrapped.getCraftingInformation
			info.isBusy = info.wrapped.isBusy
			machineList[machineType][machineName] = info
			table.insert(machineNames[machineType], machineName)
		end
	end

	-- Create empty factoryStatus
	for t, ms in pairs(machineList) do
		for mn, info in pairs(ms) do
			factoryStatus[mn] = {
				type = t,
				storageInfo = nil,
				tankInfo = nil,
				craftingInfo = nil,
			}
		end
	end
end
--------------------------------------------

local function isEmptyStorage(storageInfo)
	if not storageInfo then 
		return true
	end
	return next(storageInfo) == nil
end

local function isEmptyTank(tankInfo)
	local ret = true
	if tankInfo then
		for _, ti in ipairs(tankInfo) do
			ret = ret and ti.name == Fluid.empty
		end
	end
	return ret
end

--- Returns true if the machine is empty.
---@param info any
---@return boolean the machine is completely empty.
local function isEmptyMachine(storageInfo, tankInfo)
	return isEmptyStorage(storageInfo) and isEmptyTank(tankInfo)
end
--------------------------------------------
local function itemFitsCount(storageInfo, itemID, amt)
	if storageInfo and isEmptyStorage(storageInfo) then
		-- emtpy
		local maxCount = OddMaxCount[itemID] or 64
		return math.floor(maxCount / amt)
	end
	for _, slot in pairs(storageInfo) do
		if itemID == slot.name then
			return math.floor((slot.maxCount - slot.count) / amt)
		end
	end
	return 0
end

local function fluidFitsTankCount(tankInfo, fluidID, amt)
	if tankInfo and isEmptyTank(tankInfo) then
		return math.floor(tankInfo[1].capacity / amt)
	end
	for _, tank in pairs(tankInfo) do
		if fluidID == tank.name then
			return math.floor((tank.capacity - tank.amount) / amt)
		end
	end
	return 0
end

local function inputFitCount(input, storageInfo, tankInfo)
	local fitCounts = nil

	for itemID, amt in pairs(input.item or {}) do
		local thisFit = itemFitsCount(storageInfo, itemID, amt)
		fitCounts = math.min(fitCounts or thisFit, thisFit)
	end
	for fluidID, amt in pairs(input.fluid or {}) do
		local thisFit = fluidFitsTankCount(tankInfo, fluidID, amt)
		fitCounts = math.min(fitCounts or thisFit, thisFit)
	end
	return fitCounts or 0
end
--------------------------------------------
local function getMachineReadiness(machineName, recipe)
	local storageInfo = factoryStatus[machineName].storageInfo
	local tankInfo = factoryStatus[machineName].tankInfo
	local craftingInfo = factoryStatus[machineName].craftingInfo

	local function getCraftingSpeed(ci)
		local ce = ci.currentEfficiency

		if ce ~= nil then return math.floor(math.pow(1.0672, math.min(ce, 64)))
		else return 1 end
	end

	local empty = isEmptyMachine(storageInfo, tankInfo)
	local fitUnits = inputFitCount(recipe.unitInput, storageInfo, tankInfo)
	local minPowOk = craftingInfo.maxRecipeCost >= recipe.minimumPower
	local craftSp = getCraftingSpeed(craftingInfo)
	
	return empty, fitUnits, minPowOk, craftSp
end

local function markMachine(machineName, info, req, states)
	local resultSchedule = states.resultSchedule
	local afterFeedCtlg = states.afterFeedCtlg
	local expectedOutputCtlg = states.expectedOutputCtlg

	local recipe = req.recipe
	local isEmpty, fitCount, minPowOk, craftingSpeed = getMachineReadiness(machineName, recipe)
	
	-- No requirements (This happens when other machines already took all requirements...)
	if req.required == 0 then return end
	
	-- Calulate numbers to try input on machine.
	local countTry = 0
	
	req.expInput = req.expInput or 1
	if not minPowOk then return
	elseif isEmpty then countTry = maxTryWhenEmpty
	elseif fitCount == 0 then return
	else countTry = math.max(math.floor(req.expInput), math.ceil(craftingSpeed)) end
	countTry = math.min(countTry, req.required, fitCount)

	if countTry <= 0 then
		print("isEmpty: " .. tostring(isEmpty) .. ", fitCount: " .. tostring(fitCount) .. ", countTry: " .. tostring(countTry))
		error(machineName)
	end

	-- Mark if there is at least one available machine.
	req.foundAvailableMachine = true
	
	-- Drop if machine is already occupied by higher rank.
	local previousRecipe = resultSchedule[machineName]
	if previousRecipe and recipe.rank > previousRecipe.rank then return end

	-- Calculate actual craftable unit count
	local actualScheduled, lacksCtlg = St.tryUse(afterFeedCtlg, recipe.unitInput, countTry)
	
	-- Mark lacking materials for report
	req.lackingCtlg = req.lackingCtlg or Ctlg:new()
	-- Numbers here does not represent actual lacking amount
	req.lackingCtlg:inPlaceAdd(lacksCtlg, Ctlg.ALLOW_KEY_CREATION)

	-- Cannot be scheduled, lacks material
	if actualScheduled == 0 then return end

	local inputScheduled = Helper.makeMultipliedIO(recipe.unitInput, actualScheduled)
	local outputScheduled = Helper.makeMultipliedIO(recipe.unitOutput, actualScheduled)

	-- Do schedule
	resultSchedule[machineName] = {
		input = inputScheduled,				-- Basic information
		output = outputScheduled,			-- For tracking output catalogue
		rank = recipe.rank,					-- for preemption
		dispName = recipe.dispName,			-- for debug
		itemInput = info.itemInput,			-- Multiblock machine only
		fluidInputs = info.fluidInputs,		-- Multiblock machine only
	}

	-- Mark scheduled
	req.required = req.required - actualScheduled

	-- Add result to expectedOutputCtlg
	expectedOutputCtlg:inPlaceAdd(Helper.IO2Catalogue(outputScheduled), Ctlg.ALLOW_KEY_CREATION)

	-- Increase exponential input criteria
	req.expInput = req.expInput * 1.7
end

local function makeCraftSchedule(req, states)
	-- Other recipe already fullfilled the requirements of production
	local recipeOutput = req.recipe.unitOutput
	local alreadyScheduledCtlg = states.expectedOutputCtlg
	local globalRequiredFullfilled = alreadyScheduledCtlg / Helper.IO2Catalogue(recipeOutput)
	req.required = math.max(req.required - globalRequiredFullfilled, 0)

	local mt = req.recipe.machineType
	for _, mn in ipairs(machineNames[mt]) do
		markMachine(mn, machineList[mt][mn], req, states)
	end
end
--------------------------------------------
local function prepareFactoryStatus()
	-- Make large info [storageInfo, tankInfo, craftingInfo] table for every machine.
	-- All parallel-consuming tasks will be here.
	local function getStorageInfo(info)
		local storageInfo = nil
		if info.singleBlockMachineName then
			if info.hasItem then
				storageInfo = info.wrapped.items()
			end
		elseif info.hasItem then
			-- Multiblock
			storageInfo = peripheral.call(info.itemInput, "items")
		end
		return storageInfo
	end
	local function getTankInfo(info)
		local tankInfo = nil
		if info.singleBlockMachineName then
			if info.hasFluid then
				tankInfo = info.wrapped.tanks()
			end
		else
			if info.hasFluid then
				tankInfo = {}
				TH.paraForNoResults(function(idx, tn) tankInfo[idx] = peripheral.call(tn, "tanks")[1] end, ipairs(info.fluidInputs))
			end
		end
		return tankInfo
	end
	local function getMachineCraftingInfo(info)
		if info.getCraftingInfo then
			return info.getCraftingInfo()
		else
			return {}
		end
	end
	local function paraCost(info, totalPullCnts)
		local ret = 0
		if info.singleBlockMachineName then
			if info.hasItem then ret = ret + 1 end
			if info.hasFluid then ret = ret + 1 end
			ret = ret + 1
		else
			if info.hasItem then ret = ret + 1 end
			if info.hasFluid then ret = ret + #info.fluidInputs end
			ret = ret + 1
		end
		return ret
	end
	local function harvestToBufferSingleMachine(machineName, info, itemPuller, itemPullCnt, fluidPuller, fluidPullCnt)
		local function pullEveryItem(storageName)
			TH.doMany(function() itemPuller(storageName) end, itemPullCnt)
		end
		local function pullEveryFluid(tankName)
			TH.doMany(function() fluidPuller(tankName) end, fluidPullCnt)
		end
		local bufferPullers = {}
		if info.singleBlockMachineName then
			if info.hasItem then
				bufferPullers[#bufferPullers + 1] = function() pullEveryItem(machineName) end
			end
			if info.hasFluid then
				bufferPullers[#bufferPullers + 1] = function() pullEveryFluid(machineName) end
			end
		else
			-- No pull from multiblock machine (input and output is separated in multiblock machines...)
		end
		parallel.waitForAll(table.unpack(bufferPullers))
	end

	local statusGetters = {}
	local accParaCost = 0
	local itemPuller = St.bufferAE.pullItem
	local fluidPuller = St.bufferAE.pullFluid
	for mt, machines in pairs(machineList) do
		local itemPullCnt = MachineProperty.OutputItemSlotCount[mt] or 0
		local fluidPullCnt = MachineProperty.OutputFluidSlotCount[mt] or 0

		for mn, info in pairs(machines) do
			local thisParaCost = paraCost(info, itemPullCnt + fluidPullCnt)
			if (accParaCost + thisParaCost) > paraCostLimit then
				parallel.waitForAll(table.unpack(statusGetters))
				statusGetters = {}
				accParaCost = 0
			end

			factoryStatus[mn].type = mt
			statusGetters[#statusGetters + 1] = function()
				parallel.waitForAll(
					function() harvestToBufferSingleMachine(mn, info, itemPuller, itemPullCnt, fluidPuller, fluidPullCnt) end,
					function() factoryStatus[mn].storageInfo = getStorageInfo(info) end,
					function() factoryStatus[mn].tankInfo = getTankInfo(info) end,
					function() factoryStatus[mn].craftingInfo = getMachineCraftingInfo(info) end
				)
			end
			accParaCost = accParaCost + thisParaCost
		end
	end
	parallel.waitForAll(table.unpack(statusGetters))
end
--------------------------------------------
function M.init()
	refreshMachines()
end
--------------------------------------------
function M.makeFactoryCraftSchedule(craftReqs, afterFeedCtlg)
	assert(afterFeedCtlg ~= nil)
	
	local resultSchedule = Ctlg:new()
	local expectedOutputCtlg = Ctlg:new()
	local lackingStatus = {}
	local machineLackingStatus = {}
	
	prepareFactoryStatus()	-- Consumes paraCount
	
	local states = {
		resultSchedule = resultSchedule,
		afterFeedCtlg = afterFeedCtlg,
		expectedOutputCtlg = expectedOutputCtlg,
	}
	
	for _, req in ipairs(craftReqs) do
		makeCraftSchedule(req, states)
		for id in pairs(req.lackingCtlg or {}) do
			lackingStatus[id] = true
		end
		if not req.foundAvailableMachine then
			machineLackingStatus[req.recipe.machineType] = true
		end
	end

	return resultSchedule, lackingStatus, machineLackingStatus
end
----------------------------------------------
--- Do one 'pullFluid' and one 'pullItem' on each machine, including all multiblock output hatches
--- This is for pulling leftover products 'slowly', as scheduler only 'pulls' when the machine has thing to craft.
--- Obeys 'paraCostLimit'.
function M.harvestToBufferSlow()
	local function paraCost(info)
		local ret = 0
		if info.singleBlockMachineName then
			if info.hasItem then ret = ret + 1 end
			if info.hasFluid then ret = ret + 1 end
		end
		return ret
	end
	
	local bufferPullers = {}
	local accParaCost = 0
	local pullItem = St.bufferAE.pullItem
	local pullFluid = St.bufferAE.pullFluid
	for mt, ml in pairs(machineList) do
		for mn, info in pairs(ml) do
			local thisParaCost = paraCost(info)
			if (accParaCost + thisParaCost) > paraCostLimit then
				parallel.waitForAll(table.unpack(bufferPullers))
				bufferPullers = {}
				accParaCost = 0
			end

			if info.singleBlockMachineName then
				if info.hasItem then
					bufferPullers[#bufferPullers + 1] = function() pullItem(mn) end
				end
				if info.hasFluid then
					bufferPullers[#bufferPullers + 1] = function() pullFluid(mn) end
				end
			end

			accParaCost = accParaCost + thisParaCost
		end
	end
	parallel.waitForAll(table.unpack(bufferPullers))
end

--- Send buffer contents to main AE system. Not obeys paraCostLimit.
---@param bufferAE table
---@param bufferStorages table List of item storages connected to bufferAE network
---@param bufferTanks table list of fluid storages connected to bufferAE network
---@param mainAE table Main AE network
---@return table Harvested materials catalogue
function M.harvestFromBuffer(bufferAE, bufferStorages, bufferTanks, mainAE)
	local harvestedCtlg = Ctlg:new()

	local harvestedItems
	local harvestedTanks
	harvestedItems, harvestedTanks = table.unpack(TH.paraDoAll(bufferAE.items, bufferAE.tanks))

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

--- Feed entire factory items and fluids for craft. Obeys paraCostLimit
---@param scd table Schedule
---@param fromAE table Source of item/fluids
---@return table "fed" = Catalogue of all fed materials // "expected" = Catalogue of expected outputs
---@return table expectedOutputs
function M.feedFactory(scd, fromAE)
	local fedCtlg = Ctlg:new()
	local expectedOutputCtlg = Ctlg:new()

	local function feedItem(storageName, itemID, limit)
		local fedCount = fromAE.pushItem(storageName, itemID, limit)
		assert(fedCount == limit, storageName .. " -- " .. itemID .. " should fed: " .. limit .. ", actual: " .. fedCount)
		fedCtlg[itemID] = (fedCtlg[itemID] or 0) + fedCount
	end
	local function feedFluid(tankName, fluidID, limit)
		local fedAmt = fromAE.pushFluid(tankName, limit, fluidID)
		assert(fedAmt == limit, tankName .. " -- " .. fluidID .. " should fed: " .. limit .. ", actual: " .. fedAmt)
		fedCtlg[fluidID] = (fedCtlg[fluidID] or 0) + fedAmt
	end
	local function getConsistantFluidHatchMatches(fluidCtlg, hatchList)
		local fluidIDList = {}
		for k in pairs(fluidCtlg) do
			fluidIDList[#fluidIDList + 1] = k
		end
		table.sort(fluidIDList)
		local hatchMatches = {}
		for idx, hatch in ipairs(hatchList) do
			local idToFeed = fluidIDList[idx]
			hatchMatches[hatch] = {
				fluidID = idToFeed,
				amt = fluidCtlg[idToFeed]
			}
		end
		return hatchMatches
	end
	local function paraCost(inputCtlg)
		local inputIDs = {}
		for k in pairs(inputCtlg) do
			inputIDs[#inputIDs + 1] = k
		end
		return #inputIDs
	end

	local accParaCost = 0
	local feedJobs = {}
	for name, craftScd in pairs(scd) do
		local thisParaCost = paraCost(Helper.IO2Catalogue(craftScd.input))
		if (accParaCost + thisParaCost) > paraCostLimit then
			parallel.waitForAll(table.unpack(feedJobs))
			feedJobs = {}
			accParaCost = 0
		end

		-- Item feeding
		local itemTarget = craftScd.itemInput or name
		for itemID, count in pairs(craftScd.input.item or {}) do
			feedJobs[#feedJobs + 1] = function() feedItem(itemTarget, itemID, count) end
		end
		
		-- Fluid feeding
		if not craftScd.fluidInputs then
			-- Singleblock machine
			for fluidID, amt in pairs(craftScd.input.fluid or {}) do
				feedJobs[#feedJobs + 1] = function() feedFluid(name, fluidID, amt) end
			end
		else
			-- Multiblock machine
			local hatchMatches = getConsistantFluidHatchMatches(craftScd.input.fluid, craftScd.fluidInputs)
			for hatch, fluidFeedInfo in pairs(hatchMatches) do
				feedJobs[#feedJobs + 1] = function() feedFluid(hatch, fluidFeedInfo.fluidID, fluidFeedInfo.amt) end
			end
		end
	
		-- Counting
		expectedOutputCtlg:inPlaceAdd(Helper.IO2Catalogue(craftScd.output), Ctlg.ALLOW_KEY_CREATION)

		-- Increament paraCost
		accParaCost = accParaCost + thisParaCost
	end
	parallel.waitForAll(table.unpack(feedJobs))

	return fedCtlg, expectedOutputCtlg
end
----------------------------------------------
----------------------------------------------

function M.printMachineList()
	Helper.printPretty(machineList)
end

return M