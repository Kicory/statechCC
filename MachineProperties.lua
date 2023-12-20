local M = require("Dict").Machine

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
	}
}

return Property