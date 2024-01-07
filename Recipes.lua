local FullDict = require("Dict")
local Recipe = require("__RecipeObjects").Recipe
local RecipeList = require("__RecipeObjects").RecipeList
local Helper = require("__Helpers")
local Recipes = require("__RecipeMaker")
local Ctlg = require("__Catalouge")

local I = FullDict.Item
local F = FullDict.Fluid
local Machine = FullDict.Machine
local MultiblockMachine = FullDict.MultiblockMachine
local CustomMachine = FullDict.CustomMachine
local M = FullDict.MatType


-------------------------------------------------
do -- Make basic compressor recipes (a lot!)
	local ps = Helper.makeIDListOver(
		{M.copper, M.bronze, M.iron, M.battery_alloy, M.electrum, M.enderium, M.gold, M.silver, M.steel, M.tin, M.invar, M.lead, M.aluminum, M.beryllium, M.annealed_copper,
		M.cadmium, M.blastproof_alloy, M.chromium, M.cupronickel, M.kanthal, M.nickel, M.platinum, M.stainless_steel, M.polytetrafluoroethylene, M.calorite, M.desh, M.titanium, M.tungsten,
		M.tungstensteel, M.superconductor, M.silicon},
		{"%m_ingot", "%m_double_ingot", "%m_plate", "%m_curved_plate", "%m_rod", "%m_ring"}, I
	)
	Recipes.makeCompressorRecipesBasic(table.unpack(ps))
end
-------------------------------------------------
do -- Make other compressor recipes
	local m = Recipes.makeSingleRecipeMaker(Machine.electric_compressor, true, false, true, false)
	local dm = Helper.dispNameMaker
	m(I.carbon_dust, 1, nil, I.carbon_plate, 1, nil, nil, 2)
	m(I.lignite_coal_dust, 1, nil, I.lignite_coal, 1, nil, nil, 2):setAlwaysProc()
	m(I.iridium_plate, 1, nil, I.iridium_curved_plate, 1, nil, nil, 2)
	m(I.lapis_lazuli, 1, nil, I.lapis_plate, 1, nil, nil, 2)
	m(I.diamond, 1, nil, I.diamond_plate, 1, nil, nil, 48)
	m(I.emerald, 1, nil, I.emerald_plate, 1, nil, nil, 48)
	m(I.lazurite_dust, 1, nil, I.lazurite_plate, 1, nil, nil, 10)
	m(I.glass, 1, nil, I.glass_bottle, 2, nil, nil, 2)
end
-------------------------------------------------
do -- Make rod recipes
	local ps = Helper.makeIDListOver(
		{M.copper, M.bronze, M.tin, M.iron, M.steel, M.aluminum, M.gold, M.invar, M.stainless_steel, M.enderium, M.calorite, M.desh, M.polytetrafluoroethylene, M.cadmium, M.titanium, M.tungsten, M.tungstensteel, M.uranium, M.he_mox, M.he_uranium, M.le_mox, M.le_uranium},
		{"%m_ingot", "%m_double_ingot", "%m_rod"}, I
	)
	Recipes.makeCutterRodRecipes(table.unpack(ps))
end
-------------------------------------------------
do -- Make other cutter recipes
	local m = Recipes.makeSingleRecipeMaker(Machine.electric_cutting_machine, true, true, true, false)
	local dm = Helper.dispNameMaker
	m(I.monocrystalline_silicon, 1, nil, F.lubricant, 500, nil, I.silicon_wafer, 32, nil, dm(I.silicon_wafer), 16)
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
do -- Make Cable recipes
	local ps = Helper.makeIDListOver(
		{M.aluminum, M.annealed_copper, M.copper, M.cupronickel, M.electrum, M.kanthal, M.platinum, M.silver, M.tin, M.tungstensteel},
		{"%m_wire", "%m_cable"}, I
	)
	Recipes.makeAssemCableRecipes(table.unpack(ps))
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
do -- Make other mixer recipes
	local m = Recipes.makeSingleRecipeMaker(Machine.electric_mixer, true, true, true, true)
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
	m(I.sugar, 8, nil, F.water, 1000, nil, nil, F.sugar_solution, 1000, nil, dm(F.sugar_solution), 2)
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
	local m = Recipes.makeSingleRecipeMaker(Machine.centrifuge, true, true, true, true)
	local cen = ", Centrifuge"
	local from = " from "
	local breakdown = " breakdown"
	local dm = Helper.dispNameMaker
	m(I.coal_dust, 1, nil, nil, I.carbon_dust, 1, nil, nil, "Carbon Dust from Coal Dust", 16)
	m(I.ruby_dust, 6, nil, nil, I.chromium_crushed_dust, 1, I.aluminum_dust, 2, nil, nil,  dm(I.chromium_crushed_dust) .. cen, 16):filterEffOutput(I.chromium_crushed_dust)
	m(nil, F.hydrogen, 1000, nil, nil, F.deuterium, 20, F.tritium, 1, nil, "Deuterium and Tritium from Hydrogen", 32)
	m(I.gravel, 1, nil, nil, I.flint, 2, nil, nil, dm(I.flint) .. from .. dm(I.gravel) .. cen, 8)
	m(nil, F.water, 1000, nil, nil, F.heavy_water, 20, nil, dm(F.heavy_water) .. cen, 32)
	m(nil, F.helium, 1000, nil, nil, F.helium_3, 5, nil, dm(F.helium_3) .. from .. dm(F.helium) .. cen, 32)
	m(nil, F.liquid_air, 3000, nil, nil, F.oxygen, 650, F.nitrogen, 2315, F.argon, 35, nil, dm(F.liquid_air) .. breakdown, 24):filterEffOutput(F.nitrogen, F.argon)
	m(I.raw_iron, 6, nil, nil, I.iron_dust, 8, I.manganese_crushed_dust, 1, nil, nil, dm(I.manganese_crushed_dust), 8):filterEffOutput(I.manganese_crushed_dust)
	m(I.mozanite_dust, 9, nil, nil, I.neodymium_dust, 3, I.yttrium_dust, 3, I.cadmium_dust, 3, nil, nil, dm(I.mozanite_dust) .. breakdown, 10) -- Possible Helium production
	m(I.mozanite_tiny_dust, 9, nil, nil, I.neodymium_tiny_dust, 3, I.yttrium_tiny_dust, 3, I.cadmium_tiny_dust, 3, nil, nil, dm(I.mozanite_tiny_dust) .. breakdown, 10)
	m(I.he_mox_fuel_rod_depleted, 1, nil, nil, I.uranium_238_tiny_dust, 36, I.plutonium_tiny_dust, 36, nil, nil, dm(I.he_mox_fuel_rod_depleted) .. breakdown, 32):setAlwaysProc()
	m(I.he_uranium_fuel_rod_depleted, 1, nil, nil, I.uranium_238_tiny_dust, 36, I.plutonium_tiny_dust, 18, I.uranium_235_tiny_dust, 18, nil, nil, dm(I.he_uranium_fuel_rod_depleted) .. breakdown, 32):setAlwaysProc()
	m(I.le_mox_fuel_rod_depleted, 1, nil, nil, I.uranium_238_tiny_dust, 48, I.plutonium_tiny_dust, 30, nil, nil, dm(I.le_mox_fuel_rod_depleted) .. breakdown, 32):setAlwaysProc()
	m(I.le_uranium_fuel_rod_depleted, 1, nil, nil, I.uranium_238_tiny_dust, 48, I.plutonium_tiny_dust, 24, I.uranium_235_tiny_dust, 6, nil, nil, dm(I.le_uranium_fuel_rod_depleted) .. breakdown, 32):setAlwaysProc()
	m(I.uranium_fuel_rod_depleted, 1, nil, nil, I.uranium_238_tiny_dust, 53, I.plutonium_tiny_dust, 27, nil, nil, dm(I.uranium_fuel_rod_depleted), 32)
	m(I.redstone, 10, nil, nil, I.iron_dust, 5, I.ruby_dust, 1, I.quartz_dust, 1, nil, nil, dm(I.redstone) .. breakdown, 8):filterEffOutput(I.ruby_dust):setPriority(Recipe.PRIO_RELUCTANT) -- Redstone Dust is useful...
	-- m(I.uranium_dust, 9, nil, nil, I.uranium_235_tiny_dust, 1, I.uranium_238_tiny_dust, 80, nil, nil, dm(I.uranium_dust) .. breakdown, 64):setPriority(Recipe.PRIO_RELUCTANT) -- Too much energy
	m(nil, F.core_slurry, 1000, nil, I.platinum_nugget, 49, I.tungsten_nugget, 23, I.titanium_nugget, 19, I.iridium_nugget, 9, nil, nil, dm(F.core_slurry) .. breakdown, 32):setAlwaysProc()
	m(I.glowstone, 16, nil, nil, I.glowstone_dust, 8, I.sulfur_dust, 1, nil, F.helium, 100, nil, dm(I.glowstone) .. breakdown, 32):filterEffOutput(F.helium, I.sulfur_dust)
	m(I.ice_shard, 8, nil, nil, nil, F.helium_3, 100, nil, dm(F.helium_3) .. from .. dm(I.ice_shard), 32)
	m(I.moon_sand, 16, nil, nil, I.sand, 12, I.tungsten_tiny_dust, 1, nil, F.helium, 100, F.helium_3, 1, nil, "Heliums from Moon Sand", 32):filterEffOutput(F.helium, F.helium_3)
	m(I.sugar_cane, 1, nil, nil, nil, F.plant_oil, 500, nil, dm(F.plant_oil) .. from .. dm(I.sugar_cane), 8)
end
-------------------------------------------------
do -- Macerator
	local m = Recipes.makeSingleRecipeMaker(Machine.electric_macerator, true, false, true, false)
	local mac = ", Macerator"
	local from = " from "
	local grinded = " grinded"
	local dm = Helper.dispNameMaker
	m(I.galena_ore, 1, nil, I.galena_dust, 2, nil, dm(I.galena_dust), 2):setAlwaysProc()
	m(I.peridot_ore, 1, nil, I.peridot_dust, 2, nil, dm(I.peridot_dust), 2):setAlwaysProc()
	m(I.ruby_ore, 1, nil, I.ruby_dust, 2, nil, dm(I.ruby_dust) .. mac, 2):setAlwaysProc()
	m(I.sapphire_ore, 1, nil, I.sapphire_dust, 2, nil, dm(I.sapphire_dust) .. mac, 2):setAlwaysProc()
	m(I.silver_ore, 1, nil, I.raw_silver, 2, nil, dm(I.silver_ore) .. grinded, 2)
	m(I.raw_silver, 1, nil, I.silver_dust, 1, nil, dm(I.raw_silver) .. grinded, 2)
	m(I.sodalite_ore, 1, nil, I.sodalite_dust, 2, nil, dm(I.sodalite_dust) .. mac, 2):setAlwaysProc()
	m(I.ender_pearl, 1, nil, I.ender_pearl_dust, 1, nil, dm(I.ender_pearl_dust) .. mac, 2)
	m(I.annealed_copper_ingot, 1, nil, I.annealed_copper_dust, 1, nil, dm(I.annealed_copper_dust) .. mac, 2)
	m(I.antimony_ore, 1, nil, I.raw_antimony, 3, nil, dm(I.raw_antimony) .. mac, 2)
	m(I.raw_antimony, 1, nil, I.antimony_dust, 1, nil, dm(I.antimony_dust) .. mac, 2)
	m(I.bauxite_ore, 1, nil, I.bauxite_crushed_dust, 3, nil, dm(I.bauxite_ore) .. grinded, 2)
	m(I.bauxite_crushed_dust, 1, nil, I.bauxite_dust, 1, nil, dm(I.bauxite_crushed_dust) .. grinded, 2)
	m(I.clay_ball, 1, nil, I.clay_dust, 1, nil, dm(I.clay_ball) .. grinded, 2)
	m(I.coal_ore, 1, nil, I.coal_crushed_dust, 3, nil, dm(I.coal_ore) .. grinded, 2):setAlwaysProc()
	m(I.coal, 1, nil, I.coal_dust, 1, nil, dm(I.coal) .. grinded, 2):setAlwaysProc()
	m(I.coal_crushed_dust, 1, nil, I.coal_dust, 1, nil, dm(I.coal_crushed_dust) .. grinded, 2):setAlwaysProc()
	m(I.copper_ore, 1, nil, I.raw_copper, 8, nil, dm(I.copper_ore) .. grinded, 2)
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
	m(I.lapis_crushed_dust, 1, nil, I.lapis_dust, 1, nil, dm(I.lapis_crushed_dust) .. grinded, 2):setAlwaysProc()
	m(I.lapis_ore, 1, nil, I.lapis_crushed_dust, 16, nil, dm(I.lapis_ore) .. grinded, 2):setAlwaysProc()
	m(I.lead_ore, 1, nil, I.raw_lead, 3, nil, dm(I.lead_ore) .. grinded, 2):setAlwaysProc()
	m(I.raw_lead, 1, nil, I.lead_dust, 1, nil, dm(I.raw_lead) .. grinded, 2):setAlwaysProc()
	m(I.lead_ingot, 1, nil, I.lead_dust, 1, nil, dm(I.lead_ingot) .. grinded, 2):setAlwaysProc()
	m(I.lignite_coal_ore, 1, nil, I.lignite_coal_crushed_dust, 3, nil, dm(I.lignite_coal_ore) .. grinded, 2):setAlwaysProc()
	m(I.lignite_coal_crushed_dust, 1, nil, I.lignite_coal_dust, 1, nil, dm(I.lignite_coal_crushed_dust) .. grinded, 2):setAlwaysProc()
	m(I.nether_quartz_ore, 1, nil, I.quartz_crushed_dust, 4, nil, dm(I.nether_quartz_ore) .. grinded, 2):setPriority(Recipe.PRIO_HIGH) -- nether ones would be less. Less ones first.
	m(I.quartz_ore, 1, nil, I.quartz_crushed_dust, 4, nil, dm(I.quartz_ore) .. grinded, 2):setPriority(Recipe.PRIO_LOW)
	m(I.quartz_crushed_dust, 1, nil, I.quartz_dust, 1, nil, dm(I.quartz_crushed_dust) .. grinded, 2)
	m(I.redstone_ore, 1, nil, I.redstone_crushed_dust, 6, nil, dm(I.redstone_ore) .. grinded, 2)
	m(I.redstone_crushed_dust, 1, nil, I.redstone, 1, nil, dm(I.redstone_crushed_dust) .. grinded, 2)
	m(I.spruce_log, 1, nil, I.wood_pulp, 12, nil, dm(I.wood_pulp), 2)
	m(I.mozanite_crushed_dust, 1, nil, I.mozanite_dust, 1, nil, dm(I.mozanite_crushed_dust) .. grinded, 2)
	m(I.mozanite_ore, 1, nil, I.mozanite_crushed_dust, 3, nil, dm(I.mozanite_ore) .. grinded, 2)
	m(I.nickel_ore, 1, nil, I.raw_nickel, 3, nil, dm(I.nickel_ore) .. grinded, 2)
	m(I.raw_nickel, 1, nil, I.nickel_dust, 1, nil, dm(I.raw_nickel) .. grinded, 2)
	m(I.platinum_ore, 1, nil, I.raw_platinum, 3, nil, dm(I.platinum_ore) .. grinded, 2):setAlwaysProc()
	m(I.bone, 1, nil, I.bone_meal, 6, nil, dm(I.bone) .. grinded, 2)
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
	m(I.sheldonite_ore, 1, nil, I.raw_platinum, 3, nil, dm(I.sheldonite_ore) .. grinded, 2):setAlwaysProc()
	m(I.clay, 1, nil, I.clay_ball, 4, nil, dm(I.clay) .. grinded, 2)
	m(I.cobblestone, 1, nil, I.gravel, 1, nil, dm(I.cobblestone) .. grinded, 2)
	m(I.gravel, 1, nil, I.sand, 1, nil, dm(I.sand) .. from .. dm(I.gravel) .. mac, 2)
	m(I.sugar_cane, 1, nil, I.sugar, 3, nil, dm(I.sugar_cane) .. grinded, 2)
end
-------------------------------------------------
do -- Electronizer
	local m = Recipes.makeSingleRecipeMaker(Machine.electrolyzer, true, true, true, true)
	local ele = ", Electrolyzer"
	local from = " from "
	local eleced = " electrolized"
	local dm = Helper.dispNameMaker
	m(I.bauxite_dust, 10, nil, nil, I.aluminum_dust, 4, I.titanium_tiny_dust, 3, nil, nil, dm(I.aluminum_dust) .. from .. dm(I.bauxite_dust), 32):filterEffOutput(I.aluminum_dust):setPriority(Recipe.PRIO_LOW) -- Main method for aluminum dust
	m(I.emerald_dust, 23, nil, nil, I.beryllium_dust, 3, I.aluminum_dust, 2, I.silicon_dust, 6, nil, F.oxygen, 3000, nil, dm(I.emerald_dust) .. eleced, 32):filterEffOutput(I.beryllium_dust):setPriority(Recipe.PRIO_RELUCTANT)
	m(nil, F.heavy_water, 3000, nil, nil, F.deuterium, 2000, F.oxygen, 1000, nil, dm(F.heavy_water) .. eleced, 8):filterEffOutput(F.deuterium)
	m(I.lapis_dust, 18, nil, nil, I.aluminum_dust, 3, I.sodium_dust, 2, I.silicon_dust, 1, nil, nil, dm(I.lapis_dust) .. eleced, 32):setAlwaysProc()
	m(nil, F.manganese_sulfuric_solution, 1000, nil, I.manganese_tiny_dust, 3, nil, F.sulfuric_acid, 900, nil, dm(I.manganese_tiny_dust) .. ele, 16):filterEffOutput(I.manganese_tiny_dust)
	m(nil, F.water, 3000, nil, nil, F.hydrogen, 2000, F.oxygen, 1000, nil, dm(F.water) .. eleced, 8):setPriority(Recipe.PRIO_HIGH)
	m(nil, F.brine, 8000, nil, nil, F.chlorine, 2000, F.hydrogen, 2000, F.sodium_hydroxide, 3000, F.lithium, 1000, nil, dm(F.brine) .. eleced, 32):filterEffOutput(F.chlorine, F.sodium_hydroxide, F.lithium):setPriority(Recipe.PRIO_HIGH) -- Brine is easy to get
	-- m(nil, F.chloroform, 1000, nil, nil, F.hydrogen, 300, F.chlorine, 600, nil, dm(F.chloroform) .. eleced, 16):setPriority(Recipe.PRIO_RELUCTANT) -- chloroform is scarce resource..
	m(I.clay_dust, 32, nil, nil, I.aluminum_dust, 1, I.sodium_dust, 2, I.silicon_dust, 1, nil, F.lithium, 1000, nil, dm(I.clay_dust) .. eleced, 32):setOpportunistic():setPriority(Recipe.PRIO_RELUCTANT) -- Too much energy, low retrieve
	-- m(nil, F.hydrochloric_acid, 1000, nil, nil, F.hydrogen, 500, F.chlorine, 500, nil, dm(F.hydrochloric_acid) .. eleced, 16):setPriority(Recipe.PRIO_RELUCTANT) -- hydrochloric_acid is scarce resource..
	m(I.peridot_dust, 9, nil, nil, I.magnesium_dust, 2, I.raw_iron, 2, I.silicon_dust, 1, nil, F.oxygen, 100, nil, dm(I.peridot_dust) .. eleced, 16):filterEffOutput(I.magnesium_dust, I.raw_iron, I.silicon_dust):setAlwaysProc() -- Peridot dust's only usage
	m(I.salt_dust, 2, nil, F.water, 100, nil, I.sodium_dust, 1, nil, F.chlorine, 125, nil, dm(I.sodium_dust) .. from .. dm(I.salt_dust), 16):filterEffOutput(I.sodium_dust)
	m(I.sapphire_dust, 8, nil, nil, I.aluminum_dust, 2, nil, nil, dm(I.sapphire_dust) .. eleced, 16):setAlwaysProc() -- sapphire Dust's only usage
	m(I.sodalite_dust, 23, nil, nil, I.aluminum_dust, 3, I.sodium_dust, 4, I.silicon_dust, 3, nil, nil, dm(I.sodalite_dust) .. eleced, 16):setAlwaysProc() -- sodalite_dust's only usage
end
-------------------------------------------------
do -- Polarizer
	local m = Recipes.makeSingleRecipeMaker(Machine.polarizer, true, false, true, false)
	local dm = Helper.dispNameMaker
	m(I.stainless_steel_rod, 1, I.neodymium_dust, 1, nil, I.stainless_steel_rod_magnetic, 1, nil, dm(I.stainless_steel_rod_magnetic), 16)
	m(I.cupronickel_wire, 1, nil, I.cupronickel_wire_magnetic, 1, nil, dm(I.cupronickel_wire_magnetic), 8)
	m(I.steel_rod, 1, nil, I.steel_rod_magnetic, 1, nil, dm(I.steel_rod_magnetic), 8)
end
-------------------------------------------------
do -- Laser Engraver
	local dm = Helper.dispNameMaker
	local m = Recipes.makeSingleRecipeMaker(Machine.laser_engraver, true, false, true, false)
	m(I.basic_card, 1, I.ender_pearl, 1, nil, I.enderman_model, 1, nil, dm(I.enderman_model), 32)
	m(I.basic_card, 1, I.glass_bottle, 1, nil, I.witch_model, 1, nil, dm(I.witch_model), 32)
	m(I.basic_card, 1, I.withered_bone, 1, nil, I.wither_skeleton_model, 1, nil, dm(I.wither_skeleton_model), 32)
end
-------------------------------------------------
do -- Distillery
	-- Other distillery recipes are done manually.
	local m = Recipes.makeSingleRecipeMaker(Machine.distillery, false, true, false, true)
	m(F.sugar_solution, 1000, nil, F.ethanol, 10, nil, Helper.dispNameMaker(F.ethanol) .. " from Sugar solution", 8)
	m(F.salt_water, 4000, nil, F.brine, 3000, nil, Helper.dispNameMaker(F.brine) .. " from single Distillery", 16):setAlwaysProc()
end
-------------------------------------------------
do -- Distillation Tower
	local m = Recipes.makeSingleRecipeMaker(MultiblockMachine.distillationTower, false, true, false, true)
	local dm = Helper.dispNameMaker
	local disted = " Distillation"
	m(F.wood_tar, 1000, nil, F.creosote, 400, F.benzene, 400, F.toluene, 100, F.heavy_fuel, 100, nil, dm(F.wood_tar) .. disted, 48)
	m(F.crude_oil, 1000, nil, F.sulfuric_light_fuel, 500, F.sulfuric_heavy_fuel, 200, F.sulfuric_naphtha, 300, nil, dm(F.crude_oil) .. disted, 36)
	m(F.shale_oil, 1000, nil, F.helium, 50, F.sulfuric_crude_oil, 450, F.sulfuric_naphtha, 500, nil, dm(F.shale_oil) .. disted, 30)
	m(F.steam_cracked_heavy_fuel, 1000, nil, F.light_fuel, 500, F.methane, 100, F.butadiene, 250, F.benzene, 150, nil, dm(F.steam_cracked_heavy_fuel) .. disted, 80)
	m(F.steam_cracked_light_fuel, 1000, nil, F.methane, 200, F.acetylene, 100, F.ethylene, 300, F.butadiene, 200, F.benzene, 200, nil, dm(F.steam_cracked_light_fuel) .. disted, 125)
	m(F.steam_cracked_naphtha, 1000, nil, F.methane, 150, F.acetylene, 50, F.ethylene, 250, F.propene, 75, F.butadiene, 125, F.benzene, 150, F.toluene, 100, F.ethylbenzene, 100, nil, dm(F.steam_cracked_naphtha) .. disted, 120)
end
-------------------------------------------------
do -- Chemical Reactor, large chemical reactor
	local m = Recipes.makeSingleChemicalReactorRecipe
	local chem = ", Chemical Reactor"
	local dm = Helper.dispNameMaker
	m(I.silicon_plate, 1, I.antimony_tiny_dust, 1, nil, nil, I.silicon_n_doped_plate, 1, nil, nil, dm(I.silicon_n_doped_plate), 8)
	m(I.silicon_plate, 1, I.aluminum_tiny_dust, 1, nil, nil, I.silicon_p_doped_plate, 1, nil, nil, dm(I.silicon_p_doped_plate), 8)
	m(I.silicon_wafer, 1, I.antimony_dust, 1, I.aluminum_dust, 1, nil, F.argon, 250, F.styrene_butadiene_rubber, 500, nil, I.random_access_memory, 2, nil, nil, dm(I.random_access_memory), 12)
	m(I.chromium_crushed_dust, 1, nil, F.hydrochloric_acid, 9000, nil, nil, F.chromium_hydrochloric_solution, 9000, nil, dm(F.chromium_hydrochloric_solution), 8)
	-- m(nil, F.oxygen, 1000, F.deuterium, 2000, nil, nil, F.heavy_water, 3000, nil, dm(F.heavy_water) .. chem, 8)
	-- Deuterium is much more valuable...
	m(nil, F.hydrogen, 1000, F.chlorine, 1000, nil, nil, F.hydrochloric_acid, 2000, nil, dm(F.hydrochloric_acid), 8)
	m(I.manganese_crushed_dust, 1, nil, F.sulfuric_acid, 9000, nil, nil, F.manganese_sulfuric_solution, 9000, nil, dm(F.manganese_sulfuric_solution), 8)
	-- m(I.sodium_dust, 1, nil, F.oxygen, 1000, F.hydrogen, 1000, nil, nil, F.sodium_hydroxide, 2000, nil, dm(F.sodium_hydroxide) .. " from " .. dm(I.sodium_dust), 8)
	-- Sodium dust is much more valuable
	m(I.sulfur_dust, 1, nil, F.oxygen, 200, F.water, 200, nil, nil, F.sulfuric_acid, 500, nil, dm(F.sulfuric_acid), 16)
	m(nil, F.chlorine, 2000, F.methane, 500, nil, nil, F.hydrochloric_acid, 2000, F.chloroform, 500, nil, dm(F.chloroform), 18):filterEffOutput(F.chloroform)
	m(I.ender_pearl, 1, I.blaze_powder, 1, nil, nil, I.ender_eye, 2, nil, nil, dm(I.ender_eye), 8)
	m(I.diamond, 1, nil, F.molten_redstone, 3600, nil, I.synthetic_redstone_crystal, 1, nil, nil, dm(I.synthetic_redstone_crystal), 24)
	-- m(I.coal_dust, 1, nil, F.acetylene, 1000, nil, nil, F.hydrogen, 2000, nil, dm(F.hydrogen) .. " from " .. dm(I.coal_dust), 12)
	-- Hydrogen is cheap.
	m(nil, F.benzene, 750, F.ethylene, 750, F.hydrochloric_acid, 100, nil, nil, F.ethylbenzene, 750, nil, dm(F.ethylbenzene) .. chem, 12):setOpportunistic(F.benzene, F.ethylene):setPriority(Recipe.PRIO_HIGH)
	-- Primariliy Ethylbenzene should be from distillation...
	m(I.aluminum_tiny_dust, 1, nil, F.ethanol, 750, nil, nil, F.butadiene, 375, F.water, 750, F.hydrogen, 250, nil, dm(F.butadiene) .. chem, 16):setOpportunistic(F.ethanol):filterEffOutput(F.butadiene):setPriority(Recipe.PRIO_HIGH)
	m(nil, F.ethanol, 500, F.acrylic_acid, 25, nil, nil, F.diethyl_ether, 250, F.water, 250, nil, dm(F.diethyl_ether) .. chem, 20):filterEffOutput(F.diethyl_ether)
	m(I.sulfur_dust, 1, nil, F.ethanol, 1000, nil, nil, F.ethylene, 500, F.sulfuric_acid, 400, nil, dm(F.ethylene) .. chem, 10):setOpportunistic(F.ethanol):filterEffOutput(F.ethylene):setPriority(Recipe.PRIO_HIGH)
	m(I.iron_dust, 1, nil, F.ethylbenzene, 1000, F.steam, 2000, nil, nil, F.styrene, 1000, F.hydrogen, 500, nil, dm(F.styrene), 20):filterEffOutput(F.styrene)
	m(nil, F.ethylene, 200, F.water, 200, F.sulfuric_acid, 35, nil, nil, F.ethanol, 200, nil, dm(F.ethanol) .. " from " .. dm(F.ethylene), 10):setOpportunistic(F.ethylene):setPriority(Recipe.PRIO_HIGH)
	m(nil, F.plant_oil, 6000, F.ethanol, 400, F.sodium_hydroxide, 100, nil, nil, F.raw_biodiesel, 1500, nil, dm(F.raw_biodiesel), 12)
	m(nil, F.propene, 400, F.oxygen, 600, nil, nil, F.acrylic_acid, 400, F.water, 400, nil, dm(F.acrylic_acid), 10):filterEffOutput(F.acrylic_acid)
	m(nil, F.raw_biodiesel, 1000, F.steam, 1000, nil, nil, F.biodiesel, 700, F.ethanol, 250, nil, dm(F.biodiesel), 16):filterEffOutput(F.biodiesel)
	m(nil, F.styrene, 500, F.butadiene, 500, nil, nil, F.styrene_butadiene, 1000, nil, dm(F.styrene_butadiene), 10)
	m(nil, F.acetylene, 1000, F.hydrochloric_acid, 1000, nil, nil, F.vinyl_chloride, 1000, nil, dm(F.vinyl_chloride), 16)
	m(I.chromium_tiny_dust, 1, nil, F.ethylene, 500, nil, nil, F.polyethylene, 700, nil, dm(F.polyethylene) .. " with " .. dm(I.chromium_tiny_dust), 12)
	-- m(I.lead_tiny_dust, 4, nil, F.ethylene, 500, nil, nil, F.polyethylene, 300, nil, dm(F.polyethylene) .. " with " .. dm(I.lead_tiny_dust), 12)
	-- Too inefficient
	m(I.chromium_tiny_dust, 1, nil, F.styrene_butadiene, 500, nil, nil, F.styrene_butadiene_rubber, 700, nil, dm(F.styrene_butadiene_rubber) .. " with " .. dm(I.chromium_tiny_dust), 12)
	-- m(I.lead_tiny_dust, 4, nil, F.styrene_butadiene, 500, nil, nil, F.styrene_butadiene_rubber, 300, nil, dm(F.styrene_butadiene_rubber) .. " with " .. dm(I.lead_tiny_dust), 12)
	-- Too inefficient
	m(I.chromium_tiny_dust, 1, nil, F.vinyl_chloride, 500, nil, nil, F.polyvinyl_chloride, 700, nil, dm(F.polyvinyl_chloride) .. " with " .. dm(I.chromium_tiny_dust), 12)
	-- m(I.lead_tiny_dust, 4, nil, F.vinyl_chloride, 500, nil, nil, F.polyvinyl_chloride, 300, nil, dm(F.polyvinyl_chloride) .. " with " .. dm(I.lead_tiny_dust), 12)
	-- Too inefficient
	m(nil, F.heavy_fuel, 1000, F.steam, 100, nil, nil, F.steam_cracked_heavy_fuel, 1000, nil, dm(F.steam_cracked_heavy_fuel), 8)
	m(nil, F.light_fuel, 1000, F.steam, 100, nil, nil, F.steam_cracked_light_fuel, 1000, nil, dm(F.steam_cracked_light_fuel), 8)
	m(nil, F.naphtha, 1000, F.steam, 100, nil, nil, F.steam_cracked_naphtha, 1000, nil, dm(F.steam_cracked_naphtha), 8)
	m(nil, F.sulfuric_crude_oil, 12000, F.hydrogen, 2000, nil, nil, F.crude_oil, 12000, F.sulfuric_acid, 2000, nil, dm(F.crude_oil) .. " de-sulf", 16):setAlwaysProc()
	m(nil, F.sulfuric_heavy_fuel, 12000, F.hydrogen, 2000, nil, nil, F.heavy_fuel, 12000, F.sulfuric_acid, 2000, nil, dm(F.heavy_fuel) .. " de-sulf", 16):setAlwaysProc()
	m(nil, F.sulfuric_light_fuel, 12000, F.hydrogen, 2000, nil, nil, F.light_fuel, 12000, F.sulfuric_acid, 2000, nil, dm(F.light_fuel) .. " de-sulf", 16):setAlwaysProc()
	m(nil, F.sulfuric_naphtha, 12000, F.hydrogen, 2000, nil, nil, F.naphtha, 12000, F.sulfuric_acid, 2000, nil, dm(F.naphtha) .. " de-sulf", 16):setAlwaysProc()
end
-------------------------------------------------
do -- Other Packer recipes
	local dm = Helper.dispNameMaker
	local m = Recipes.makeSingleRecipeMaker(Machine.electric_packer, true, false, true, false)
	m(I.ostrum_ingot, 1, I.tungsten_ingot, 1, I.ostrum_ingot, 1, nil, I.mixed_ingot_blastproof, 1, nil, dm(I.mixed_ingot_blastproof), 32)
	m(I.blastproof_alloy_ingot, 2, I.iridium_ingot, 1, nil, I.mixed_ingot_iridium, 1, nil, dm(I.mixed_ingot_iridium), 2)
	m(I.iridium_plate, 4, I.diamond_dust, 1, I.advanced_alloy_plate, 4, nil, I.iridium_alloy_ingot, 1, nil, dm(I.iridium_alloy_ingot), 24)
	m(I.blastproof_alloy_plate, 1, I.beryllium_plate, 1, I.cadmium_plate, 1, nil, I.mixed_plate_nuclear, 1, nil, dm(I.mixed_plate_nuclear), 2)
end
-------------------------------------------------
do -- Other Unpacker recipes
	local dm = Helper.dispNameMaker
	local m = Recipes.makeSingleRecipeMaker(Machine.electric_unpacker, true, false, true, false)
	m(I.stainless_steel_ingot, 1, nil, I.stainless_steel_nugget, 9, nil, dm(I.stainless_steel_nugget), 2)
end
-------------------------------------------------
do -- Industrial Greenhouse recipes
	-- Only wood is required... (or not)
end
-------------------------------------------------
do -- Blast Furnace recipes (Cupronickel, Kanthal, Tungstensteel)
	local dm = Helper.dispNameMaker
	
	local mcRaw = Recipes.makeSingleRecipeMaker(MultiblockMachine.blastFurnaceCupr, true, true, true, true)
	local mkRaw = Recipes.makeSingleRecipeMaker(MultiblockMachine.blastFurnaceKant, true, true, true, true)
	local mtRaw = Recipes.makeSingleRecipeMaker(MultiblockMachine.blastFurnaceTung, true, true, true, true)

	local mk = function(...)
		return RecipeList:new {
			mkRaw(...), 
			mtRaw(...)
		}
	end
	local mc = function(...)
		return RecipeList:new {
			mcRaw(...),
			mkRaw(...),
			mtRaw(...)
		}
	end

	local blasted = " blasted"
	local bla = ", blast furnace"

	mc(I.redstone, 9, nil, nil, nil, F.molten_redstone, 1000, nil, dm(F.molten_redstone), 4)
	mc(nil, F.raw_synthetic_oil, 1000, nil, nil, F.synthetic_oil, 1000, nil, dm(F.synthetic_oil), 2)
	mc(I.soldering_alloy_dust, 9, nil, nil, nil, F.soldering_alloy, 1000, nil, dm(F.soldering_alloy), 4)

	mc(I.quartz_dust, 2, I.carbon_dust, 1, nil, nil, I.silicon_dust, 2, nil, nil, dm(I.silicon_dust) .. bla, 32)
	mc(I.chromium_dust, 1, nil, nil, I.chromium_hot_ingot, 1, nil, nil, dm(I.chromium_hot_ingot), 32)
	mc(I.kanthal_dust, 1, nil, nil, I.kanthal_hot_ingot, 1, nil, nil, dm(I.kanthal_hot_ingot), 32)
	mc(I.stainless_steel_dust, 1, nil, nil, I.stainless_steel_hot_ingot, 1, nil, nil, dm(I.stainless_steel_hot_ingot), 32)
	mc(I.aluminum_dust, 1, nil, nil, I.aluminum_ingot, 1, nil, nil, dm(I.aluminum_ingot) .. bla, 32)
	mc(nil, F.methane, 200, nil, nil, F.acetylene, 200, nil, dm(F.acetylene) .. bla, 32):setOpportunistic(F.methane):setPriority(Recipe.PRIO_HIGH)
	
	mk(I.nether_star, 1, nil, nil, nil, F.molten_nether_star, 500, nil, dm(F.molten_nether_star), 128):setOpportunistic():setPriority(Recipe.PRIO_HIGH)
	mk(I.silicon_dust, 32, I.iridium_tiny_dust, 1, nil, F.argon, 1250, nil, I.monocrystalline_silicon, 1, nil, nil, dm(I.monocrystalline_silicon), 64)
	mk(I.copper_dust, 1, nil, F.oxygen, 250, nil, I.annealed_copper_hot_ingot, 1, nil, nil, dm(I.annealed_copper_hot_ingot), 64)
	mk(I.raw_titanium, 3, nil, F.manganese_sulfuric_solution, 3000, nil, I.titanium_hot_ingot, 4, nil, F.manganese_sulfuric_solution, 2500, nil, dm(I.titanium_hot_ingot), 128):filterEffOutput(I.titanium_hot_ingot)
	mk(I.he_mox_dust, 1, nil, nil, I.he_mox_ingot, 1, nil, nil, dm(I.he_mox_ingot), 128)
	mk(I.he_uranium_dust, 1, nil, nil, I.he_uranium_ingot, 1, nil, nil, dm(I.he_uranium_ingot), 128)
	mk(I.le_mox_dust, 1, nil, nil, I.le_mox_ingot, 1, nil, nil, dm(I.le_mox_ingot), 128)
	mk(I.le_uranium_dust, 1, nil, nil, I.le_uranium_ingot, 1, nil, nil, dm(I.le_uranium_ingot), 128)
	mk(I.platinum_dust, 1, nil, nil, I.platinum_hot_ingot, 1, nil, nil, dm(I.platinum_hot_ingot), 128)
	mk(I.plutonium_dust, 1, nil, nil, I.plutonium_ingot, 1, nil, nil, dm(I.plutonium_ingot), 128)
	mk(I.titanium_dust, 1, nil, nil, I.titanium_hot_ingot, 1, nil, nil, dm(I.titanium_hot_ingot), 128):setOpportunistic():setPriority(Recipe.PRIO_HIGH)
	mk(I.uranium_dust, 1, nil, nil, I.uranium_ingot, 1, nil, nil, dm(I.uranium_ingot) .. bla, 128)
	mk(I.stainless_steel_dust, 1, nil, F.molten_enderium, 1000, nil, I.enderium_hot_ingot, 1, nil, nil, dm(I.enderium_hot_ingot), 64)
	mk(I.tungsten_ingot, 1, I.steel_ingot, 1, nil, nil, I.tungstensteel_hot_ingot, 1, nil, nil, dm(I.tungstensteel_hot_ingot), 128)
	mk(I.steel_dust, 1, nil, F.liquid_ender, 1000, nil, nil, F.molten_enderium, 1000, nil, dm(F.molten_enderium), 48)
	mk(I.platinum_tiny_dust, 1, nil, F.impure_liquid_nether_star, 1000, nil, nil, F.molten_nether_star, 1000, nil, dm(F.molten_nether_star) .. " from impure", 128)
	
	mtRaw(I.superconductor_dust, 1, nil, F.molten_nether_star, 50, nil, I.superconductor_hot_ingot, 1, nil, nil, dm(I.superconductor_hot_ingot), 512)
	
	---------------------------- Special -------
	mc(I.refined_iron_ingot, 3, I.carbon_dust, 1, nil, nil, I.steel_ingot, 4, nil, nil, dm(I.steel_ingot) .. " from " .. dm(I.refined_iron_ingot), 16):setOpportunistic()
	mc(I.carbon_dust, 1, I.iron_dust, 4, nil, nil, I.steel_ingot, 5, nil, nil, dm(I.steel_ingot) .. bla, 16)
	-- Use refined iron prior than normal iron dust
	mc(I.uncooked_steel_dust, 1, nil, nil, I.steel_ingot, 1, nil, nil, dm(I.steel_ingot) .. " from " .. dm(I.uncooked_steel_dust), 2)
end
-------------------------------------------------
do -- Pyrolyse Oven recipes
	local m = Recipes.makeSingleRecipeMaker(MultiblockMachine.pyrolyseOven, true, true, true, true)
	m(I.spruce_log, 16, nil, F.steam, 8000, nil, I.charcoal, 24, nil, F.wood_tar, 1000, nil, Helper.dispNameMaker(F.wood_tar), 16):filterEffOutput(F.wood_tar)
	m(I.coal_dust, 16, nil, F.steam, 8000, nil, I.coke_dust, 20, nil, F.creosote, 1000, nil, Helper.dispNameMaker(I.coke_dust) .. ", Pyrolyse", 16):filterEffOutput(I.coke_dust)
end
-------------------------------------------------
do -- Vacuum Freezer recipes
	local dm = Helper.dispNameMaker
	local mRaw = Recipes.makeSingleRecipeMaker(MultiblockMachine.vacuumFreezer, true, true, true, true)
	local m = function(...)
		-- Most of Vacuum Freezer recipes can be done efficiently in other machines (Pressurizer, Heat exchanger)
		return mRaw(...):setPriority(Recipe.PRIO_LOW)
	end

	m(I.kanthal_hot_ingot, 1, nil, nil, I.kanthal_ingot, 1, nil, nil, dm(I.kanthal_hot_ingot) .. " cooled", 32)
	m(I.chromium_hot_ingot, 1, nil, nil, I.chromium_ingot, 1, nil, nil, dm(I.chromium_hot_ingot) .. " cooled", 32)
	m(I.enderium_hot_ingot, 1, nil, nil, I.enderium_ingot, 1, nil, nil, dm(I.enderium_hot_ingot) .. " cooled", 32)
	m(I.platinum_hot_ingot, 1, nil, nil, I.platinum_ingot, 1, nil, nil, dm(I.platinum_hot_ingot) .. " cooled", 32)
	m(I.titanium_hot_ingot, 1, nil, nil, I.titanium_ingot, 1, nil, nil, dm(I.titanium_hot_ingot) .. " cooled", 32)
	m(I.superconductor_hot_ingot, 1, nil, nil, I.superconductor_ingot, 1, nil, nil, dm(I.superconductor_hot_ingot) .. " cooled", 32)
	m(I.annealed_copper_hot_ingot, 1, nil, nil, I.annealed_copper_ingot, 1, nil, nil, dm(I.annealed_copper_hot_ingot) .. " cooled", 32)
	m(I.stainless_steel_hot_ingot, 1, nil, nil, I.stainless_steel_ingot, 1, nil, nil, dm(I.stainless_steel_hot_ingot) .. " cooled", 32)
	m(I.tungstensteel_hot_ingot, 1, nil, nil, I.tungstensteel_ingot, 1, nil, nil, dm(I.tungstensteel_hot_ingot) .. " cooled", 64)

	m(nil, F.argon, 35, F.helium, 15, nil, nil, F.cryofluid, 50, nil, dm(F.cryofluid), 64)
	m(nil, F.polytetrafluoroethylene, 100, nil, I.polytetrafluoroethylene_ingot, 1, nil, nil, dm(I.polytetrafluoroethylene_ingot), 32)
	m(nil, F.styrene_butadiene_rubber, 200, nil, I.rubber_sheet, 64, nil, nil, dm(I.rubber_sheet) .. " from " .. dm(F.styrene_butadiene_rubber), 128):setOpportunistic(F.styrene_butadiene_rubber):setPriority(Recipe.PRIO_HIGH)
end
-------------------------------------------------
do -- Heat Exchanger recipes
	-- Do later...
end
-------------------------------------------------
do -- Pressurizer recipes
	-- Do later...
end
-------------------------------------------------
do -- Implosion Compressor recipes
	local dm = Helper.dispNameMaker
	local m = Recipes.makeSingleRecipeMaker(MultiblockMachine.implosionCompressor, true, false, true, false)
	local itnt = I.industrial_tnt
	m(I.beryllium_tiny_dust, 9, I.stainless_steel_nugget, 1, itnt, 1, nil, I.beryllium_ingot, 1, nil, nil, 1)
	m(I.mixed_ingot_blastproof, 1, itnt, 1, nil, I.blastproof_alloy_ingot, 3, nil, nil, 1)
	m(I.mixed_ingot_iridium, 1, itnt, 1, nil, I.iridium_plate, 1, nil, nil, 1)
	m(I.mixed_plate_nuclear, 1, itnt, 1, nil, I.nuclear_alloy_plate, 3, nil, nil, 1)
	m(I.tungsten_tiny_dust, 9, I.stainless_steel_nugget, 1, itnt, 1, nil, I.tungsten_ingot, 1, nil, nil, 1)
	m(I.iridium_alloy_ingot, 1, itnt, 4, nil, I.iridium_alloy_plate, 1, nil, nil, 64)
	m(I.tungsten_large_plate, 64, I.enderium_plate, 64, I.core_fragment, 64, I.nuke, 8, nil, I.ultradense_metal_ball, 1, nil, nil, 512)
	m(I.emerald_dust, 1, itnt, 1, nil, I.emerald, 1, nil, nil, 1)
	m(I.diamond_dust, 1, itnt, 1, nil, I.diamond, 1, nil, nil, 1)
end
-------------------------------------------------
do -- Mob Crusher recipes
	-- Will be treated as Producer
end
-------------------------------------------------
do -- Nuclear Reactor recipes
	-- I cannot understand how this machine works.
end
-------------------------------------------------
do -- Fusion Reactor recipes
	local dm = Helper.dispNameMaker
	local m = Recipes.makeSingleRecipeMaker(MultiblockMachine.fusionReactor, false, true, false, true)
	-- Do it later...
end
-------------------------------------------------
do -- Core Mininer recipes
	-- Will be treated as Producer
end
-------------------------------------------------
do -- Quasi Quantum Singularity Forge recipe
	local m = Recipes.makeSingleRecipeMaker(MultiblockMachine.bigComputer, true, true, true, false)
	m(I.nuke, 64, I.ultradense_metal_ball, 1, nil, F.neutronium, 1000, nil, I.singularity, 1, nil, Helper.dispNameMaker(I.singularity), 8192)
end
-------------------------------------------------
do -- Assembler Recipes
	local m = Recipes.makeSingleRecipeMaker(Machine.assembler, true, true, true, false)
	local dm = Helper.dispNameMaker

	m(I.battery_alloy_plate, 1, I.tin_cable, 2, I.battery_alloy_curved_plate, 4, I.redstone, 2, nil, nil, I.redstone_battery, 1, nil, nil, 8)
	m(I.battery_alloy_plate, 1, I.electrum_cable, 2, I.battery_alloy_curved_plate, 4, I.silicon_dust, 2, nil, nil, I.silicon_battery, 1, nil, nil, 8)
	m(I.superconductor_coil, 4, I.large_heat_exchanger, 2, I.nuclear_alloy_large_plate, 2, I.plasma_handling_iridium_machine_casing, 1, nil, nil, I.fusion_chamber, 1, nil, nil, 8)
	m(I.aluminum_plate, 8, I.basic_machine_hull, 1, nil, nil, I.advanced_machine_casing, 1, nil, nil, 8)
	m(I.blastproof_alloy_plate, 8, nil, nil, I.blastproof_casing, 1, nil, nil, 8)
	m(I.stainless_steel_plate, 8, I.stainless_steel_gear, 1, nil, nil, I.clean_stainless_steel_machine_casing, 1, nil, nil, 8)
	m(I.invar_plate, 8, I.invar_gear, 1, nil, nil, I.heatproof_machine_casing, 1, nil, nil, 8)
	m(I.titanium_plate, 4, I.chromium_plate, 4, I.turbo_machine_hull, 1, nil, nil, I.highly_advanced_machine_casing, 1, nil, nil, 8)
	m(I.plasma_handling_iridium_machine_casing, 1, I.iridium_curved_plate, 6, I.large_advanced_pump, 2, nil, nil, I.iridium_machine_casing_pipe, 2, nil, nil, 8)
	m(I.stainless_steel_plate, 8, I.advanced_machine_hull, 1, nil, nil, I.turbo_machine_casing, 1, nil, nil, 8)
	m(I.or_gate, 1, I.electronic_circuit, 4, I.not_gate, 2, I.and_gate, 1, I.digital_circuit_board, 1, nil, nil, I.digital_circuit, 1, nil, nil, 8)
	m(I.diode, 2, I.analog_circuit, 4, I.transistor, 2, I.electronic_circuit_board, 1, nil, nil, I.electronic_circuit, 1, nil, nil, 8)
	m(I.aluminum_plate, 3, I.electrum_cable, 4, I.analog_circuit_board, 1, I.redstone_battery, 1, nil, nil, I.electronic_circuit_board, 1, nil, nil, 8)
	m(I.inductor, 1, I.copper_wire, 3, I.resistor, 2, I.capacitor, 2, I.analog_circuit_board, 1, nil, nil, I.analog_circuit, 1, nil, nil, 8)
	m(I.rubber_sheet, 2, I.copper_plate, 1, nil, nil, I.analog_circuit_board, 1, nil, nil, 8)
	m(I.digital_circuit, 4, I.random_access_memory, 2, I.memory_management_unit, 1, I.arithmetic_logic_unit, 1, I.processing_unit_board, 1, nil, nil, I.processing_unit, 1, nil, nil, 8)
	m(I.processing_unit, 4, I.cooling_cell, 2, I.qbit, 2, I.quantum_circuit_board, 1, nil, nil, I.quantum_circuit, 1, nil, nil, 8)
	m(I.stainless_steel_rod_magnetic, 1, I.stainless_steel_rod, 2, I.aluminum_cable, 2, I.annealed_copper_wire, 4, nil, nil, I.advanced_motor, 1, nil, nil, 8)
	m(I.resistor, 2, I.op_amp, 1, I.aluminum_wire, 4, nil, nil, I.and_gate, 1, nil, nil, 8)
	m(I.diamond_plate, 1, I.and_gate, 2, I.or_gate, 2, I.not_gate, 4, nil, nil, I.arithmetic_logic_unit, 1, nil, nil, 8)
	m(I.motor, 2, I.rubber_sheet, 6, I.tin_cable, 1, nil, nil, I.conveyor, 1, nil, nil, 8)
	m(I.silicon_n_doped_plate, 1, I.glass, 3, I.electrum_fine_wire, 3, I.steel_plate, 2, nil, nil, I.diode, 2, nil, nil, 8)
	m(I.processing_unit, 1, I.titanium_rod, 2, I.advanced_motor, 6, nil, nil, I.large_advanced_motor, 1, nil, nil, 8)
	m(I.processing_unit, 2, I.titanium_rotor, 3, I.large_advanced_motor, 1, I.advanced_pump, 3, nil, nil, I.large_advanced_pump, 1, nil, nil, 8)
	m(I.small_heat_exchanger, 2, I.large_advanced_pump, 1, I.aluminum_rotor, 2, I.invar_gear, 4, nil, nil, I.large_heat_exchanger, 1, nil, nil, 8)
	m(I.electronic_circuit, 1, I.aluminum_rod, 2, I.motor, 6, nil, nil, I.large_motor, 1, nil, nil, 8)
	m(I.electronic_circuit, 2, I.aluminum_rotor, 3, I.large_motor, 1, I.pump, 3, nil, nil, I.large_pump, 1, nil, nil, 8)
	m(I.emerald_plate, 1, I.silicon_wafer, 2, I.platinum_fine_wire, 6, nil, nil, I.memory_management_unit, 1, nil, nil, 8)
	m(I.steel_rod_magnetic, 1, I.steel_rod, 2, I.tin_cable, 2, I.copper_wire, 4, nil, nil, I.motor, 1, nil, nil, 8)
	m(I.resistor, 1, I.op_amp, 1, I.aluminum_wire, 1, nil, nil, I.not_gate, 1, nil, nil, 8)
	m(I.op_amp, 2, I.aluminum_wire, 2, I.diode, 1, nil, nil, I.or_gate, 1, nil, nil, 8)
	m(I.motor, 1, I.steel_rod, 2, I.tin_cable, 2, I.steel_plate, 3, I.steel_gear, 1, nil, nil, I.piston, 1, nil, nil, 8)
	m(I.motor, 2, I.steel_rod, 2, I.tin_cable, 3, I.piston, 1, I.analog_circuit, 1, nil, nil, I.robot_arm, 1, nil, nil, 8)
	m(I.invar_plate, 4, I.stainless_steel_large_plate, 1, I.advanced_pump, 4, nil, nil, I.small_heat_exchanger, 1, nil, nil, 8)
	m(I.silicon_p_doped_plate, 2, I.silicon_n_doped_plate, 1, I.electrum_fine_wire, 1, I.steel_plate, 3, nil, nil, I.transistor, 4, nil, nil, 8)
	m(I.silicon_battery, 2, I.electronic_circuit, 1, I.advanced_machine_casing, 1, I.electrum_cable, 3, nil, nil, I.advanced_machine_hull, 1, nil, nil, 8)
	m(I.cadmium_battery, 2, I.processing_unit, 1, I.highly_advanced_machine_casing, 1, I.annealed_copper_cable, 3, nil, nil, I.highly_advanced_machine_hull, 1, nil, nil, 8)
	m(I.redstone_battery, 2, I.analog_circuit, 1, I.steel_machine_casing, 1, I.tin_cable, 3, nil, nil, I.basic_machine_hull, 1, nil, nil, 8)
	m(I.plutonium_battery, 2, I.quantum_circuit, 1, I.quantum_machine_casing, 1, I.superconductor_cable, 3, nil, nil, I.quantum_machine_hull, 1, nil, nil, 8)
	m(I.sodium_battery, 2, I.digital_circuit, 1, I.turbo_machine_casing, 1, I.aluminum_cable, 3, nil, nil, I.turbo_machine_hull, 1, nil, nil, 8)
	m(I.robot_arm, 4, I.analog_circuit, 2, I.conveyor, 2, I.basic_machine_hull, 1, nil, nil, I.assembler, 1, nil, nil, 8)
	m(I.large_motor, 4, I.basic_machine_hull, 1, I.electrum_cable, 2, I.large_pump, 1, I.electronic_circuit, 1, nil, nil, I.centrifuge, 1, nil, nil, 8)
	m(I.aluminum_rotor, 2, I.large_pump, 1, I.basic_machine_hull, 1, I.glass, 2, I.electronic_circuit, 2, I.electrum_cable, 1, nil, nil, I.chemical_reactor, 1, nil, nil, 8)
	m(I.piston, 4, I.basic_machine_hull, 1, I.tin_cable, 2, I.analog_circuit, 2, nil, nil, I.electric_compressor, 1, nil, nil, 8)
	m(I.steel_machine_casing, 1, I.motor, 2, I.analog_circuit, 4, I.hopper, 2, nil, nil, I.configurable_chest, 4, nil, nil, 8)
	m(I.steel_machine_casing, 1, I.pump, 2, I.analog_circuit, 4, I.aluminum_tank, 2, nil, nil, I.configurable_tank, 4, nil, nil, 8)
	m(I.cupronickel_wire_magnetic, 4, I.aluminum_rod, 2, I.basic_machine_hull, 1, I.electronic_circuit, 1, I.large_pump, 1, nil, nil, I.electrolyzer, 1, nil, nil, 8)
	m(I.digital_circuit, 1, I.advanced_motor, 2, I.turbo_machine_hull, 1, I.fluid_pipe, 2, I.stainless_steel_rotor, 2, I.aluminum_cable, 1, nil, nil, I.hv_steam_turbine, 1, nil, nil, 8)
	m(I.invar_rotary_blade, 1, I.motor, 2, I.piston, 2, I.basic_machine_hull, 1, I.tin_cable, 1, I.analog_circuit, 2, nil, nil, I.electric_macerator, 1, nil, nil, 8)
	m(I.glass, 2, I.motor, 1, I.basic_machine_hull, 1, I.fluid_pipe, 1, I.tin_rotor, 2, I.analog_circuit, 2, nil, nil, I.electric_mixer, 1, nil, nil, 8)
	m(I.aluminum_drill_head, 1, I.iron_gear, 2, I.fluid_pipe, 2, I.pump, 2, I.electrum_cable, 1, I.electronic_circuit, 1, nil, nil, I.aluminum_drill, 4, nil, nil, 8)
	m(I.bronze_drill_head, 1, I.iron_gear, 2, I.item_pipe, 1, I.fluid_pipe, 1, nil, nil, I.bronze_drill, 4, nil, nil, 8)
	m(I.copper_drill_head, 1, I.iron_gear, 2, I.item_pipe, 1, I.fluid_pipe, 1, nil, nil, I.copper_drill, 4, nil, nil, 8)
	m(I.gold_drill_head, 1, I.iron_gear, 2, I.item_pipe, 2, I.motor, 2, I.tin_cable, 1, I.analog_circuit, 1, nil, nil, I.gold_drill, 4, nil, nil, 8)
	m(I.stainless_steel_drill_head, 1, I.iron_gear, 2, I.item_pipe, 1, I.fluid_pipe, 1, I.advanced_motor, 1, I.advanced_pump, 1, I.aluminum_cable, 1, I.digital_circuit, 1, nil, nil, I.stainless_steel_drill, 4, nil, nil, 8)
	m(I.steel_drill_head, 1, I.iron_gear, 2, I.item_pipe, 2, I.motor, 2, I.tin_cable, 1, I.analog_circuit, 1, nil, nil, I.steel_drill, 4, nil, nil, 8)
	m(I.titanium_drill_head, 1, I.iron_gear, 2, I.item_pipe, 2, I.large_advanced_motor, 2, I.annealed_copper_cable, 1, I.processing_unit, 1, nil, nil, I.titanium_drill, 4, nil, nil, 8)
	m(I.bronze_curved_plate, 6, I.copper_rotor, 2, I.glass_pane, 1, nil, nil, I.fluid_pipe, 16, nil, nil, 8)
	m(I.bronze_curved_plate, 6, I.steel_gear, 2, nil, nil, I.item_pipe, 16, nil, nil, 8)
	m(I.steel_plate, 8, I.steel_gear, 1, nil, nil, I.steel_machine_casing, 1, nil, nil, 8)
	m(I.aluminum_cable, 6, I.silicon_battery, 1, I.electronic_circuit_board, 1, I.stainless_steel_plate, 4, nil, F.polyethylene, 750, nil, I.digital_circuit_board, 1, nil, nil, 16)
	m(I.annealed_copper_cable, 8, I.cadmium_battery, 2, I.digital_circuit_board, 1, I.platinum_plate, 4, nil, F.polyvinyl_chloride, 1500, nil, I.processing_unit_board, 1, nil, nil, 32)
	m(I.superconductor_cable, 12, I.plutonium_battery, 2, I.processing_unit_board, 1, I.iridium_plate, 6, nil, F.helium_3, 50, nil, I.quantum_circuit_board, 1, nil, nil, 64)
	m(I.fluid_pipe, 3, I.stainless_steel_rotor, 3, I.advanced_motor, 1, nil, F.soldering_alloy, 200, nil, I.advanced_pump, 1, nil, nil, 8)
	m(I.gold_plate, 2, I.copper_wire, 2, I.rubber_sheet, 1, nil, nil, I.capacitor, 4, nil, nil, 8)
	m(I.fluid_pipe, 3, I.small_heat_exchanger, 2, I.tin_plate, 6, nil, F.cryofluid, 1000, nil, I.cooling_cell, 1, nil, nil, 16)
	m(I.copper_wire, 8, I.steel_rod, 1, nil, nil, I.inductor, 4, nil, nil, 8)
	m(I.fluid_pipe, 3, I.tin_rotor, 3, I.motor, 1, nil, F.soldering_alloy, 100, nil, I.pump, 1, nil, nil, 8)
	m(I.copper_fine_wire, 2, I.coal_dust, 1, nil, nil, I.resistor, 12, nil, nil, 8)
	m(I.basic_upgrade, 4, I.large_motor, 2, I.large_pump, 1, I.electronic_circuit_board, 1, nil, F.polyethylene, 1000, nil, I.advanced_upgrade, 4, nil, nil, 8)
	m(I.conveyor, 2, I.motor, 4, I.robot_arm, 2, I.analog_circuit_board, 1, nil, F.polyethylene, 500, nil, I.basic_upgrade, 4, nil, nil, 8)
	m(I.large_advanced_motor, 8, I.large_advanced_pump, 4, I.turbo_upgrade, 4, I.processing_unit_board, 1, nil, F.polyvinyl_chloride, 2500, nil, I.highly_advanced_upgrade, 4, nil, nil, 32)
	m(I.highly_advanced_upgrade, 32, I.quantum_circuit, 8, I.singularity, 1, I.quantum_circuit_board, 1, nil, F.uu_matter, 50, nil, I.quantum_upgrade, 1, nil, nil, 32)
	m(I.advanced_motor, 16, I.advanced_pump, 2, I.advanced_upgrade, 4, I.digital_circuit_board, 1, nil, F.polyvinyl_chloride, 1000, nil, I.turbo_upgrade, 4, nil, nil, 16)
	m(I.aluminum_plate, 8, I.glass, 1, nil, nil, I.aluminum_tank, 1, nil, nil, 8)
	m(I.industrial_tnt, 6, I.plutonium_ingot, 4, I.processing_unit, 2, I.nuclear_alloy_plate, 4, nil, F.tritium, 50, F.deuterium, 100, nil, I.nuke, 2, nil, nil, 32)
	m(I.superconductor_wire, 3, I.cooling_cell, 2, nil, F.polyvinyl_chloride, 1000, nil, I.superconductor_cable, 6, nil, nil, 32)
	m(I.cupronickel_cable, 8, nil, nil, I.cupronickel_coil, 1, nil, nil, 8)
	m(I.kanthal_cable, 8, nil, nil, I.kanthal_coil, 1, nil, nil, 8)
	m(I.superconductor_cable, 8, nil, nil, I.superconductor_coil, 1, nil, nil, 8)
	m(I.tungstensteel_cable, 8, nil, nil, I.tungstensteel_coil, 1, nil, nil, 8)
	m(I.aluminum_plate, 3, I.gold_ingot, 2, I.calculation_processor, 1, nil, F.molten_redstone, 100, nil, I.basic_card, 2, nil, nil, 8)
	m(I.printed_calculation_processor, 1, I.printed_silicon, 1, nil, F.molten_redstone, 100, nil, I.calculation_processor, 1, nil, nil, 8)
	m(I.battery_alloy_plate, 1, I.annealed_copper_cable, 2, I.battery_alloy_curved_plate, 4, I.cadmium_dust, 2, nil, F.lithium, 100, nil, I.cadmium_battery, 2, nil, nil, 8)
	m(I.calorite_plate, 8, I.calorite_gear, 1, nil, nil, I.calorite_machine_casing, 1, nil, nil, 16)
	m(I.calorite_machine_casing, 1, I.calorite_curved_plate, 6, nil, nil, I.calorite_machine_casing_pipe, 1, nil, nil, 16)
	m(I.desh_drill_head, 1, I.item_pipe, 2, I.enderium_gear, 2, I.large_advanced_motor, 2, I.processing_unit, 1, I.annealed_copper_wire, 1, nil, nil, I.desh_drill, 4, nil, nil, 16)
	m(I.resistor, 4, I.transistor, 4, I.diode, 1, nil, F.polytetrafluoroethylene, 50, nil, I.op_amp, 1, nil, nil, 8)
	m(I.battery_alloy_plate, 1, I.superconductor_cable, 2, I.battery_alloy_curved_plate, 4, I.plutonium_dust, 2, nil, F.lithium, 100, nil, I.plutonium_battery, 2, nil, nil, 8)
	m(I.polytetrafluoroethylene_plate, 8, I.polytetrafluoroethylene_gear, 1, nil, nil, I.chemically_inert_ptfe_casing, 1, nil, nil, 8)
	m(I.chemically_inert_ptfe_casing, 1, I.polytetrafluoroethylene_curved_plate, 6, nil, nil, I.polytetrafluoroethylene_machine_casing_pipe, 1, nil, nil, 8)
	m(I.arithmetic_logic_unit, 2, I.carbon_plate, 2, I.tungstensteel_plate, 2, I.superconductor_wire, 6, nil, F.cryofluid, 250, F.tritium, 50, nil, I.qbit, 1, nil, nil, 20)
	m(I.battery_alloy_plate, 1, I.aluminum_cable, 2, I.battery_alloy_curved_plate, 4, I.sodium_dust, 2, nil, F.lithium, 100, nil, I.sodium_battery, 2, nil, nil, 8)
	m(I.steel_plate, 5, I.motor, 1, nil, nil, I.hopper, 2, nil, "Hopper from Assembler", 8)



	m(I.blastproof_alloy_curved_plate, 2, I.large_motor, 1, I.robot_arm, 2, I.cadmium_rod, 18, nil, F.soldering_alloy, 500, F.helium, 100, nil, I.cadmium_control_rod, 1, nil, nil, 16)
	m(I.blastproof_alloy_curved_plate, 2, I.large_motor, 1, I.robot_arm, 2, I.uranium_rod, 18, nil, F.soldering_alloy, 500, F.helium, 100, nil, I.uranium_fuel_rod, 1, nil, nil, 16)
	m(I.blastproof_alloy_curved_plate, 2, I.large_motor, 1, I.robot_arm, 2, I.le_uranium_rod, 18, nil, F.soldering_alloy, 500, F.helium, 100, nil, I.le_uranium_fuel_rod, 1, nil, nil, 16)
	m(I.blastproof_alloy_curved_plate, 2, I.large_motor, 1, I.robot_arm, 2, I.he_uranium_rod, 18, nil, F.soldering_alloy, 500, F.helium, 100, nil, I.he_uranium_fuel_rod, 1, nil, nil, 16)
	m(I.blastproof_alloy_curved_plate, 2, I.large_motor, 1, I.robot_arm, 2, I.le_mox_rod, 18, nil, F.soldering_alloy, 500, F.helium, 100, nil, I.le_mox_fuel_rod, 1, nil, nil, 16)
	m(I.blastproof_alloy_curved_plate, 2, I.large_motor, 1, I.robot_arm, 2, I.he_mox_rod, 18, nil, F.soldering_alloy, 500, F.helium, 100, nil, I.he_mox_fuel_rod, 1, nil, nil, 16)
end
-------------------------------------------------
do -- Process Chains
	local chemHead = Recipes.makeSingleChemicalReactorRecipe
	local blastCuprRaw = Recipes.makeSingleRecipeMaker(MultiblockMachine.blastFurnaceCupr, true, true, true, true)
	local blastKantRaw = Recipes.makeSingleRecipeMaker(MultiblockMachine.blastFurnaceKant, true, true, true, true)
	local blastTungRaw = Recipes.makeSingleRecipeMaker(MultiblockMachine.blastFurnaceTung, true, true, true, true)
	local blastKantHead = function(...)
		return RecipeList:new {
			blastKantRaw(...), 
			blastTungRaw(...)
		}
	end
	local blastCuprHead = function(...)
		return RecipeList:new {
			blastCuprRaw(...),
			blastKantRaw(...),
			blastTungRaw(...)
		}
	end
	local chemChain = Recipes.makeChainRecipeMaker(Machine.chemical_reactor, true, true)
	local chemBigChain = Recipes.makeChainRecipeMaker(MultiblockMachine.chemicalReactorLarge, true, true)
	local elecChain = Recipes.makeChainRecipeMaker(Machine.electrolyzer, true, true)
	local centChain = Recipes.makeChainRecipeMaker(Machine.centrifuge, true, true)

	do -- Chromium tiny dust production
		local name = "Chromium Chain"
		chemHead(I.chromium_crushed_dust, 1, nil, F.hydrochloric_acid, 9000, nil, I.chromium_tiny_dust, 3 * 9, nil, F.hydrogen, 450 * 9, F.chlorine, 450 * 9, nil, name, 8):setChainHead(
			Ctlg:new {}
		):filterEffOutput(I.chromium_tiny_dust)
		elecChain(nil, F.chromium_hydrochloric_solution, 1000, nil, name .. ": 1", 16)
	end
	do -- Platinum tiny dust production
		local name = "Platinum Chain"
		chemHead(I.raw_platinum, 1, nil, F.sulfuric_acid, 9000, nil, I.platinum_tiny_dust, 3 * 9, nil, F.sulfuric_acid, 900 * 9, nil, name, 8):setChainHead(
			Ctlg:new {}
		):filterEffOutput(I.platinum_tiny_dust)
		centChain(nil, F.platinum_sulfuric_solution, 1000, nil, name .. ": 1", 8)
		elecChain(nil, F.purified_platinum_sulfuric_solution, 1000, nil, name .. ": 2", 32)
	end
	do -- polytetrafluoroethylene production
		local name = "Polything Chain"
		blastCuprHead(I.fluorite_dust, 3, nil, nil, nil, F.hydrochloric_acid, 7500, F.polytetrafluoroethylene, 2000, nil, name, 16):setChainHead(
			Ctlg:new {
				[F.hydrogen] = 3000,
				[F.chloroform] = 3000,
				[F.oxygen] = 5000,
			}
		):filterEffOutput(F.polytetrafluoroethylene)
		chemBigChain(nil, F.fluorine, 1000 * 4, F.hydrogen, 1000 * 4, nil, name .. ": 1 Large", 48)
		chemChain(nil, F.fluorine, 1000, F.hydrogen, 1000, nil, name .. ": 1", 24)
		chemBigChain(nil, F.hydrofluoric_acid, 2000 * 4, F.chloroform, 1000 * 4, nil, name .. ": 2 Large", 48)
		chemChain(nil, F.hydrofluoric_acid, 2000, F.chloroform, 1000, nil, name .. ": 2", 24)
		chemBigChain(nil, F.tetrafluoroethylene, 300 * 4, F.oxygen, 1000 * 4, nil, name .. ": 3", 48)
		chemChain(nil, F.tetrafluoroethylene, 300, F.oxygen, 1000, nil, name .. ": 3", 24)
	end
end
-------------------------------------------------
do -- Test Recipes
	local m = Recipes.makeSingleRecipeMaker(CustomMachine.trashCan, true, true, false, false)
	m(I.emerald_tiny_dust, 16, nil, nil, "eme", 0):setPaddings(I.emerald_tiny_dust, 64):setAlwaysProc()
end
-------------------------------------------------
local function recipeSort(a, b)
	if a.alwaysProc then
		return true
	elseif a.priority > b.priority then
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

--- Recipe Validation (no cycles)
local function checkCycles()
	local ctlgs = {
		inputs = {},
		outputs = {}
	}
	local recipeCnt = #Recipes
	local safeSubtreeSet = {}
	
	for idx, r in ipairs(Recipes) do
		table.insert(ctlgs.inputs, Helper.IO2Catalogue(r.unitInput))
		table.insert(ctlgs.outputs, r.effUnitOutputCtlg)
	end

	local function listConcat(l, toConcat)
		for _, v in ipairs(toConcat) do
			table.insert(l, v)
		end
	end

	local function getRecipesHaveInput(fromMat)
		local ret = {}
		for idx = 1, recipeCnt do
			if ctlgs.inputs[idx][fromMat] ~= nil then
				table.insert(ret, idx)
			end
		end
		return ret
	end

	local function getConnectedRecipes(recipeIdx)
		local ret = {}
		for m, amt in pairs(ctlgs.outputs[recipeIdx]) do
			local singleRet = getRecipesHaveInput(m)
			listConcat(ret, singleRet)
		end
		return ret
	end

	local function getErrorMessage(toCheckIdx, stackTrace)
		local ret = "Cycle detected: \n"
		for _, ridx in ipairs(stackTrace) do
			if ridx == toCheckIdx then
				ret = ret .. "\t\t" .. Recipes[ridx].dispName .. " <\n"
			else
				ret = ret .. "\t" .. Recipes[ridx].dispName .. "\n"
			end
		end
		ret = ret .. "\t\t" .. Recipes[toCheckIdx].dispName .. " <"
		return ret
	end

	local function recipeCycleChecker(toCheckIdx, stackTrace, depth)
		stackTrace = stackTrace or {}
		depth = depth or 1
		for ii = 1, #stackTrace do
			if toCheckIdx == stackTrace[ii] then
				-- Cycle detected
				error(getErrorMessage(toCheckIdx, stackTrace))
				-- safeSubtreeSet[toCheckIdx] = true
				return
			end
		end
		
		if safeSubtreeSet[toCheckIdx] then
			return
		end
		local conns = getConnectedRecipes(toCheckIdx)
		for _, cridx in ipairs(conns) do
			local nextStack = {}
			for _, v in ipairs(stackTrace) do
				table.insert(nextStack, v)
			end
			table.insert(nextStack, toCheckIdx)
			recipeCycleChecker(cridx, nextStack, depth + 1)
		end
		safeSubtreeSet[toCheckIdx] = true
	end

	for ridx = 1, recipeCnt do
		recipeCycleChecker(ridx)
	end
	print("Cycle test Done!")
end

-- checkCycles()

do -- Make production Graph
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
	for _, r in ipairs(Recipes) do
		if (not r.alwaysProc) and (not r.opportunistic) then
			for mat, amt in pairs(r.effUnitOutputCtlg) do
				prodDict[mat] = prodDict[mat] or {}
				local unit = preciseCtlgMult(r.effUnitInputCtlg:copy(), 1 / amt)
				if find(prodDict[mat], unit) == 0 then
					table.insert(prodDict[mat], unit)
				end
			end
		end
	end
	Recipes.productionGraph = prodDict
end

return Recipes