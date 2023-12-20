local I = require("Dict").Item
local F = require("Dict").Fluid
local Machine = require("Dict").Machine
local MultiblockMachine = require("Dict").MultiblockMachine
local M = require("Dict").MatType

require("__RecipeMaker")
local Helper = require("__Helpers")

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
Recipes:makeMixerDustRecipes {
	{M.lead, M.antimony, M.battery_alloy, 1, 1, 2},
	{M.tin, M.copper, M.bronze, 1, 3, 4},
	{M.copper, M.nickel, M.cupronickel, 1, 1, 2},
	{M.silver, M.gold, M.electrum, 1, 1, 2},
	{M.uranium_238, M.plutonium, M.he_mox, 6, 3, 9},
	{M.uranium_238, M.uranium_235, M.he_uranium, 6, 3, 9},
	{M.iron, M.nickel, M.invar, 2, 1, 3},
	{M.chromium, M.aluminum, M.stainless_steel, M.kanthal, 1, 1, 1, 3},
	{M.uranium_238, M.plutonium, M.le_mox, 8, 1, 9},
	{M.uranium_238, M.uranium_235, M.le_uranium, 8, 1, 9},
	{M.tin, M.lead, M.soldering_alloy, 1, 1, 2},
	{M.chromium, M.iron, M.nickel, M.manganese, M.stainless_steel, 1, 6, 1, 1, 9},
	{M.yttrium, M.annealed_copper, M.neodymium, M.iridium, M.superconductor, 3, 3, 2, 1, 9},
}
-------------------------------------------------
Recipes:new { dispName = "Liquid Ender",
	unitInput = {
		item = {
			[I.ender_pearl_dust] = 2,
		},
		fluid = {
			[F.water] = 800
		}
	},
	unitOutput = {
		fluid = {
			[F.liquid_ender] = 1000
		}
	},
	machineType = Machine.electric_mixer,
	minimumPower = 8
}
-------------------------------------------------
Recipes:new { dispName = "Battery Alloy Dust",
	unitInput = {
		item = {
			[I.lead_dust] = 1,
			[I.antimony_dust] = 1,
		}
	},
	unitOutput = {
		item = {
			[I.battery_alloy_dust] = 2
		}
	},
	machineType = Machine.electric_mixer,
	minimumPower = 8
}
-------------------------------------------------
Recipes:new { dispName = "Raw Biodiesel",
	unitInput = {
		fluid = {
			[F.plant_oil] = 24000,
			[F.ethanol] = 1600,
			[F.sodium_hydroxide] = 400,
		}
	},
	unitOutput = {
		fluid = {
			[F.raw_biodiesel] = 6000
		}
	},
	machineType = MultiblockMachine.chemicalReactorLarge,
	minimumPower = 24
}
-------------------------------------------------
Recipes:new { dispName = "Copper Ingot Mega",
	unitInput = {
		item = {
			[I.copper_dust] = 32
		}
	},
	unitOutput = {
		item = {
			[I.copper_ingot] = 32
		}
	},
	machineType = MultiblockMachine.smelterMega,
	minimumPower = 32
}