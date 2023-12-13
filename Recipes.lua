require("__RecipeMaker")

local I = Item
Recipes:makeCompressorRecipes(
	I.copper_ingot, I.copper_plate,
	I.copper_plate, I.copper_curved_plate,
	I.copper_rod, I.copper_ring,
	I.bronze_ingot, I.bronze_plate,
	I.bronze_plate, I.bronze_curved_plate,
	I.bronze_rod, I.bronze_ring,
	I.iron_ingot, I.iron_plate,
	I.iron_rod, I.iron_ring,
	I.battery_alloy_ingot, I.battery_alloy_plate,
	I.battery_alloy_plate, I.battery_alloy_curved_plate,
	I.carbon_dust, I.carbon_plate,
	I.electrum_ingot, I.electrum_plate,
	I.enderium_ingot, I.enderium_plate,
	I.enderium_rod, I.enderium_ring,
	I.gold_ingot, I.gold_plate,
	I.gold_plate, I.gold_curved_plate,
	I.gold_rod, I.gold_ring,
	I.silicon_ingot, I.silicon_plate,
	I.silver_ingot, I.silver_plate,
	I.steel_ingot, I.steel_plate,
	I.steel_plate, I.steel_curved_plate,
	I.steel_rod, I.steel_ring,
	I.tin_ingot, I.tin_plate,
	I.tin_plate, I.tin_curved_plate,
	I.tin_rod, I.tin_ring,
	I.invar_ingot, I.invar_plate,
	I.invar_rod, I.invar_ring,
	I.lead_ingot, I.lead_plate,
	I.aluminum_ingot, I.aluminum_plate,
	I.aluminum_plate, I.aluminum_curved_plate,
	I.aluminum_rod, I.aluminum_ring,
	I.beryllium_ingot, I.beryllium_plate,
	I.annealed_copper_ingot, I.annealed_copper_plate,
	I.cadmium_ingot, I.cadmium_plate,
	I.blastproof_alloy_ingot, I.blastproof_alloy_plate,
	I.chromium_ingot, I.chromium_plate,
	I.cupronickel_ingot, I.cupronickel_plate,
	I.kanthal_ingot, I.kanthal_plate,
	I.lignite_coal_dust, I.lignite_coal,
	I.nickel_ingot, I.nickel_plate,
	I.platinum_ingot, I.platinum_plate,
	I.stainless_steel_ingot, I.stainless_steel_plate,
	I.stainless_steel_plate, I.stainless_steel_curved_plate,
	I.stainless_steel_rod, I.stainless_steel_ring,
	I.polytetrafluoroethylene_ingot, I.polytetrafluoroethylene_plate,
	I.polytetrafluoroethylene_plate, I.polytetrafluoroethylene_curved_plate,
	I.polytetrafluoroethylene_rod, I.polytetrafluoroethylene_ring,
	I.titanium_ingot, I.titanium_plate,
	I.titanium_plate, I.titanium_curved_plate,
	I.titanium_rod, I.titanium_ring,
	I.tungsten_ingot, I.tungsten_plate,
	I.tungsten_ingot, I.tungstensteel_plate,
	I.tungstensteel_plate, I.tungstensteel_curved_plate,
	I.tungstensteel_rod, I.tungstensteel_ring,
	I.superconductor_ingot, I.superconductor_plate,
	I.iridium_plate, I.iridium_curved_plate
)

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

Recipes:new { dispName = "Tungsten Tiny Nugget",
	unitInput = {
		item = {
			[Item.tungsten_tiny_dust] = 1,
		},
		fluid = {}
	},
	unitOutput = {
		item = {
			[Item.tungsten_nugget] = 1
		}
	},
	machineTypes = {
		Machine.electric_compressor,
	},
	minimumPower = 32
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