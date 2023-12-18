require("Dict")

BigMachines = {
	[MultiblockMachine.smelterMega] = {
		["modern_industrialization:mega_smelter_1"] = {
			wrapped = nil, -- will filled by __Machines.refreshMachines

			hasFluid = false,
			fluidInputs = {
				
			},
			fluidOutputs = {

			},
			hasItem = true,
			itemInput = "modern_industrialization:bronze_item_input_hatch_1",
			itemOutput = "modern_industrialization:bronze_item_output_hatch_1",
			
			getBasePower = nil, -- will filled by __Machines.refreshMachines
			isBusy = nil, -- will filled by __Machines.refreshMachines
		}
	},
	--
	[MultiblockMachine.chemicalReactorLarge] = {
	 	["modern_industrialization:large_chemical_reactor_2"] = {
	 		hasFluid = true,
	 		fluidInputs = {
	 			"modern_industrialization:highly_advanced_fluid_input_hatch_1",
	 			"modern_industrialization:highly_advanced_fluid_input_hatch_2",
	 			"modern_industrialization:highly_advanced_fluid_input_hatch_3",
	 		},
	 		fluidOutputs = {
	 			"modern_industrialization:advanced_fluid_output_hatch_0",
	 			"modern_industrialization:advanced_fluid_output_hatch_1",
	 			"modern_industrialization:advanced_fluid_output_hatch_2",
	 		},
	 		hasItem = true,
	 		itemInput = "modern_industrialization:advanced_item_input_hatch_0",
	 		itemOutput = "modern_industrialization:advanced_item_output_hatch_0",
	 	}
	}
	--]]
}