local FullDict = require("Dict")
local RecipeMaker = require("__RecipeMaker")
local Helper = require("__Helpers")

local I = FullDict.Item
local F = FullDict.Fluid
local Machine = FullDict.Machine
local MultiblockMachine = FullDict.MultiblockMachine
local M = FullDict.MatType

local Recipes = RecipeMaker.Recipes
local Recipe = RecipeMaker.Recipe

-------------------------------------------------
do -- Make basic compressor recipes (a lot!)
	local ps = Helper.makeIDListOver(
		{M.copper, M.bronze, M.iron, M.battery_alloy, M.electrum, M.enderium, M.gold, M.silver, M.steel, M.tin, M.invar, M.lead, M.aluminum, M.beryllium, M.annealed_copper,
		M.cadmium, M.blastproof_alloy, M.chromium, M.cupronickel, M.kanthal, M.nickel, M.platinum, M.stainless_steel, M.polytetrafluoroethylene, M.calorite, M.desh, M.titanium, M.tungsten,
		M.tungstensteel, M.superconductor},
		{"%m_ingot", "%m_double_ingot", "%m_plate", "%m_curved_plate", "%m_rod", "%m_ring"}, I
	)
	Recipes.makeCompressorRecipesBasic(table.unpack(ps)) 
end
-------------------------------------------------
Recipes.makeCompressorRecipesCustom(
	I.carbon_dust, I.carbon_plate, 1, 2,
	I.lignite_coal_dust, I.lignite_coal, 1, 2,
	I.iridium_plate, I.iridium_curved_plate, 1, 2,	-- Iridium has unique plate recipe, using implosion_compressor
	I.lapis_lazuli, I.lapis_plate, 1, 2,
	I.diamond, I.diamond_plate, 1, 48,
	I.emerald, I.emerald_plate, 1, 48,
	I.lazurite_dust, I.lazurite_plate, 1, 10
)
-------------------------------------------------
do -- Make rod recipes
	local ps = Helper.makeIDListOver(
		{M.copper, M.bronze, M.tin, M.iron, M.steel, M.aluminum, M.gold, M.invar, M.stainless_steel, M.enderium, M.calorite, M.desh, M.polytetrafluoroethylene, M.cadmium, M.titanium, M.tungsten, M.tungstensteel, M.uranium, M.he_mox, M.he_uranium, M.le_mox, M.le_uranium},
		{"%m_ingot", "%m_double_ingot", "%m_rod"}, I
	)
	Recipes.makeCutterRodRecipes(table.unpack(ps))
end
-------------------------------------------------
do -- Make Blade recipes
	local ps = Helper.makeIDListOver(
		{M.copper, M.bronze, M.tin, M.aluminum, M.stainless_steel, M.calorite, M.titanium},
		{"%m_curved_plate", "%m_rod", "%m_blade"}, I
	)
	Recipes.makePackerBladeRecipes(table.unpack(ps))
end
-------------------------------------------------
do -- Make Tiny to Normal Dust recipes
	local ps = Helper.makeIDListOver(
		{M.platinum, M.manganese, M.chromium},
		{"%m_tiny_dust", "%m_dust"}, I
	)
	Recipes.makePackerDustRecipes(table.unpack(ps))
end
-------------------------------------------------
do -- Make Normal to Tiny Dust recipes
	local ps = Helper.makeIDListOver(
		{M.beryllium, M.tungsten, M.nickel, M.lead, M.iridium, M.antimony, M.aluminum},
		{"%m_dust", "%m_tiny_dust"}, I
	)
	Recipes.makeUnpackerTinyDustRecipes(table.unpack(ps))
end
-------------------------------------------------
do -- Make Gear recipes
	local ps = Helper.makeIDListOver(
		{M.copper, M.bronze, M.iron, M.steel, M.gold, M.aluminum, M.calorite, M.desh, M.enderium, M.invar, M.polytetrafluoroethylene, M.stainless_steel, M.tin, M.titanium, M.tungstensteel},
		{"%m_plate", "%m_ring", "%m_gear"}, I
	)
	Recipes.makeAssemGearRecipes(table.unpack(ps))
end
-------------------------------------------------
do -- Make Rotor recipes
	local assemRotorRecipeIDs = Helper.makeIDListOver(
		{M.bronze, M.copper, M.aluminum, M.stainless_steel, M.tin, M.titanium},
		{"%m_blade", "%m_ring", "%m_rotor"}, I
	)
	Recipes.makeAssemRotorRecipes(table.unpack(assemRotorRecipeIDs))
end
-------------------------------------------------
do -- Make Drill Head recipes
	local ps = Helper.makeIDListOver(
		{M.aluminum, M.bronze, M.copper, M.gold, M.stainless_steel, M.desh, M.steel, M.titanium},
		{"%m_plate", "%m_curved_plate", "%m_rod", "%m_gear", "%m_drill_head"}, I
	)
	Recipes.makeAssemDrillHeadRecipes(table.unpack(ps))
end
-------------------------------------------------
do -- Make wiremill recipes
	local ps = Helper.makeIDListOver(
		{M.copper, M.silver, M.tin, M.cupronickel, M.electrum, M.aluminum, M.annealed_copper, M.kanthal, M.platinum, M.tungstensteel, M.superconductor},
		{"%m_plate", "%m_wire", "%m_fine_wire"}, I
	)
	Recipes.makeWiremillRecipes(table.unpack(ps))
end
-------------------------------------------------
-- Mixing dust (alloy) recipes
Recipes.makeMixerDustRecipes {
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
do -- Make other mixing recipes
	local m = Recipes.makeSingleMixerRecipe
	local dm = Helper.dispNameMaker
	m(I.coke_dust, 9, nil, F.water, 900, nil, nil, F.raw_synthetic_oil, 2000, nil, dm(F.raw_synthetic_oil), 2)
	m(I.coke_dust, 1, I.sulfur_dust, 1, nil, nil, I.gunpowder, 2, nil, nil, "Gunpowder from Mixer", 2)
	m(I.redstone, 1, nil, F.creosote, 500, nil, nil, F.lubricant, 500, nil, "Lubricant from Creosote with Mixer", 2)
	m(I.paper, 9, nil, F.synthetic_rubber, 1000, nil, I.rubber_sheet, 12 * 9, nil, nil, "Rubber Sheet from paper and rubber", 2)
	m(I.iron_dust, 7, I.coke_dust, 2, nil, nil, I.uncooked_steel_dust, 9, nil, nil, dm(I.uncooked_steel_dust), 2)
	m(I.sand, 1, nil, F.water, 1000, nil, I.clay, 1, nil, nil, "Clay from Mixer", 2)
	m(I.wood_pulp, 1, nil, F.water, 100, nil, I.paper, 2, nil, nil, "Paper with Mixer", 2)
	m(I.brick_dust, 2, I.clay_dust, 2, nil, nil, I.fire_clay_dust, 4, nil, nil, dm(I.fire_clay_dust), 2)

	m(I.sulfur_dust, 1, nil, F.synthetic_oil, 1000, nil, nil, F.synthetic_rubber, 1000, nil, dm(F.synthetic_rubber), 4)

	m(I.sand, 4, I.flint, 3, nil, F.toluene, 250, F.nitrogen, 1000, nil, I.industrial_tnt, 4, nil, nil, dm(I.industrial_tnt), 16)
	m(I.clay_dust, 16, nil, F.water, 700, F.lubricant, 100, nil, nil, F.drilling_fluid, 1000, nil, dm(F.drilling_fluid), 8)
	m(I.ender_pearl_dust, 2, nil, F.water, 800, nil, nil, F.liquid_ender, 1000, nil, dm(F.liquid_ender), 8)
	m(nil, F.heavy_fuel, 1000, F.light_fuel, 5000, nil, nil, F.diesel, 6000, nil, dm(F.diesel) .. " from Mixer", 8)
	m(nil, F.biodiesel, 2000, F.diethyl_ether, 250, nil, nil, F.boosted_diesel, 1500, nil, dm(F.boosted_diesel) .. " with " .. dm(F.biodiesel), 12)
	m(nil, F.diesel, 1000, F.diethyl_ether, 250, nil, nil, F.boosted_diesel, 1200, nil, dm(F.boosted_diesel), 12)
end
-------------------------------------------------
-- Make smelting recipes
Recipes.makeFurnaceRecipes {
	I.raw_calorite, I.calorite_ingot,
	I.raw_desh, I.desh_ingot,
	I.raw_ostrum, I.ostrum_ingot,
	I.galena_dust, I.lead_ingot,
	I.clay_ball, I.brick,
	I.copper_dust, I.copper_ingot,
	I.sand, I.glass,
	I.gold_dust, I.gold_ingot,
	I.iron_dust, I.iron_ingot,
	I.cobblestone, I.stone,
	I.battery_alloy_dust, I.battery_alloy_ingot,
	I.bronze_dust, I.bronze_ingot,
	I.cadmium_dust, I.cadmium_ingot,
	I.cupronickel_dust, I.cupronickel_ingot,
	I.electrum_dust, I.electrum_ingot,
	I.invar_dust, I.invar_ingot,
	I.iridium_dust, I.iridium_ingot,
	I.nickel_dust, I.nickel_ingot,
	I.silicon_dust, I.silicon_ingot,
	I.silver_dust, I.silver_ingot,
	I.tin_dust, I.tin_ingot,
	I.mixed_metal_ingot, I.advanced_alloy_ingot,
	I.brass_dust, I.brass_ingot,
}
-------------------------------------------------
do -- Centrifuge
	local m = Recipes.makeSingleCentrifugeRecipe
	local cen = ", Centrifuge"
	local from = " from "
	local breakdown = " breakdown"
	local dm = Helper.dispNameMaker
	m(I.coal_dust, 1, nil, nil, I.carbon_dust, 1, nil, nil, "Carbon Dust from Coal Dust", 16)
	m(I.ruby_dust, 6, nil, nil, I.chromium_crushed_dust, 1, I.aluminum_dust, 2, nil, nil,  dm(I.chromium_crushed_dust) .. cen, 16)
	m(nil, F.hydrogen, 1000, nil, nil, F.deuterium, 20, F.tritium, 1, nil, "Deuterium and Tritium from Hydrogen", 32)
	m(I.gravel, 1, nil, nil, I.flint, 2, nil, nil, dm(I.flint) .. from .. dm(I.gravel) .. cen, 8)
	m(nil, F.water, 1000, nil, nil, F.heavy_water, 20, nil, dm(F.heavy_water) .. cen, 32)
	m(nil, F.helium, 1000, nil, nil, F.helium_3, 5, nil, dm(F.helium_3) .. from .. dm(F.helium) .. cen, 32)
	m(nil, F.liquid_air, 3000, nil, nil, F.oxygen, 650, F.nitrogen, 2315, F.argon, 35, nil, dm(F.liquid_air) .. breakdown, 24)
	m(I.raw_iron, 6, nil, nil, I.iron_dust, 8, I.manganese_crushed_dust, 1, nil, nil, dm(I.manganese_crushed_dust), 8)
	m(I.mozanite_dust, 9, nil, nil, I.neodymium_dust, 3, I.yttrium_dust, 3, I.cadmium_dust, 3, nil, nil, dm(I.mozanite_dust) .. breakdown, 10) -- Possible Helium production
	m(I.mozanite_tiny_dust, 9, nil, nil, I.neodymium_tiny_dust, 3, I.yttrium_tiny_dust, 3, I.cadmium_tiny_dust, 3, nil, nil, dm(I.mozanite_tiny_dust) .. breakdown, 10)
	m(I.he_mox_fuel_rod_depleted, 1, nil, nil, I.uranium_238_tiny_dust, 36, I.plutonium_tiny_dust, 36, nil, nil, dm(I.he_mox_fuel_rod_depleted) .. breakdown, 32)
	m(I.he_uranium_fuel_rod_depleted, 1, nil, nil, I.uranium_238_tiny_dust, 36, I.plutonium_tiny_dust, 18, I.uranium_235_tiny_dust, 18, nil, nil, dm(I.he_uranium_fuel_rod_depleted) .. breakdown, 32)
	m(I.le_mox_fuel_rod_depleted, 1, nil, nil, I.uranium_238_tiny_dust, 48, I.plutonium_tiny_dust, 30, nil, nil, dm(I.le_mox_fuel_rod_depleted) .. breakdown, 32)
	m(I.le_uranium_fuel_rod_depleted, 1, nil, nil, I.uranium_238_tiny_dust, 48, I.plutonium_tiny_dust, 24, I.uranium_235_tiny_dust, 6, nil, nil, dm(I.le_uranium_fuel_rod_depleted) .. breakdown, 32)
	m(I.uranium_fuel_rod_depleted, 1, nil, nil, I.uranium_238_tiny_dust, 53, I.plutonium_tiny_dust, 27, nil, nil, dm(I.uranium_fuel_rod_depleted), 32)
	m(nil, F.platinum_sulfuric_solution, 1000, nil, nil, F.purified_platinum_sulfuric_solution, 1000, nil, dm(F.purified_platinum_sulfuric_solution), 8)
	m(I.redstone, 10, nil, nil, I.iron_dust, 5, I.ruby_dust, 1, I.quartz_dust, 1, nil, nil, dm(I.redstone) .. breakdown, 8):setPriority(Recipe.PRIO_RELUCTANT) -- Redstone Dust is useful...
	m(I.uranium_dust, 9, nil, nil, I.uranium_235_tiny_dust, 1, I.uranium_238_tiny_dust, 80, nil, nil, dm(I.uranium_dust) .. breakdown, 64):setPriority(Recipe.PRIO_RELUCTANT) -- Too much energy
end
-------------------------------------------------
do -- Macerator
	local m = Recipes.makeSingleMaceratorRecipe
	local mac = ", Macerator"
	local from = " from "
	local grinded = " grinded"
	local dm = Helper.dispNameMaker
	m(I.galena_ore, 1, nil, I.galena_dust, 2, nil, dm(I.galena_dust), 2)
	m(I.peridot_ore, 1, nil, I.peridot_dust, 2, nil, dm(I.peridot_dust), 2)
	m(I.ruby_ore, 1, nil, I.ruby_dust, 2, nil, dm(I.ruby_dust) .. mac, 2)
	m(I.sapphire_ore, 1, nil, I.sapphire_dust, 2, nil, dm(I.sapphire_dust) .. mac, 2)
	m(I.silver_ore, 1, nil, I.raw_silver, 2, nil, dm(I.silver_ore) .. grinded, 2)
	m(I.raw_silver, 1, nil, I.silver_dust, 1, nil, dm(I.raw_silver) .. grinded, 2)
	m(I.sodalite_ore, 1, nil, I.sodalite_dust, 2, nil, dm(I.sodalite_dust) .. mac, 2)
	m(I.ender_pearl, 1, nil, I.ender_pearl_dust, 1, nil, dm(I.ender_pearl_dust) .. mac, 2)
	m(I.annealed_copper_ingot, 1, nil, I.annealed_copper_dust, 1, nil, dm(I.annealed_copper_dust) .. mac, 2)
	m(I.antimony_ore, 1, nil, I.raw_antimony, 3, nil, dm(I.raw_antimony) .. mac, 2)
	m(I.raw_antimony, 1, nil, I.antimony_dust, 1, nil, dm(I.antimony_dust) .. mac, 2)
	m(I.bauxite_ore, 1, nil, I.bauxite_crushed_dust, 3, nil, dm(I.bauxite_ore) .. grinded, 2)
	m(I.bauxite_crushed_dust, 1, nil, I.bauxite_dust, 1, nil, dm(I.bauxite_crushed_dust) .. grinded, 2)
	m(I.clay_ball, 1, nil, I.clay_dust, 1, nil, dm(I.clay_ball) .. grinded, 2)
	m(I.coal_ore, 1, nil, I.coal_crushed_dust, 3, nil, dm(I.coal_ore) .. grinded, 2)
	m(I.coal, 1, nil, I.coal_dust, 1, nil, dm(I.coal) .. grinded, 2):setPriority(Recipe.PRIO_HIGH)
	m(I.coal_crushed_dust, 1, nil, I.coal_dust, 1, nil, dm(I.coal_crushed_dust) .. grinded, 2):setPriority(Recipe.PRIO_LOW)
	m(I.raw_copper, 1, nil, I.copper_dust, 1, nil, dm(I.raw_copper) .. grinded, 2)
	m(I.diamond_crushed_dust, 1, nil, I.diamond_dust, 1, nil, dm(I.diamond_crushed_dust) .. grinded, 2)
	m(I.diamond_ore, 1, nil, I.diamond_crushed_dust, 3, nil, dm(I.diamond_ore) .. grinded, 2)
	m(I.emerald_crushed_dust, 1, nil, I.emerald_dust, 1, nil, dm(I.emerald_crushed_dust) .. grinded, 2)
	m(I.emerald_ore, 1, nil, I.emerald_crushed_dust, 3, nil, dm(I.emerald_crushed_dust) .. grinded, 2)
	m(I.fluorite_ore, 1, nil, I.raw_fluorite, 3, nil, dm(I.fluorite_ore) .. grinded, 2)
	m(I.raw_fluorite, 1, nil, I.fluorite_dust, 1, nil, dm(I.raw_fluorite) .. grinded, 2)
	m(I.nether_gold_ore, 1, nil, I.raw_gold, 3, nil, dm(I.nether_gold_ore) .. grinded, 2):setPriority(Recipe.PRIO_HIGH) -- nether ones would be less. Less ones first.
	m(I.gold_ore, 1, nil, I.raw_gold, 3, nil, dm(I.gold_ore) .. grinded, 2):setPriority(Recipe.PRIO_LOW)
	m(I.raw_gold, 1, nil, I.gold_dust, 1, nil, dm(I.raw_gold) .. grinded, 2)
	m(I.iridium_ore, 1, nil, I.raw_iridium, 3, nil, dm(I.iridium_ore) .. grinded, 2)
	m(I.raw_iridium, 1, nil, I.iridium_dust, 1, nil, dm(I.raw_iridium) .. grinded, 2)
	m(I.iron_ore, 1, nil, I.raw_iron, 3, nil, dm(I.iron_ore) .. grinded, 2)
	m(I.raw_iron, 1, nil, I.iron_dust, 1, nil, dm(I.raw_iron) .. grinded, 2):setPriority(Recipe.PRIO_HIGH)
	m(I.lapis_crushed_dust, 1, nil, I.lapis_dust, 1, nil, dm(I.lapis_crushed_dust) .. grinded, 2)
	m(I.lapis_ore, 1, nil, I.lapis_crushed_dust, 16, nil, dm(I.lapis_ore) .. grinded, 2)
	m(I.lead_ore, 1, nil, I.raw_lead, 3, nil, dm(I.lead_ore) .. grinded, 2)
	m(I.raw_lead, 1, nil, I.lead_dust, 1, nil, dm(I.raw_lead) .. grinded, 2)
	m(I.lignite_coal_crushed_dust, 1, nil, I.lignite_coal_dust, 1, nil, dm(I.lignite_coal_crushed_dust) .. grinded, 2)
	m(I.nether_quartz_ore, 1, nil, I.quartz_crushed_dust, 4, nil, dm(I.nether_quartz_ore) .. grinded, 2):setPriority(Recipe.PRIO_HIGH) -- nether ones would be less. Less ones first.
	m(I.quartz_ore, 1, nil, I.quartz_crushed_dust, 4, nil, dm(I.quartz_ore) .. grinded, 2):setPriority(Recipe.PRIO_LOW)
	m(I.quartz_crushed_dust, 1, nil, I.quartz_dust, 1, nil, dm(I.quartz_crushed_dust) .. grinded, 2)
	m(I.redstone_ore, 1, nil, I.redstone_crushed_dust, 6, nil, dm(I.redstone_ore) .. grinded, 2)
	m(I.redstone_crushed_dust, 1, nil, I.redstone, 1, nil, dm(I.redstone_crushed_dust) .. grinded, 2)
	print("Wood to wood pulp recipe is missing")
	m(I.mozanite_crushed_dust, 1, nil, I.mozanite_dust, 1, nil, dm(I.mozanite_crushed_dust) .. grinded, 2)
	m(I.mozanite_ore, 1, nil, I.mozanite_crushed_dust, 3, nil, dm(I.mozanite_ore) .. grinded, 2)
	m(I.nickel_ore, 1, nil, I.raw_nickel, 3, nil, dm(I.nickel_ore) .. grinded, 2)
	m(I.raw_nickel, 1, nil, I.nickel_dust, 1, nil, dm(I.raw_nickel) .. grinded, 2)
	m(I.platinum_ore, 1, nil, I.raw_platinum, 3, nil, dm(I.platinum_ore) .. grinded, 2)
	m(I.salt_ore, 1, nil, I.salt_crushed_dust, 3, nil, dm(I.salt_ore) .. grinded, 2)
	m(I.salt_crushed_dust, 1, nil, I.salt_dust, 1, nil, dm(I.salt_crushed_dust) .. grinded, 2)
	m(I.steel_ingot, 1, nil, I.steel_dust, 1, nil, dm(I.steel_dust) .. from .. dm(I.steel_ingot), 2)
	m(I.tin_ore, 1, nil, I.raw_tin, 3, nil, dm(I.tin_ore) .. grinded, 2)
	m(I.raw_tin, 1, nil, I.tin_dust, 1, nil, dm(I.raw_tin) .. grinded, 2)
	m(I.titanium_ore, 1, nil, I.raw_titanium, 3, nil, dm(I.titanium_ore) .. grinded, 2)
	m(I.tungsten_ore, 1, nil, I.raw_tungsten, 3, nil, dm(I.tungsten_ore) .. grinded, 2)
	m(I.raw_tungsten, 1, nil, I.tungsten_dust, 1, nil, dm(I.raw_tungsten) .. grinded, 2)
	m(I.uranium_ore, 1, nil, I.raw_uranium, 3, nil, dm(I.uranium_ore) .. grinded, 2)
	m(I.raw_uranium, 1, nil, I.uranium_dust, 1, nil, dm(I.raw_uranium) .. grinded, 2)
	m(I.sheldonite_ore, 1, nil, I.raw_platinum, 3, nil, dm(I.sheldonite_ore) .. grinded, 2):setPriority(Recipe.PRIO_HIGH) -- Higher for scarce material
	m(I.clay, 1, nil, I.clay_ball, 4, nil, dm(I.clay) .. grinded, 2)
	m(I.gravel, 1, nil, I.sand, 1, nil, dm(I.sand) .. from .. dm(I.gravel) .. mac, 2)
end
-------------------------------------------------
do -- Electronizer
	local m = Recipes.makeSingleElectrolyzerRecipe
	local ele = ", Electrolyzer"
	local from = " from "
	local eleced = " electrolized"
	local dm = Helper.dispNameMaker
	m(I.bauxite_dust, 10, nil, nil, I.aluminum_dust, 4, I.titanium_tiny_dust, 3, nil, nil, dm(I.aluminum_dust) .. from .. dm(I.bauxite_dust), 32):setPriority(Recipe.PRIO_LOW) -- Main method for aluminum dust
	m(I.emerald_dust, 23, nil, nil, I.beryllium_dust, 3, I.aluminum_dust, 2, I.silicon_dust, 6, nil, F.oxygen, 3000, nil, dm(I.emerald_dust) .. eleced, 32):setPriority(Recipe.PRIO_HIGH)
	m(nil, F.chromium_hydrochloric_solution, 1000, nil, I.chromium_tiny_dust, 3, nil, F.hydrogen, 450, F.chlorine, 450, nil, dm(I.chromium_tiny_dust) .. ele, 16)
	m(nil, F.heavy_water, 3000, nil, nil, F.deuterium, 2000, F.oxygen, 1000, nil, dm(F.heavy_water) .. eleced, 8)
	m(I.lapis_dust, 18, nil, nil, I.aluminum_dust, 3, I.sodium_dust, 2, I.silicon_dust, 1, nil, nil, dm(I.lapis_dust) .. eleced, 32)
	m(nil, F.manganese_sulfuric_solution, 1000, nil, I.manganese_tiny_dust, 3, nil, F.sulfuric_acid, 900, nil, dm(I.manganese_tiny_dust) .. ele, 16)
	m(nil, F.purified_platinum_sulfuric_solution, 1000, nil, I.platinum_tiny_dust, 3, nil, F.sulfuric_acid, 900, nil, dm(I.platinum_tiny_dust) .. ele, 32)
	m(nil, F.water, 3000, nil, nil, F.hydrogen, 2000, F.oxygen, 1000, nil, dm(F.water) .. eleced, 8):setPriority(Recipe.PRIO_HIGH)
	m(nil, F.brine, 8000, nil, nil, F.chlorine, 2000, F.hydrogen, 2000, F.sodium_hydroxide, 3000, F.lithium, 1000, nil, dm(F.brine) .. eleced, 32):setPriority(Recipe.PRIO_HIGH) -- Brine is easy to get
	-- m(nil, F.chloroform, 1000, nil, nil, F.hydrogen, 300, F.chlorine, 600, nil, dm(F.chloroform) .. eleced, 16):setPriority(Recipe.PRIO_RELUCTANT) -- chloroform is scarce resource..
	m(I.clay_dust, 32, nil, nil, I.aluminum_dust, 1, I.sodium_dust, 2, I.silicon_dust, 1, nil, F.lithium, 1000, nil, dm(I.clay_dust) .. eleced, 32):setPriority(Recipe.PRIO_LOW) -- Too much energy, low retrieve
	-- m(nil, F.hydrochloric_acid, 1000, nil, nil, F.hydrogen, 500, F.chlorine, 500, nil, dm(F.hydrochloric_acid) .. eleced, 16):setPriority(Recipe.PRIO_RELUCTANT) -- hydrochloric_acid is scarce resource..
	m(I.peridot_dust, 9, nil, nil, I.magnesium_dust, 2, I.raw_iron, 2, I.silicon_dust, 1, nil, F.oxygen, 100, nil, dm(I.peridot_dust) .. eleced, 16):setPriority(Recipe.PRIO_HIGH) -- Peridot dust's only usage
	m(I.salt_dust, 2, nil, F.water, 100, nil, I.sodium_dust, 1, nil, F.chlorine, 125, nil, dm(I.sodium_dust) .. from .. dm(I.salt_dust), 16)
	m(I.sapphire_dust, 8, nil, nil, I.aluminum_dust, 2, nil, nil, dm(I.sapphire_dust) .. eleced, 16):setPriority(Recipe.PRIO_HIGH) -- sapphire Dust's only usage
	m(I.sodalite_dust, 23, nil, nil, I.aluminum_dust, 3, I.sodium_dust, 4, I.silicon_dust, 3, nil, nil, dm(I.sodalite_dust) .. eleced, 16):setPriority(Recipe.PRIO_HIGH) -- sodalite_dust's only usage
end
-------------------------------------------------
Recipes.add { dispName = "Raw Biodiesel",
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
local function recipeSort(a, b)
	if a.priority > b.priority then
		return true
	elseif a.priority < b.priority then
		return false
	elseif a.rank < b.rank then
		return true
	elseif a.rank > b.rank then
		return false
	end
	assert(false, a.dispName .. " has same rank with " .. b.dispName)
end

table.sort(Recipes, recipeSort)

return Recipes