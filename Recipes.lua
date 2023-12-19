require("Dict")
require("__RecipeMaker")
local Helper = require("__Helpers")

local I = Item
local M = MatType

local compBasicRecipeIDs = Helper.makeIDListOver(
	{M.copper, M.bronze, M.iron, M.battery_alloy, M.electrum, M.enderium, M.gold, M.silver, M.steel, M.tin, M.invar, M.lead, M.aluminum, M.beryllium, M.annealed_copper,
	M.cadmium, M.blastproof_alloy, M.chromium, M.cupronickel, M.kanthal, M.nickel, M.platinum, M.stainless_steel, M.polytetrafluoroethylene, M.calorite, M.desh, M.titanium, M.tungsten,
	M.tungstensteel, M.superconductor},
	{"%m_ingot", "%m_double_ingot", "%m_plate", "%m_curved_plate", "%m_rod", "%m_ring"}, I
)
Recipes:makeCompressorRecipesBasic(table.unpack(compBasicRecipeIDs))
Recipes:makeCompressorRecipesCustom(
	I.carbon_dust, I.carbon_plate, 1, 2,
	I.lignite_coal_dust, I.lignite_coal, 1, 2,
	I.iridium_plate, I.iridium_curved_plate, 1, 2,	-- Iridium has unique plate recipe, using implosion_compressor
	I.lapis_lazuli, I.lapis_plate, 1, 2,
	I.diamond, I.diamond_plate, 1, 48,
	I.emerald, I.emerald_plate, 1, 48,
	I.lazurite_dust, I.lazurite_plate, 1, 10
)
-------------------------------------------------
local cutterRodRecipeIDs = Helper.makeIDListOver(
	{M.copper, M.bronze, M.tin, M.iron, M.steel, M.aluminum, M.gold, M.invar, M.stainless_steel, M.enderium, M.calorite, M.desh, M.polytetrafluoroethylene, M.cadmium, M.titanium, M.tungsten, M.tungstensteel, M.uranium, M.he_mox, M.he_uranium, M.le_mox, M.le_uranium},
	{"%m_ingot", "%m_double_ingot", "%m_rod"}, I
)
Recipes:makeCutterRodRecipes(table.unpack(cutterRodRecipeIDs))
-------------------------------------------------
local packerBladeRecipeIDs = Helper.makeIDListOver(
	{M.copper, M.bronze, M.tin, M.aluminum, M.stainless_steel, M.calorite, M.titanium},
	{"%m_curved_plate", "%m_rod", "%m_blade"}, I
)
Recipes:makePackerBladeRecipes(table.unpack(packerBladeRecipeIDs))
-------------------------------------------------
local assemGearRecipeIDs = Helper.makeIDListOver(
	{M.copper, M.bronze, M.iron, M.steel, M.gold, M.aluminum, M.calorite, M.desh, M.enderium, M.invar, M.polytetrafluoroethylene, M.stainless_steel, M.tin, M.titanium, M.tungstensteel},
	{"%m_plate", "%m_ring", "%m_gear"}, I
)
Recipes:makeAssemGearRecipes(table.unpack(assemGearRecipeIDs))
-------------------------------------------------
local assemRotorRecipeIDs = Helper.makeIDListOver(
	{M.bronze, M.copper, M.aluminum, M.stainless_steel, M.tin, M.titanium},
	{"%m_blade", "%m_ring", "%m_rotor"}, I
)
Recipes:makeAssemRotorRecipes(table.unpack(assemRotorRecipeIDs))
-------------------------------------------------
local assemDrillHeadRecipeIDs = Helper.makeIDListOver(
	{M.aluminum, M.bronze, M.copper, M.gold, M.stainless_steel, M.desh, M.steel, M.titanium},
	{"%m_plate", "%m_curved_plate", "%m_rod", "%m_gear", "%m_drill_head"}, I
)
Recipes:makeAssemDrillHeadRecipes(table.unpack(assemDrillHeadRecipeIDs))
-------------------------------------------------
local wiremillRecipeIDs = Helper.makeIDListOver(
	{M.copper, M.silver, M.tin, M.cupronickel, M.electrum, M.aluminum, M.annealed_copper, M.kanthal, M.platinum, M.tungstensteel, M.superconductor},
	{"%m_plate", "%m_wire", "%m_fine_wire"}, I
)
Recipes:makeWiremillRecipes(table.unpack(wiremillRecipeIDs))
-------------------------------------------------
Recipes:new { dispName = "Liquid Ender",
	unitInput = {
		item = {
			[Item.ender_pearl_dust] = 2,
		},
		fluid = {
			[Fluid.water] = 800
		}
	},
	unitOutput = {
		fluid = {
			[Fluid.liquid_ender] = 1000
		}
	},
	machineTypes = {
		Machine.electric_mixer,
	},
	minimumPower = 8
}
---------------
Recipes:new { dispName = "Battery Alloy Dust",
	unitInput = {
		item = {
			[Item.lead_dust] = 1,
			[Item.antimony_dust] = 1,
		}
	},
	unitOutput = {
		item = {
			[Item.battery_alloy_dust] = 2
		}
	},
	machineTypes = {
		Machine.electric_mixer,
	},
	minimumPower = 8
}

Recipes:new { dispName = "Raw Biodiesel",
	unitInput = {
		fluid = {
			[Fluid.plant_oil] = 24000,
			[Fluid.ethanol] = 1600,
			[Fluid.sodium_hydroxide] = 400,
		}
	},
	unitOutput = {
		fluid = {
			[Fluid.raw_biodiesel] = 6000
		}
	},
	machineTypes = {
		MultiblockMachine.chemicalReactorLarge,
	},
	minimumPower = 24
}

Recipes:new { dispName = "Copper Ingot Mega",
	unitInput = {
		item = {
			[Item.copper_dust] = 32
		}
	},
	unitOutput = {
		item = {
			[Item.copper_ingot] = 32
		}
	},
	machineTypes = {
		MultiblockMachine.smelterMega,
	},
	minimumPower = 32
}