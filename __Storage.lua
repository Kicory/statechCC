local DispName = require("Dict").DispName
local DirectProd = require("Dict").DirectProd
local StorageSystems = require("Enviornment")
local Helper = require("__Helpers")
local Ctlg = require("__Catalouge")
local Recipes = require("Recipes")

local St = {
	mainAE = nil,
}

local emptyCtlg = nil
-- Whole item data
local catalogue = nil

local craftingCtlg = Ctlg:new()

local function findStorageSystems()
	St.mainAE = peripheral.wrap(StorageSystems.main)
end
-----------------------------------
function St.init()
	findStorageSystems()
	emptyCtlg = Recipes.getMaterialsUsedEmptyCtlg()
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
---@param availableCtlg table Catalogue
---@param toUse table Materials to use, in unitInput format
---@param limit integer Maximum units to use.
---@return integer count of units successfully used
---@return table Catalogue of lacking materials
function St.tryUse(availableCtlg, stockOffsetCtlg, toUseCtlg, limit)
	assert(limit ~= nil and limit > 0, Helper.serializeTable(toUseCtlg))

	local result = availableCtlg:divWithOffset(toUseCtlg, stockOffsetCtlg)
	result = math.min(limit, result)
	local lacksCtlg = toUseCtlg:copy():inPlaceSub(availableCtlg, Ctlg.IGNORE_NEW_KEY):filter(function(k, v) return v > 0 end)

	if result ~= 0 then
		local used = toUseCtlg * result
		availableCtlg:inPlaceSub(used, Ctlg.ERROR_ON_NEW_KEY)
	end

	return result, lacksCtlg
end

function St.tryUseGeneric(availableCtlg, stockOffset, toUse, limit)
end
-----------------------------------
function St.getRequirements(wholeRecipes, goalsCtlg)
	local requiredCtlg = goalsCtlg - (catalogue + craftingCtlg)
	local craftRequirements = {}

	local function getRequiredUnit(recipe)
		if recipe.alwaysProc then
			return catalogue / Helper.IO2Catalogue(recipe.unitInput)
		else
			return requiredCtlg:divGeneric(recipe.effUnitOutputCtlg, nil, math.ceil)
		end
	end

	for _, recipe in ipairs(wholeRecipes) do
		local unitCount = getRequiredUnit(recipe)
		if unitCount > 0 then
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

function St.printStatusToMonitor(goalsCtlg, lackStatus, machineLackStatus, moni)
	moni.clear()
	moni.setCursorPos(1, 1)

	local backColors = {colors.pink, colors.lightBlue, colors.pink}
	local textColors = {colors.red, colors.black, colors.red}

	local function getDispName(whatever)
		if whatever then
			return DispName[whatever] or Helper.dispNameMaker(whatever)
		else
			return '-'
		end
	end

	local function printIDList(list)
		for idx = 1, #list, 3 do
			local content = {getDispName(list[idx]), getDispName(list[idx + 1]), getDispName(list[idx + 2])}
			Helper.printRowOf({1/3, 1/3, 1/3}, backColors, textColors, content, moni)
		end
	end

	-- Lack raw material (should increase raw material production)
	do
		Helper.printRowOf({1}, {colors.black}, {colors.white}, {"  Lacking Raw Materials"}, moni)
		local dpLacksList = {}
		for id in pairs(DirectProd) do
			if lackStatus[id] then
				dpLacksList[#dpLacksList] = id
			end
		end
		printIDList(dpLacksList)
	end

	-- Lack machine (should enlarge factory)
	do
		Helper.printRowOf({1}, {colors.black}, {colors.white}, {"  Lacking Machines"}, moni)
		local lackingMachineList = {}
		for k, v in pairs(machineLackStatus) do
			if v then
				lackingMachineList[#lackingMachineList + 1] = k
			end
		end
		printIDList(lackingMachineList)
	end

	-- Lack speed (should increase goal)
	do
		Helper.printRowOf({1}, {colors.black}, {colors.white}, {"  Lacking Speed of producing..."}, moni)
		local lackingSpeedList = {}
		for k, v in pairs(lackStatus) do
			if v and craftingCtlg[k] and craftingCtlg[k] >= goalsCtlg[k] * 0.95 then
				lackingSpeedList[#lackingSpeedList + 1] = k
			end
		end
		printIDList(lackingSpeedList)
	end
end

return St