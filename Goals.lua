require("Dict")
local Ctlg = require("__Catalouge")

local Goals = Ctlg:new {
	[Item.copper_ingot] = 200,
	[Item.copper_plate] = 200,
	[Item.copper_curved_plate] = 200,
	[Item.copper_rod] = 20,
	[Item.copper_ring] = 10,
	[Item.copper_gear] = 20,
	[Item.copper_blade] = 30,
	[Item.copper_rotor] = 10,

	[Item.copper_wire] = 3000,

	[Item.bronze_plate] = 100,
	[Item.bronze_rod] = 20,
	[Item.bronze_curved_plate] = 20,
	[Item.bronze_ring] = 20,
	[Item.bronze_gear] = 20,
	[Item.bronze_blade] = 200,
	[Item.bronze_rotor] = 10,

	-- [Fluid.raw_biodiesel] = 24000,
}

return Goals