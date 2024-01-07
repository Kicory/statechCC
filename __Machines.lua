local MachineProperty = require("MachineProperties")
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
local paraCostLimit = 250
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
		local info = {}
		info.wrapped = machineWrapped
		info.hasFluid = peripheral.hasType(machineName, PpType.fluidStorage)
		info.hasItem = peripheral.hasType(machineName, PpType.itemStorage)

		if peripheral.hasType(machineName, PpType.miCrafter) then
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
	for _, mt in pairs(singleBlockMachineTypes) do
		machineList[mt] = {}
		machineNames[mt] = {}
		peripheral.find(mt, function(machineName, machineWrapped) registerMachine(mt, machineName, machineWrapped) end)
	end

	local BigMachines = require("OtherMachines").BigMachines
	-- Add multiblock machines manually
	for mt, tl in pairs(BigMachines) do
		machineList[mt] = {}
		machineNames[mt] = {}
		for mn, info in pairs(tl) do
			if peripheral.isPresent(mn) then
				info.wrapped = peripheral.wrap(mn)
				info.getCraftingInfo = info.wrapped.getCraftingInformation
				info.isBusy = info.wrapped.isBusy
				machineList[mt][mn] = info
				table.insert(machineNames[mt], mn)
			end
		end
	end

	local CustomMachines = require("OtherMachines").CustomMachines
	-- Add custom machines (not mi crafters) manually
	for mt, tl in pairs(CustomMachines) do
		machineList[mt] = {}
		machineNames[mt] = {}
		for mn, info in pairs(tl) do
			if peripheral.isPresent(mn) or string.find(mn, "trash_can") then
				info.wrapped = peripheral.wrap(mn)
				machineList[mt][mn] = info
				table.insert(machineNames[mt], mn)
			end
		end
	end

	-- Create empty factoryStatus
	for mt, tl in pairs(machineList) do
		for mn, info in pairs(tl) do
			factoryStatus[mn] = {
				type = mt,
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
	local minPowOK
	if craftingInfo.maxRecipeCost ~= nil then
		minPowOK = craftingInfo.maxRecipeCost >= recipe.minimumPower
	else
		-- Custom machinary; do not have restriction
		minPowOK = true
	end
	local craftSp = getCraftingSpeed(craftingInfo)
	
	return empty, fitUnits, minPowOK, craftSp
end

local function markMachine(machineName, info, req, states)
	local resultSchedule = states.resultSchedule
	local afterFeedCtlg = states.afterFeedCtlg
	local expectedOutputCtlg = states.expectedOutputCtlg
	local goalsCtlg = states.goalsCtlg

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

	-- Calculate stock padding (Materials reserve for other recipes)
	local stockOffsetCtlg = recipe.paddingCtlg:copy()
	for id, amt in pairs(stockOffsetCtlg) do
		if amt == recipe.PADDING_GOAL then
			stockOffsetCtlg[id] = -goalsCtlg[id]
		elseif amt == recipe.PADDING_HALF_GOAL then
			stockOffsetCtlg[id] = -math.ceil(goalsCtlg[id] / 2)
		else
			stockOffsetCtlg[id] = -amt
		end
	end

	-- Calculate actual craftable unit count
	local actualScheduled, lacksCtlg = St.tryUse(afterFeedCtlg, stockOffsetCtlg, Helper.IO2Catalogue(recipe.unitInput), countTry)
	
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
	if not req.recipe.alwaysProc then
		-- Other recipe already fullfilled the requirements of production
		local recipeOutput = req.recipe.unitOutput
		local globalRequiredFullfilled = states.expectedOutputCtlg / Helper.IO2Catalogue(recipeOutput)
		req.required = math.max(req.required - globalRequiredFullfilled, 0)
	end

	local mt = req.recipe.machineType
	for _, mn in ipairs(machineNames[mt] or {}) do
		markMachine(mn, machineList[mt][mn], req, states)
	end
end
--------------------------------------------
function M.init()
	package.loaded.OtherMachines = nil
	refreshMachines()
end
--------------------------------------------
function M.updateFactory(fromAE)
	local harvestedCtlg = Ctlg:new()
	local itemPuller = fromAE.pullItem
	local fluidPuller = fromAE.pullFluid

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
	local function harvestToBufferSingleMachine(machineName, info, itemPullCnt, fluidPullCnt)
		os.sleep(0.01) -- Wait for factoryStatus fill up
		local si = factoryStatus[machineName].storageInfo
		local ti = factoryStatus[machineName].tankInfo
		
		local function harvestItem()
			local sLen = #si
			local pullers = {}
			for idx = sLen, math.max(1, sLen - itemPullCnt + 1), -1 do
				local singleStorage = si[idx]
				pullers[#pullers + 1] = function() 
					local harvestedAmt = itemPuller(machineName, singleStorage.name, singleStorage.count)
					if harvestedAmt ~= 0 then
						harvestedCtlg[singleStorage.name] = (harvestedCtlg[singleStorage.name] or 0) + harvestedAmt
						-- Update storageInfo
						si[idx] = nil
					end
				end
			end
			parallel.waitForAll(table.unpack(pullers))
		end
		local function harvestFluid()
			local pullers = {}
			for idx = #ti, #ti - fluidPullCnt + 1, -1 do
				local singleTank = ti[idx]
				if singleTank.amount ~= 0 then
					pullers[#pullers + 1] = function()
						local harvestedAmt = fluidPuller(machineName, singleTank.amount, singleTank.name)
						if harvestedAmt ~= 0 then
							harvestedCtlg[singleTank.name] = (harvestedCtlg[singleTank.name] or 0) + harvestedAmt
							-- Update tankInfo
							singleTank.amount = 0
							singleTank.name = Fluid.empty
						end
					end
				end
			end
			parallel.waitForAll(table.unpack(pullers))
		end

		local bufferPullers = {}

		if info.singleBlockMachineName then
			if info.hasItem then
				bufferPullers[#bufferPullers + 1] = harvestItem
			end
			if info.hasFluid then
				bufferPullers[#bufferPullers + 1] = harvestFluid
			end
		else
			-- No pull from multiblock machine (input and output is separated in multiblock machines...)
		end
		parallel.waitForAll(table.unpack(bufferPullers))
	end

	local statusGetters = {}
	local accParaCost = 0

	for mt, machines in pairs(machineList) do
		local itemPullCnt = MachineProperty.OutputItemSlotCount[mt] or 0
		local fluidPullCnt = MachineProperty.OutputFluidSlotCount[mt] or 0

		for mn, info in pairs(machines) do
			local thisParaCost = itemPullCnt + fluidPullCnt + 3
			if (accParaCost + thisParaCost) > paraCostLimit then
				parallel.waitForAll(table.unpack(statusGetters))
				statusGetters = {}
				accParaCost = 0
			end

			factoryStatus[mn].type = mt
			statusGetters[#statusGetters + 1] = function()
				parallel.waitForAll(
					function() factoryStatus[mn].storageInfo = getStorageInfo(info) end,
					function() factoryStatus[mn].tankInfo = getTankInfo(info) end,
					function() harvestToBufferSingleMachine(mn, info, itemPullCnt, fluidPullCnt) end,
					function() factoryStatus[mn].craftingInfo = getMachineCraftingInfo(info) end
				)
			end
			accParaCost = accParaCost + thisParaCost
		end
	end
	parallel.waitForAll(table.unpack(statusGetters))
	return harvestedCtlg
end
--------------------------------------------
function M.makeFactoryCraftSchedule(craftReqs, afterFeedCtlg, goalsCtlg)
	assert(afterFeedCtlg ~= nil)
	
	local resultSchedule = Ctlg:new()
	local expectedOutputCtlg = Ctlg:new()
	local lackingStatus = {}
	local machineLackingStatus = {}

	local states = {
		resultSchedule = resultSchedule,
		afterFeedCtlg = afterFeedCtlg,
		expectedOutputCtlg = expectedOutputCtlg,
		goalsCtlg = goalsCtlg,
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
--- Feed entire factory items and fluids for craft. Obeys paraCostLimit
---@param scd table Schedule
---@param fromAE table Source of item/fluids
---@return table "fed" = Catalogue of all fed materials // "expected" = Catalogue of expected outputs
---@return table expectedOutputs
function M.feedFactory(scd, fromAE)
	local fedCtlg = Ctlg:new()
	local expectedOutputCtlg = Ctlg:new()

	local function pushMaterial(toName, id, limit, isItem)
		if isItem then
			return fromAE.pushItem(toName, id, limit)
		else
			return fromAE.pushFluid(toName, limit, id)
		end
	end

	local function feedMaterial(toName, matID, limit, isItem)
		local fedAmt = pushMaterial(toName, matID, limit, isItem)
		local trial = 0
		while fedAmt ~= limit do
			trial = trial + 1
			printError(toName .. " -- " .. matID .. " should fed: " .. limit .. ", actual: " .. fedAmt .. ", Trial: " .. trial)
			if trial >= 3 then
				printError("!!!!!!!!!!!!!!!!!!!!\nDO SOMETHING and press any key.\n!!!!!!!!!!!!!!!!!!!!")
				Helper.doAlarmUntilEvent()
			end
			fedAmt = fedAmt + pushMaterial(toName, matID, limit - fedAmt, isItem)
		end
		fedCtlg[matID] = (fedCtlg[matID] or 0) + fedAmt
	end

	local function getConsistantFluidHatchMatches(fluidCtlg, hatchList)
		local fluidIDList = fluidCtlg:getKeys()
		assert(#fluidIDList <= #hatchList, debug.traceback())
		table.sort(fluidIDList)
		local hatchMatches = {}
		for idx, fid in ipairs(fluidIDList) do
			hatchMatches[hatchList[idx]] = {
				fluidID = fid,
				amt = fluidCtlg[fid]
			}
		end
		return hatchMatches
	end
	local function paraCost(inputCtlg)
		return #(inputCtlg:getKeys())
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
			feedJobs[#feedJobs + 1] = function() feedMaterial(itemTarget, itemID, count, true) end
		end
		
		-- Fluid feeding
		if not craftScd.fluidInputs then
			-- Singleblock machine
			for fluidID, amt in pairs(craftScd.input.fluid or {}) do
				feedJobs[#feedJobs + 1] = function() feedMaterial(name, fluidID, amt, false) end
			end
		else
			-- Multiblock machine
			local hatchMatches = getConsistantFluidHatchMatches(Ctlg:new(craftScd.input.fluid), craftScd.fluidInputs)
			for hatch, fluidFeedInfo in pairs(hatchMatches) do
				feedJobs[#feedJobs + 1] = function() feedMaterial(hatch, fluidFeedInfo.fluidID, fluidFeedInfo.amt, false) end
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