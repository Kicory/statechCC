local Machine = require("Dict").Machine
local MultiMachine = require("Dict").MultiblockMachine
local Item = require("Dict").Item
local Fluid = require("Dict").Fluid
local Helper = require("__Helpers")
local Ctlg = require("__Catalouge")
local Recipe = require("__RecipeObjects").Recipe
local RecipeList = require("__RecipeObjects").RecipeList

local Recipes = {}

local function basePowerChecker(basePowerRequired)
	return function (machineInfo) return machineInfo.getBasePower() >= basePowerRequired end
end

local function doSingleIO(ps, tab, idx, multiplier)
	multiplier = multiplier or 1
	while(ps[idx]) do
		assert(ps[idx] and ps[idx + 1], debug.traceback())
		tab[ps[idx]] = ps[idx + 1] * multiplier
		idx = idx + 2
	end
	return idx + 1
end

local function getRecipeTemplate(mt)
	return {
		machineType = mt,
		unitInput = {
			item = {},
			fluid = {}
		},
		unitOutput = {
			item = {},
			fluid = {}
		}
	}
end

--- Add to Recipes list
---@param specs table Recipe info
---@return table Added Recipe (Can be customized)
function Recipes.add(specs)
	if (not specs.dispName) or (type(specs.dispName) ~= "string") then error("Recipe Display Name not specified!:" .. debug.traceback()) end

	local dispName = specs.dispName

	if not specs.unitInput then error("No input for recipe: " .. dispName) end
	if not specs.unitOutput then error("No output for recipe: " .. dispName) end
	if not specs.machineType then error("No machine type specified for recipe: " .. dispName) end
	if not specs.minimumPower then error("No machine minimum power requirement: " .. dispName) end

	local order = #Recipes + 1
	local r = Recipe:new {
		-- Lower comes first
		rank = order,
		priority = Recipe.PRIO_NORMAL,
		dispName = specs.dispName,
		-- 
		unitInput = specs.unitInput,
		unitOutput = specs.unitOutput,
		machineType = specs.machineType,
		minimumPower = specs.minimumPower,
		-- Inputs expected to used when conducting 1 unit of this recipe
		-- This is same with base unitInput most of the time.
		-- But if this recipe is the head of process chain, then this ctlg should contain all inputs required to finish the chain.
		effUnitInputCtlg = Helper.IO2Catalogue(specs.unitInput),
		-- Outputs considered as result of this recipe when calculating required crafting.
		-- e.g., hydrogen output from butadiene production should not considered as hydrogen production method.
		effUnitOutputCtlg = Helper.IO2Catalogue(specs.unitOutput),
		-- Schedule if there is input material.
		alwaysProc = false,
		-- Not used for goal maker calculation (only craft when resource is available)
		opportunistic = false,
		paddingCtlg = Ctlg:new(),
	}
	Recipes[order] = r

	-- Return r to customize later
	return r
end

--- Make single recipe maker
---@param mt string Machine type
---@param itemIn boolean
---@param fluidIn boolean
---@param itemOut boolean
---@param fluidOut boolean
function Recipes.makeSingleRecipeMaker(mt, itemIn, fluidIn, itemOut, fluidOut)
	assert(mt ~= nil and itemIn ~= nil and fluidIn ~= nil and itemOut	~= nil and fluidOut ~= nil)
	
	return function(...)
		local ps = table.pack(...)
		local r = getRecipeTemplate(mt)
	
		local idx = 1
		local firstItemOutIdx = nil
		if itemIn then
			idx = doSingleIO(ps, r.unitInput.item, idx)
		end
		if fluidIn then
			idx = doSingleIO(ps, r.unitInput.fluid, idx)
		end
		if itemOut then
			firstItemOutIdx = idx
			idx = doSingleIO(ps, r.unitOutput.item, idx)
		end
		if fluidOut then
			idx = doSingleIO(ps, r.unitOutput.fluid, idx)
		end
		r.dispName = ps[idx] or Helper.dispNameMaker(ps[firstItemOutIdx])
		idx = idx + 1
		r.minimumPower = ps[idx]
		return Recipes.add(r)
	end
end

function Recipes.makeChainRecipeMaker(mt, itemIn, fluidIn)
	return function(...)
		local single = Recipes.makeSingleRecipeMaker(mt, itemIn, fluidIn, false, false)
		return single(...):setAlwaysProc()
	end
end
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--- Make basic compressor recipes. [ingot ID, double ingot ID, plate ID, curved plate ID, rod ID, ring ID]. Give "false" if there is no corresponding item.
function Recipes.makeCompressorRecipesBasic(...)
	local ps = table.pack(...)
	local m = Recipes.makeSingleRecipeMaker(Machine.electric_compressor, true, false, true, false)
	local function addOne(inputID, outputID, outputCnt, dispNamePostfix)
		return m(inputID, 1, nil, outputID, outputCnt, nil, Helper.dispNameMaker(outputID) .. dispNamePostfix, 2)
	end
	for idx = 1, #ps, 6 do
		local ingotID = ps[idx]
		local doubleIngotID = ps[idx + 1]
		local plateID = ps[idx + 2]
		local curvedPlateID = ps[idx + 3]
		local rodID = ps[idx + 4]
		local ringID = ps[idx + 5]
		
		if doubleIngotID and plateID then
			addOne(doubleIngotID, plateID, 2, " from Double"):setOpportunistic()
		end
		if ingotID and plateID then
			addOne(ingotID, plateID, 1, "")
		end
		if plateID and curvedPlateID then
			addOne(plateID, curvedPlateID, 1, "")
		end
		if rodID and ringID then
			addOne(rodID, ringID, 1, "")
		end
	end
end

--- Make rod recipes. [single Ingot ID, double ingot ID (if there's no double ingot, give false or nil; anything evaluated to 'false'), rod ID]
function Recipes.makeCutterRodRecipes(...)
	local m = Recipes.makeSingleRecipeMaker(Machine.electric_cutting_machine, true, true, true, false)
	local function addOne(fromID, toID, toAmt, dispName)
		return m(fromID, 1, nil, Fluid.lubricant, 10, nil, toID, toAmt, nil, dispName, 2)
	end
	local ps = table.pack(...)
	for idx = 1, #ps, 3 do
		local fromID = ps[idx]
		local fromDoubleID = ps[idx + 1]
		local toID = ps[idx + 2]
		if fromDoubleID then
			addOne(fromDoubleID, toID, 4, Helper.dispNameMaker(toID) .. " from Double"):setOpportunistic()
		end
		if fromID then
			addOne(fromID, toID, 2, Helper.dispNameMaker(toID))
		end
	end
end

--- Make blade recipes. [Curved plate ID, rod ID, blade ID]
function Recipes.makePackerBladeRecipes(...)
	local ps = table.pack(...)
	local m = Recipes.makeSingleRecipeMaker(Machine.electric_packer, true, false, true, false)
	for idx = 1, #ps, 3 do
		local curvedID = ps[idx]
		local rodID = ps[idx + 1]
		local bladeID = ps[idx + 2]
		m(curvedID, 2, rodID, 1, nil, bladeID, 4, nil, Helper.dispNameMaker(bladeID), 2)
	end
end

--- Make tiny dust to big dust recipes (only needed ones) [tinyDustID, dustID]
function Recipes.makePackerDustRecipes(...)
	local ps = table.pack(...)
	local m = Recipes.makeSingleRecipeMaker(Machine.electric_packer, true, false, true, false)
	for idx = 1, #ps, 2 do
		local tinyDustID = ps[idx]
		local dustID = ps[idx + 1]
		m(tinyDustID, 9, nil, dustID, 1, nil, Helper.dispNameMaker(dustID) .. " from tiny", 2)
	end
end

-- Make big dust to tiny dust recipes (only needed ones) [dustID, tinyDustID]
function Recipes.makeUnpackerTinyDustRecipes(...)
	local ps = table.pack(...)
	local m = Recipes.makeSingleRecipeMaker(Machine.electric_unpacker, true, false, true, false)
	for idx = 1, #ps, 2 do
		local dustID = ps[idx]
		local tinyDustID = ps[idx + 1]
		m(dustID, 1, nil, tinyDustID, 9, nil, Helper.dispNameMaker(tinyDustID) .. " from big", 2)
	end
end

--- Make blade recipes. [plate ID, ring ID, gear ID]
function Recipes.makeAssemGearRecipes(...)
	local ps = table.pack(...)
	local m = Recipes.makeSingleRecipeMaker(Machine.assembler, true, true, true, false)
	for idx = 1, #ps, 3 do
		local plateID = ps[idx]
		local ringID = ps[idx + 1]
		local gearID = ps[idx + 2]
		m(plateID, 4, ringID, 1, nil, Fluid.soldering_alloy, 100, nil, gearID, 2, nil, Helper.dispNameMaker(gearID), 2)
	end
end

--- Make drill head recipes. [plate ID, curved plate ID, rod ID, gear ID, drill head ID]
function Recipes.makeAssemDrillHeadRecipes(...)
	local ps = table.pack(...)
	local m = Recipes.makeSingleRecipeMaker(Machine.assembler, true, true, true, false)
	for idx = 1, #ps, 5 do
		local plateID = ps[idx]
		local curvedID = ps[idx + 1]
		local rodID = ps[idx + 2]
		local gearID = ps[idx + 3]
		local dhID = ps[idx + 4]
		m(plateID, 1, curvedID, 2, rodID, 1, gearID, 2, nil, Fluid.soldering_alloy, 75, nil, dhID, 1, nil, Helper.dispNameMaker(dhID), 2)
	end
end

--- Make rotor recipes. [Blade ID, ring ID, rotor ID]
function Recipes.makeAssemRotorRecipes(...)
	local ps = table.pack(...)
	local m = Recipes.makeSingleRecipeMaker(Machine.assembler, true, true, true, false)
	for idx = 1, #ps, 3 do
		local bladeID = ps[idx]
		local ringID = ps[idx + 1]
		local rotorID = ps[idx + 2]
		m(bladeID, 4, ringID, 1, nil, Fluid.soldering_alloy, 100, nil, rotorID, 1, nil, Helper.dispNameMaker(rotorID), 2)
	end
end

--- Make rotor recipes. [wireID, cableID]
function Recipes.makeAssemCableRecipes(...)
	local ps = table.pack(...)
	local m = Recipes.makeSingleRecipeMaker(Machine.assembler, true, true, true, false)
	for idx = 1, #ps, 2 do
		local wireID = ps[idx]
		local cableID = ps[idx + 1]
		m(wireID, 3, nil, Fluid.styrene_butadiene_rubber, 6, nil, cableID, 3, nil, Helper.dispNameMaker(cableID) .. " butadiene", 2):setOpportunistic():setPriority(Recipe.PRIO_LOW)
		m(wireID, 3, nil, Fluid.synthetic_rubber, 30, nil, cableID, 3, nil, Helper.dispNameMaker(cableID) .. " normal rubber", 2):setPriority(Recipe.PRIO_RELUCTANT) -- Consumes too much coal dust...
	end
end

--- Make wiremill recipes. [plate ID, wire ID, fineWire ID (if there is no finewire, give false or nil; anything evaluated to 'false')]
function Recipes.makeWiremillRecipes(...)
	local ps = table.pack(...)
	local m = Recipes.makeSingleRecipeMaker(Machine.electric_wiremill, true, false, true, false)
	for idx = 1, #ps, 3 do
		local plateID = ps[idx]
		local wireID = ps[idx + 1]
		local fineWireID = ps[idx + 2]
		if wireID then
			m(plateID, 1, nil, wireID, 2, nil, Helper.dispNameMaker(wireID), 2)
		end
		if wireID and fineWireID then
			m(wireID, 1, nil, fineWireID, 4, nil, Helper.dispNameMaker(fineWireID), 2)
		end
	end
end

function Recipes.makeMixerDustRecipes(ps)
	local function dtmaker(mats, amts)
		local inputs = {
			item = {}
		}
		local outputs = {
			item = {}
		}
		local dustTml = "%m_dust"
		local ig = Helper.getIdOf

		for idx = 1, #mats - 1 do
			inputs.item[ig(mats[idx], dustTml, Item)] = amts[idx]
		end
		local name = ig(mats[#mats], dustTml, Item)

		outputs.item[name] = amts[#mats]

		name = Helper.dispNameMaker(name)

		return inputs, outputs, name
	end

	local function addOne(inputs, outputs, name)
		Recipes.add {
			dispName = name .. " from Mixer",
			unitInput = inputs,
			unitOutput = outputs,
			machineType = Machine.electric_mixer,
			minimumPower = 2,
		}
	end

	for _, ing in pairs(ps) do
		local mats, amts
		mats = {table.unpack(ing, 1, #ing / 2)}
		amts = {table.unpack(ing, (#ing / 2) + 1)}
		local i, o, n = dtmaker(mats, amts)
		addOne(i, o, n)
		-- addOne(ti, to, tn) -- Tiny dust mixing recipes are inefficient, and not mandatory.
	end
end

--- Make furnace and mega-smelter recipe
--- Only requires inputID and outputID (number and required minimum energy is always same)
function Recipes.makeFurnaceRecipes(ps)
	local mm = Recipes.makeSingleRecipeMaker(MultiMachine.smelterMega, true, false, true, false)
	local ms = Recipes.makeSingleRecipeMaker(Machine.electric_furnace, true, false, true, false)
	for idx = 1, #ps, 2 do
		local toSmeltID = ps[idx]
		local resultID = ps[idx + 1]
		mm(toSmeltID, 32, nil, resultID, 32, nil, "Mega-smelt " .. Helper.dispNameMaker(toSmeltID), 16)
		ms(toSmeltID, 1, nil, resultID, 1, nil, "Smelt " .. Helper.dispNameMaker(toSmeltID), 2)
	end
end

--- Make both single/large recipes. [ID], [amt], [ID], [amt], nil, [ID], [amt], ...
--- [Item inputs], nil, [Fluid Inputs], nil, [Item outputs], nil, [Fluid outputs], nil, [DispName], [minimum Power]
--- @return	table Added recipe (single)
--- @return table Added recipe (large)
function Recipes.makeSingleChemicalReactorRecipe(...)
	local ps = table.pack(...)
	local rBig = getRecipeTemplate(MultiMachine.chemicalReactorLarge)
	local r = getRecipeTemplate(Machine.chemical_reactor)

	local idxBig = 1
	idxBig = doSingleIO(ps, rBig.unitInput.item, idxBig, 4)
	idxBig = doSingleIO(ps, rBig.unitInput.fluid, idxBig, 4)
	idxBig = doSingleIO(ps, rBig.unitOutput.item, idxBig, 4)
	idxBig = doSingleIO(ps, rBig.unitOutput.fluid, idxBig, 4)
	rBig.dispName = ps[idxBig] .. " Big"
	idxBig = idxBig + 1
	rBig.minimumPower = ps[idxBig] * 2
	local bigRecipe = Recipes.add(rBig)
	function bigRecipe:setChainHead(otherChainInputCtlg)
		getmetatable(self).__index.setChainHead(self, otherChainInputCtlg * 4)
	end
	
	local idx = 1
	idx = doSingleIO(ps, r.unitInput.item, idx)
	idx = doSingleIO(ps, r.unitInput.fluid, idx)
	idx = doSingleIO(ps, r.unitOutput.item, idx)
	idx = doSingleIO(ps, r.unitOutput.fluid, idx)
	r.dispName = ps[idx]
	idx = idx + 1
	r.minimumPower = ps[idx]
	local singleRecipe = Recipes.add(r)
	
	local ret = RecipeList:new({singleRecipe, bigRecipe})
	return ret
end
-------------------------------------------------------------
function Recipes.getMaterialsUsedEmptyCtlg()
	local ret = Ctlg:new()
	for _, r in ipairs(Recipes) do
		for id, _ in pairs(r.unitInput.item or {}) do
			ret[id] = 0
		end
		for id, _ in pairs(r.unitInput.fluid or {}) do
			ret[id] = 0
		end
		for id, _ in pairs(r.unitOutput.item or {}) do
			ret[id] = 0
		end
		for id, _ in pairs(r.unitOutput.fluid or {}) do
			ret[id] = 0
		end
	end
	return ret
end

return Recipes