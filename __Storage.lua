require("Dict")
require("Enviornment")
require("__ThreadingHelpers")
require("__Helpers")

St = {
	bufferAE = nil,
	mainAE = nil,
	BufferStorages = nil,
	BufferTanks = nil,
}

local emptyCtlg = {}
-- Whole item data
local catalogue = {}
local craftingCtlg = {}
local lackingMaterialsSet = {}

local function findStorageSystems()
	St.bufferAE = peripheral.wrap(StorageSystems.buffer)
	St.mainAE = peripheral.wrap(StorageSystems.main)
	St.BufferStorages = StorageSystems.BufferStorages
	St.BufferTanks = StorageSystems.BufferTanks
end

local function calcCtlg(ctlg1, ctlg2, func, defaultVal)
	local keyDict = {}
	local resultCtlg = {}
	for k, _ in pairs(ctlg1) do
		keyDict[k] = true
	end
	for k, _ in pairs(ctlg2) do
		keyDict[k] = true
	end
	for k, _ in pairs(keyDict) do
		resultCtlg[k] = func(ctlg1[k] or defaultVal, ctlg2[k] or defaultVal)
	end

	return resultCtlg
end

local function add(a, b) return a + b end

local function sub(a, b) return a - b end

--- Apply function to every entry, in place. No return.
---@param ctlg table
---@param func function
local function funcCtlgInplace(ctlg, func)
	for k, v in pairs(ctlg) do
		ctlg[k] = func(ctlg[k])
	end
end

local function copyEmptyCtlg()
	local ret = {}
	for k, _ in pairs(emptyCtlg) do
		ret[k] = 0
	end
	return ret
end

local function recipeManagerCoroutine(recipe)
	while true do

	end
end
-----------------------------------
function St.init()
	findStorageSystems()
	emptyCtlg = Recipes:getMaterialsUsedEmptyCtlg()
end

function St.refreshCatalogue()
	assert(St.mainAE ~= nil)
	catalogue = copyEmptyCtlg()
	local function refreshItem()
		local items = St.mainAE.items()
		for _, item in ipairs(items) do
			if catalogue[item.technicalName] then
				catalogue[item.technicalName] = item.count
			end
		end
	end
	local function refreshFluid()
		local tanks = St.mainAE.tanks()
		for _, tank in ipairs(tanks) do
			if catalogue[tank.name] then
				catalogue[tank.name] = tank.amount
			end
		end
	end
	parallel.waitForAll(refreshItem, refreshFluid)
end

function St.getCatalogueCopy()
	local copy = {}
	for id, amt in pairs(catalogue) do
		copy[id] = amt
	end
	return copy
end

function St.clearLackingMaterialsSet()
	for k, _ in pairs(lackingMaterialsSet) do
		lackingMaterialsSet[k] = nil
	end
end

--- Try consume material from catalogue given.
---@param ctlg table
---@param toUse table Materials to use, in unitInput format
---@return boolean True if successfully used
function St.tryUse(ctlg, toUse)
	local result = true
	local enough
	for itemID, amt in pairs(toUse.item or {}) do
		enough = ctlg[itemID] >= amt
		result = result and enough
		if not enough then
			lackingMaterialsSet[itemID] = true
		end
	end
	for fluidID, amt in pairs(toUse.fluid or {}) do
		enough = ctlg[fluidID] >= amt
		result = result and enough
		if not enough then
			lackingMaterialsSet[fluidID] = true
		end
	end
	if result then
		for itemID, amt in pairs(toUse.item or {}) do
			ctlg[itemID] = ctlg[itemID] - amt
		end
		for fluidID, amt in pairs(toUse.fluid or {}) do
			ctlg[fluidID] = ctlg[fluidID] - amt
		end
		return true
	else
		return false
	end
end
-----------------------------------
function St.filterRequired(wholeRecipes, goals)
	local potentialCtlg = calcCtlg(catalogue, craftingCtlg, add, 0)
	local factorySizeFactor = 3
	local resultRecipes = {}
	local requiredUnits = {}

	local function getRequiredUnit(recipe)
		local output = recipe.unitOutput
		local requiredUnit = 0
		for itemID, count in pairs(output.item or {}) do
			local balance = potentialCtlg[itemID] - (goals[itemID] or 0)
			requiredUnit = math.max(requiredUnit, math.ceil((-balance) / count))
		end
		for fluidID, amt in pairs(output.fluid or {}) do
			local balance = potentialCtlg[fluidID] - (goals[fluidID] or 0)
			requiredUnit = math.max(requiredUnit, math.ceil((-balance) / amt))
		end
		return requiredUnit
	end

	for _, recipe in ipairs(wholeRecipes) do
		local unitCount = getRequiredUnit(recipe)
		if unitCount ~= 0 then
			local idx = #resultRecipes + 1
			resultRecipes[idx] = recipe
			requiredUnits[idx] = unitCount
		end
	end
	return {resultRecipes, requiredUnits}
end

function St.applyHarvestedCatalogue(harvestedCtlg)
	craftingCtlg = calcCtlg(craftingCtlg, harvestedCtlg, sub, 0)
	-- CraftingCtlg cannot be negative; it is bug or leftover harvests from previous session.
	funcCtlgInplace(craftingCtlg, function(v) return math.max(0, v) end)
end

function St.applyExpectedCatalogue(expectedCtlg)
	craftingCtlg = calcCtlg(craftingCtlg, expectedCtlg, add, 0)
end

-----------------------------------
function St.printCatalogue()
	Helper.printPretty(catalogue)
end

function St.printCraftingCtlg()
	Helper.printPretty(craftingCtlg)
end

function St.printBlanceCtlg(goals)
	Helper.printPretty(calcCtlg(calcCtlg(catalogue, craftingCtlg, add, 0), goals, sub, 0))
end

function St.printStatusToMonitor(goals, moni)

	local balanceCtlg = calcCtlg(calcCtlg(catalogue, craftingCtlg, add, 0), goals, sub, 0)
	local lacks = {}
	-- Copy lackingMaterialsSet
	for k, _ in pairs(lackingMaterialsSet) do
		lacks[k] = true
	end

	local toPrint = {}
	for id, bal in pairs(balanceCtlg) do
		local name = DispName[id] or Helper.dispNameMaker(id)

		if bal < 0 then
			toPrint[#toPrint + 1] = {name, goals[id], bal, craftingCtlg[id] or 0}
			-- It's already crafting (or at least lackage is reported.)
			lacks[id] = nil
		end
	end
	for id, _ in pairs(lacks) do
		local name = DispName[id] or id
		toPrint[#toPrint + 1] = {name, "Lacks", "Lacks", "Lacks"}
	end

	local widRatios = {0.34, 0.22, 0.22, 0.22}
	local backColors = {{colors.pink, colors.lightBlue}, {colors.pink, colors.lightGray}}
	local textColors = {{colors.red, colors.black}, {colors.red, colors.black}}
	moni.clear()
	moni.setCursorPos(1, 1)

	Helper.printRowOf(widRatios, {colors.black}, {colors.lightBlue}, {"Name/ID", "Goal", "Balance", "Crafting..."}, moni)
	for idx, row in ipairs(toPrint) do
		Helper.printRowOf(widRatios, backColors[(idx % 2) + 1], textColors[(idx % 2) + 1], row, moni)
	end
end
