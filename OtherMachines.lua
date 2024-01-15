local MM = require("Dict").MultiblockMachine
local OM = require("Dict").CustomMachine
local F = require("Dict").Fluid

local OtherMachines = {}

OtherMachines.BigMachines = {
	[MM.blastFurnaceCupr] = {
		["modern_industrialization:electric_blast_furnace_0"] = {
			hasFluid = true,
			fluidInputs = {
				"modern_industrialization:bronze_fluid_input_hatch_2",
			},
			hasItem = true,
			itemInput = "modern_industrialization:steel_item_input_hatch_0",
		},
		["modern_industrialization:electric_blast_furnace_1"] = {
			hasFluid = true,
			fluidInputs = {
				"modern_industrialization:bronze_fluid_input_hatch_3",
			},
			hasItem = true,
			itemInput = "modern_industrialization:steel_item_input_hatch_1",
		}
	}
}

local trashCanConfChest = "modern_industrialization:configurable_chest_2"
local trashCanConfTank = "modern_industrialization:configurable_tank_0"
local trashCanInfo = {
	hasFluid = true,
	fluidInputs = {
		trashCanConfTank,
	},
	hasItem = true,
	itemInput = trashCanConfChest,
}

OtherMachines.CustomMachines = {
	[OM.trashCan] = {
		["trash_can_1"] = trashCanInfo,
		["trash_can_2"] = trashCanInfo,
		["trash_can_3"] = trashCanInfo,
		["trash_can_4"] = trashCanInfo,
		["trash_can_5"] = trashCanInfo,
		["trash_can_6"] = trashCanInfo,
		["trash_can_7"] = trashCanInfo,
		["trash_can_8"] = trashCanInfo,
		["trash_can_9"] = trashCanInfo,
	},
	[OM.advLargeBoiler] = {
		["Boiler_1"] = {
			hasFluid = true,
			fluidInputs = {
				"modern_industrialization:bronze_fluid_input_hatch_1",
			},
			hasItem = true,
			itemInput = "modern_industrialization:bronze_item_input_hatch_0",
		},
	},
	[OM.boilerWaterHatch] = {
		["Boiler_1_water"] = {
			hasFluid = true,
			fluidInputs = {
				"modern_industrialization:bronze_fluid_input_hatch_0"
			},
		}
	}
}

return OtherMachines