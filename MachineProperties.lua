local M = require("Dict").Machine
local I = require("Dict").Item

local Property = {
	OutputItemSlotCount = {
		[M.electric_compressor] = 1,
		[M.electric_cutting_machine] = 1,
		[M.electric_furnace] = 1,
		[M.electric_macerator] = 4,
		[M.electric_mixer] = 2,
		[M.electric_packer] = 1,
		[M.electric_unpacker] = 2,
		[M.electric_wiremill] = 1,
		[M.centrifuge] = 4,
		[M.electrolyzer] = 4,
		[M.assembler] = 3,
		[M.chemical_reactor] = 3,
		[M.polarizer] = 1,
		[M.alloy_smelter] = 1,

		[I.bronze_item_output_hatch] = 1,
		[I.steel_item_output_hatch] = 2,
		[I.advanced_item_output_hatch] = 4,
		[I.turbo_item_output_hatch] = 9,
		[I.highly_advanced_item_output_hatch] = 15,
	},
	OutputFluidSlotCount = {
		[M.electric_compressor] = 0,
		[M.electric_cutting_machine] = 0,
		[M.electric_furnace] = 0,
		[M.electric_macerator] = 0,
		[M.electric_mixer] = 2,
		[M.electric_packer] = 0,
		[M.electric_unpacker] = 0,
		[M.electric_wiremill] = 0,
		[M.centrifuge] = 4,
		[M.electrolyzer] = 4,
		[M.assembler] = 0,
		[M.chemical_reactor] = 3,
		[M.polarizer] = 0,
		[M.alloy_smelter] = 0,
		
		[I.bronze_fluid_output_hatch] = 1,
		[I.steel_fluid_output_hatch] = 1,
		[I.advanced_fluid_output_hatch] = 1,
		[I.turbo_fluid_output_hatch] = 1,
		[I.highly_advanced_fluid_output_hatch] = 1,
	}
}

return Property