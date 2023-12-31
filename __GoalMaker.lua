local Prefix = require("Dict").Prefix
local I = require("Dict").Item
local F = require("Dict").Fluid
local DirectProd = require("Dict").DirectProd
local Ctlg = require("__Catalouge")
local Helper = require("__Helpers")

local mi = Prefix.moin
local tr = Prefix.techReborn
local va = Prefix.vanilla
local cr = Prefix.create
local ad = Prefix.adAstra

local Goals = {}

local function goalMaker(gs)
	local seedGoalsCtlg = Ctlg:new()
	for k, v in pairs(gs) do
		if DirectProd[k] ~= nil then
			error(k .. " is direct production, cannot set the goal.")
		end
		seedGoalsCtlg[k] = v
	end
	return seedGoalsCtlg
end

local function makeAutoGoals(seedGoals, dps, prodGraph)
	-- local cnt = 0
	-- for mat, methods in pairs(prodGraph) do
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
	
		local methods = prodGraph[id]
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

	local function addDerivedGoalsFor(targetItem, amt)
		if dps[targetItem] ~= nil then
			-- Is Direct product; no goals set.
			return
		end
		tmpGoals[targetItem] = (tmpGoals[targetItem] or 0) + amt
		if not hasValidChain(targetItem) then
			-- Does not have any valid production chain, but just.. put it in the goals.
			return
		end

		local methods = prodGraph[targetItem]
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
				addDerivedGoalsFor(matID, matAmt)
			end
		end
	end

	for id, amt in pairs(seedGoals) do
		addDerivedGoalsFor(id, amt)
	end
	tmpGoals:map(function(_, amt) return math.ceil(amt) end)
	-- Helper.printPretty(tmpGoals)
	return tmpGoals
end

function Goals.init(directProducts, prodGraph)
	package.loaded.Goals = nil
	local seedGoalsCtlg = require("Goals")
	Goals.DerivedGoalsCtlg = makeAutoGoals(seedGoalsCtlg, directProducts, prodGraph)
end

return Goals