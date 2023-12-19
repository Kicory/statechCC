require("Dict")
require("Enviornment")
local TH = require("__ThreadingHelpers")
local Helper = require("__Helpers")
local Ctlg = require("__Catalouge")

local St = {
	bufferAE = nil,
	mainAE = nil,
	BufferStorages = nil,
	BufferTanks = nil,
}

local emptyCtlg = nil
-- Whole item data
local catalogue = nil

local craftingCtlg = Ctlg:new()

local function findStorageSystems()
	St.bufferAE = peripheral.wrap(StorageSystems.buffer)
	St.mainAE = peripheral.wrap(StorageSystems.main)
	St.BufferStorages = StorageSystems.BufferStorages
	St.BufferTanks = StorageSystems.BufferTanks
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
	catalogue = emptyCtlg:copy()
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
	return catalogue:copy()
end

--- Try consume material from catalogue given.
---@param ctlg table
---@param toUse table Materials to use, in unitInput format
---@param limit integer Maximum units to use.
---@return integer count of units successfully used
function St.tryUse(ctlg, toUse, limit)
	assert(limit ~= nil and limit > 0)

	local result = ctlg / Helper.IO2Catalogue(toUse)
	result = math.min(limit, result)

	if result ~= 0 then
		local used = Helper.IO2Catalogue(Helper.makeMultipliedIO(toUse, result))
		ctlg:inPlaceSub(used, Ctlg.ERROR_ON_NEW_KEY)
	end
	
	return result
end
-----------------------------------
function St.getRequirements(wholeRecipes, goalsCtlg)
	local requiredCtlg = goalsCtlg - (catalogue + craftingCtlg)
	local craftRequirements = {}

	local function getRequiredUnit(recipe)
		local output = recipe.unitOutput
		local requiredUnit = 0
		for itemID, count in pairs(output.item or {}) do
			requiredUnit = math.max(requiredUnit, math.ceil(requiredCtlg[itemID] / count))
		end
		for fluidID, amt in pairs(output.fluid or {}) do
			requiredUnit = math.max(requiredUnit, math.ceil(requiredCtlg[fluidID] / amt))
		end
		return requiredUnit
	end

	for _, recipe in ipairs(wholeRecipes) do
		local unitCount = getRequiredUnit(recipe)
		if unitCount ~= 0 then
			craftRequirements[#craftRequirements + 1] = {
				recipe = recipe,
				required = unitCount,
			}
		end
	end
	return craftRequirements
end

function St.applyHarvestedCatalogue(harvestedCtlg)
	craftingCtlg:inPlaceSub(harvestedCtlg, Ctlg.ALLOW_KEY_CREATION)

	-- CraftingCtlg cannot be negative; it is bug or leftover harvests from previous session.
	craftingCtlg:map(function(k, v) return math.max(0, v) end)
end

function St.applyExpectedCatalogue(expectedCtlg)
	craftingCtlg:inPlaceAdd(expectedCtlg, Ctlg.ALLOW_KEY_CREATION)
end

-----------------------------------
function St.printCatalogue()
	Helper.printPretty(catalogue)
end

function St.printCraftingCtlg()
	Helper.printPretty(craftingCtlg)
end

function St.printStatusToMonitor(goals, moni)
	local balanceCtlg = (catalogue + craftingCtlg):inPlaceSub(goals, Ctlg.ALLOW_KEY_CREATION)
	local lacks = {}
	
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
		local name = DispName[id] or Helper.dispNameMaker(id)
		toPrint[#toPrint + 1] = {name, "Lacks", "Lacks", "Lacks"}
	end

	local widRatios = {0.34, 0.22, 0.22, 0.22}
	local backColors = {{colors.pink, colors.lightBlue}, {colors.pink, colors.lightGray}}
	local textColors = {{colors.red, colors.black}, {colors.red, colors.black}}
	moni.clear()
	moni.setCursorPos(1, 1)

	Helper.printRowOf(widRatios, {colors.black}, {colors.lightBlue}, {"Name/ID", "Goal", "Balance", "Crafting"}, moni)
	for idx, row in ipairs(toPrint) do
		Helper.printRowOf(widRatios, backColors[(idx % 2) + 1], textColors[(idx % 2) + 1], row, moni)
	end
end

return St