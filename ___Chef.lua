local Recipes = require("Recipes")
local GoalsCtlg = require("Goals")
local M = require("__Machines")
local St = require("__Storage")
local Helper = require("__Helpers")
local DirectProd = require("Dict").DirectProd
local Ctlg = require("__Catalouge")

-- Main program
local Chef = {}
local moni

local function tmpGoalMaker(seedGoals, dps, rcps, factor)
	local prodDict = {}
	local function find(l, ctlg)
		for i = 1, #l do
			if l[i] == ctlg then
				return i
			end
		end
		return 0
	end
	local function preciseCtlgMult(ctlg, toMult)
		return ctlg:map(function(_, v) return v * toMult end)
	end
	for _, r in ipairs(rcps) do
		if (not r.alwaysProc) and (not r.opportunistic) then
			for mat, amt in pairs(r.effUnitOutputCtlg) do
				prodDict[mat] = prodDict[mat] or {}
				local unit = preciseCtlgMult(Helper.IO2Catalogue(r.unitInput), 1 / amt)
				if find(prodDict[mat], unit) == 0 then
					table.insert(prodDict[mat], unit)
				end
			end
		end
	end

	-- local cnt = 0
	-- for mat, methods in pairs(prodDict) do
	-- 	if #methods > 1 then
	-- 		cnt = cnt + 1
	-- 		print(Helper.dispNameMaker(mat), #methods, cnt)
	-- 	end
	-- end

	local tmpGoals = Ctlg:new()
	local hasChainSet = {}

	local function hasValidChain(id)
		if hasChainSet[id] ~= nil then
			return hasChainSet[id]
		end
	
		local methods = prodDict[id]
		if methods == nil then
			if dps[id] == nil then
				print("WARN:", id, "does not have recipe! (Is it Direct Product?)")
				-- Fail to make production chain; Goal should NOT be made.
				hasChainSet[id] = false
				return false
			else
				-- Succeed to make production chain; Goal should be made.
				hasChainSet[id] = true
				return true
			end
		end
		local ret = false
		for _, unitCltg in ipairs(methods) do
			local isValidMethod = true
			for matID in pairs(unitCltg) do
				isValidMethod = isValidMethod and hasValidChain(matID)
			end
			ret = ret or isValidMethod
		end

		hasChainSet[id] = ret
		return ret
	end

	local function addTempGoalsFor(targetItem, amt)
		if dps[targetItem] ~= nil then
			return
		end

		local methods = prodDict[targetItem]
		local validMethods = {}
		for _, unitCltg in ipairs(methods) do
			local isValidMethod = true
			for matID, matAmt in pairs(unitCltg) do
				isValidMethod = isValidMethod and hasValidChain(matID)
			end
			if isValidMethod then
				table.insert(validMethods, unitCltg)
			end
		end
		
		for _, unitCtlg in ipairs(validMethods) do
			for matID, matAmt in pairs(unitCtlg) do
				matAmt = matAmt * amt / #validMethods
				tmpGoals[matID] = (tmpGoals[matID] or 0) + matAmt
				addTempGoalsFor(matID, matAmt)
			end
		end
	end

	for id, amt in pairs(seedGoals) do
		addTempGoalsFor(id, amt)
	end
	tmpGoals:map(function(_, amt) return math.ceil(amt) end)
	Helper.printPretty(tmpGoals)
	return tmpGoals
end

function Chef.init()
	M.init()
	St.init()
	tmpGoalMaker(GoalsCtlg, DirectProd, Recipes, 1)
	moni = peripheral.find("monitor")
end

function Chef.step(prevLackingStatus, prevMachineLackingStatus)
	St.refreshCatalogue()
	
	if moni then
		St.printStatusToMonitor(GoalsCtlg, prevLackingStatus, prevMachineLackingStatus, moni)
	end

	local craftRequirements = St.getRequirements(Recipes, GoalsCtlg)

	M.harvestToBufferSlow()
	local factoryScd, lackingStatus, machineLackingStatus = M.makeFactoryCraftSchedule(craftRequirements, St.getCatalogueCopy())

	os.sleep(0.01)	-- 1 tick for AE system to prepare.

	local harvestedCtlg = M.harvestFromBuffer(St.bufferAE, St.BufferStorages, St.BufferTanks, St.mainAE)
	
	local fedCtlg, expectedCtlg = M.feedFactory(factoryScd, St.mainAE)
	
	St.applyExpectedCatalogue(expectedCtlg)
	St.applyHarvestedCatalogue(harvestedCtlg)

	if (rs.getInput("left")) then
		if moni then
			local x, y = moni.getCursorPos()
			local xx, yy = moni.getSize()
			moni.setCursorPos(xx / 2 - 2, y + (yy - y) / 2)
			moni.write("FROZEN")
		end
		while rs.getInput("left") do
			os.sleep(0.1)
			M.harvestToBufferSlow()
			os.sleep(0.01)
			-- Pulling back outputs from factory should not stop
			St.applyHarvestedCatalogue(M.harvestFromBuffer(St.bufferAE, St.BufferStorages, St.BufferTanks, St.mainAE))
		end
	end
	return lackingStatus, machineLackingStatus
end

print("Initializing...")
local cur = os.clock()
Chef.init()
print("Initializing took " .. Helper.tickFrom(cur) .. " ticks")

error("OK")

local lackingStatus = {}
local machineLackingStatus = {}
while true do
	local cur = os.clock()
	lackingStatus, machineLackingStatus = Chef.step(lackingStatus, machineLackingStatus)
	print(Helper.tickFrom(cur) .. " ticks for previous step.")
end