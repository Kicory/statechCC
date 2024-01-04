local MM = require("Dict").MultiblockMachine
local OM = require("Dict").CustomMachine

local OtherMachines = {}

OtherMachines.BigMachines = {
	[MM.smelterMega] = {
		["modern_industrialization:mega_smelter_1"] = {
			wrapped = nil, -- will filled by __Machines.refreshMachines

			hasFluid = false, -- Only consider input hatches
			fluidInputs = {
				
			},
			hasItem = true, -- Only consider input hatches
			itemInput = "modern_industrialization:bronze_item_input_hatch_1", 
			-- No need to contain output hatches; Chef will auto-detect all output hatches.
			
			getBasePower = nil, -- will filled by __Machines.refreshMachines
			isBusy = nil, -- will filled by __Machines.refreshMachines
		}
	},
	--
	[MM.chemicalReactorLarge] = {
	 	["modern_industrialization:large_chemical_reactor_2"] = {
	 		hasFluid = true,
	 		fluidInputs = {
	 			"modern_industrialization:highly_advanced_fluid_input_hatch_1",
	 			"modern_industrialization:highly_advanced_fluid_input_hatch_2",
	 			"modern_industrialization:highly_advanced_fluid_input_hatch_3",
	 		},
	 		hasItem = true,
	 		itemInput = "modern_industrialization:advanced_item_input_hatch_0",
	 	}
	}
	--]]
}

OtherMachines.CustomMachines = {
	[OM.trashCan] = {
		["modern_industrialization:trash_can_0"] = {
			hasFluid = true,
			fluidInputs = {
				"modern_industrialization:configurable_tank_6",
			},
			hasItem = true,
			itemInput = "modern_industrialization:configurable_chest_6",
		}
	}
}

return OtherMachines