local Prefix = require("Dict").Prefix
local I = require("Dict").Item
local Fluid = require("Dict").Fluid
local DirectProd = require("Dict").DirectProd
local Ctlg = require("__Catalouge")
local Helper = require("__Helpers")

local mi = Prefix.moin
local tr = Prefix.techReborn
local va = Prefix.vanilla
local cr = Prefix.create
local ad = Prefix.adAstra

local Goals = {}
Goals.SeedGoalsCtlg = Ctlg:new()

local function goalMaker(gs)
	for k, v in pairs(gs) do
		if DirectProd[k] ~= nil then
			error(k .. " is direct production, Cannot set the goal.")
		end
		Goals.SeedGoalsCtlg[k] = v
	end
end

local _X = 32
local _XX = 64
local _XXXX = 128
local _XXXXXXXX = 256
local _XXXXXXXXXXXXXXXX = 512
local _XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX = 1024
local _XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX = 2048

if false then
	-- Producers
	goalMaker {
		[I.copper_drill]					= _X,
		[I.bronze_drill]					= _X,
		[I.gold_drill]						= _X,
		[I.steel_drill]						= _X,
		[I.aluminum_drill]					= _X,
		[I.titanium_drill]					= _X,
		[I.desh_drill]						= _X,
		[I.stainless_steel_drill]			= _X,
	}

	-- Primitive crushed ores & raw ores & big dusts
	goalMaker {
		-- Bronze Drill
		[I.raw_iron]						= _XXXXXXXX,
		[I.iron_dust]						= _XXXXXXXXXXXXXXXX,
		[I.coal_crushed_dust]				= _XXXXXXXX,
		[I.coal_dust]						= _XXXXXXXX,
		[I.lignite_coal_crushed_dust]		= _XXXX,
		[I.lignite_coal_dust]				= _XXXX,
		[I.raw_copper]						= _XXXXXXXX,
		[I.copper_dust]						= _XXXXXXXX,
		[I.raw_tin]							= _XXXX,
		[I.tin_dust]						= _XXXX,
		[I.raw_gold]						= _XXXX,
		[I.gold_dust]						= _XXXX,
		[I.raw_lead]						= _XXXX,
		[I.lead_dust]						= _XXXX,
		[I.raw_silver]						= _XXXX,
		[I.silver_dust]						= _XXXX,
		[I.redstone_crushed_dust]			= _XXXX,
		[I.redstone]						= _XXXXXXXX,
		[I.galena_dust]						= _XXXX,

		-- Gold Drill

		-- Steel Drill
		[I.raw_antimony]					= _XXXX,
		[I.antimony_dust]					= _XXXX,
		[I.raw_fluorite]					= _XXXX,
		[I.fluorite_dust]					= _XXXX,
		[I.diamond_crushed_dust]			= _XXXX,
		[I.diamond_dust]					= _XXXX,
		[I.lapis_crushed_dust]				= _XXXX,
		[I.lapis_dust]						= _XXXX,
		[I.raw_lead]						= _XXXX,
		[I.lead_dust]						= _XXXX,
		[I.raw_nickel]						= _XXXXXXXX,
		[I.nickel_dust]						= _XXXXXXXX,
		[I.bauxite_crushed_dust]			= _XXXXXXXXXXXXXXXX,
		[I.bauxite_dust]					= _XXXXXXXXXXXXXXXX,
		[I.salt_crushed_dust]				= _XXXX,
		[I.salt_dust]						= _XXXX,
		[I.emerald_crushed_dust]			= _XXXX,
		[I.emerald_dust]					= _XXXX,
		[I.quartz_crushed_dust]				= _XXXX,
		[I.quartz_dust]						= _XXXX,
		[I.ruby_dust]						= _XXXXXXXX,
		[I.sapphire_dust]					= _XXXX,

		-- Stainless Steel Drill
		[I.raw_titanium]					= _XXXX,
		[I.raw_tungsten]					= _XXXX,
		[I.tungsten_dust]					= _XXXX,
		[I.mozanite_crushed_dust]			= _XXXXXXXX,
		[I.mozanite_dust]					= _XXXXXXXX,
		[I.raw_platinum]					= _XXXX,
		[I.peridot_dust]					= _XXXX,
		[I.sodalite_dust]					= _XXXXXXXX,

		-- Titanium Drill
		[I.raw_uranium]						= _XXXX,
		[I.uranium_dust]					= _XXXX,
		[I.raw_iridium]						= _XXXX,
		[I.iridium_dust]					= _XXXX,
	}

	-- Other dusts (mixed ones)
	goalMaker {
		[I.battery_alloy_dust]				= _XXXX,
		[I.bronze_dust]						= _XXXX,
		[I.electrum_dust]					= _XXXX,
		[I.invar_dust]						= _XXXX,
		[I.cupronickel_dust]				= _XXXX,
		[I.kanthal_dust]					= _XXXX,
		[I.stainless_steel_dust]			= _XXXX,
		[I.uncooked_steel_dust]				= _XXXX,
		[I.superconductor_dust]				= _XXXX,
	}

	-- Tiny dusts (whether useful or tiny form is main product)
	goalMaker {
		[I.platinum_tiny_dust]				= _XXXXXXXX, -- Main product & useful
		[I.chromium_tiny_dust]				= _XXXXXXXX, -- Main product & useful
		[I.manganese_tiny_dust]				= _XXXXXXXX, -- Main product

		[I.lead_tiny_dust]					= _XXXXXXXX, -- (Very) useful
		[I.beryllium_tiny_dust]				= _XXXX, -- Useful
		[I.tungsten_tiny_dust]				= _XXXX, -- Useful
		[I.antimony_tiny_dust]				= _XXXX, -- Useful
		[I.aluminum_tiny_dust]				= _XXXX, -- Useful
		[I.iridium_tiny_dust]				= _XX, -- Useful (Monocrystalline Silicon)
		[I.nickel_tiny_dust]				= _XX, -- (Not really) useful
	}

	-- Ingots
	goalMaker {
		[I.copper_ingot]					= _XXXX,
		[I.iron_ingot]						= _XXXX,
		[I.tin_ingot]						= _XXXX,
		[I.bronze_ingot]					= _XXXX,
		[I.gold_ingot]						= _XX,
		[I.silver_ingot]					= _X,
		[I.aluminum_ingot]					= _XXXX,
		[I.electrum_ingot]					= _XXXX,
		[I.invar_ingot]						= _XXXX,
		[I.battery_alloy_ingot]				= _XXXX,
		[I.silicon_ingot]					= _XXXX,
		[I.steel_ingot]						= _XXXX,
		[I.cupronickel_ingot]				= _XXXX,
		[I.annealed_copper_ingot]			= _XXXX,
		[I.platinum_ingot]					= _XXXX,
		[I.tungstensteel_ingot]				= _XXXX,
		[I.kanthal_ingot]					= _XXXX,
		[I.stainless_steel_ingot]			= _XXXX,
	}

	-- Parts
	goalMaker {
		[I.copper_plate]					= _XXXX,
		[I.copper_curved_plate]				= _XXXX,
		[I.bronze_plate]					= _XXXX,
		[I.bronze_curved_plate]				= _XXXX,
		[I.gold_plate]						= _XX,
		[I.gold_curved_plate]				= _X,
		[I.battery_alloy_plate]				= _XXXX,
		[I.battery_alloy_curved_plate]		= _XXXX,
		[I.aluminum_plate]					= _XXXX,
		[I.aluminum_curved_plate]			= _XXXX,
		[I.electrum_plate]					= _XXXX,
		[I.silver_plate]					= _X,
		[I.tin_plate]						= _XXXX,
		[I.tin_curved_plate]				= _XXXX,
		[I.iron_plate]						= _XXXX,
		[I.invar_plate]						= _XXXX,
		[I.steel_plate]						= _XXXX,
		[I.steel_curved_plate]				= _XXXX,
		[I.stainless_steel_plate]			= _XXXX,
		[I.stainless_steel_curved_plate]	= _XXXX,
		[I.cupronickel_plate]				= _XXXX,
		[I.calorite_plate]					= _XXXX,
		[I.calorite_curved_plate]			= _XXXX,
		[I.desh_plate]						= _XXXX,
		[I.desh_curved_plate]				= _XXXX,
		[I.annealed_copper_plate]			= _XXXX,
		[I.platinum_plate]					= _XXXX,
		[I.tungstensteel_plate]				= _XXXX,
		[I.tungstensteel_curved_plate]		= _XXXX,
		[I.kanthal_plate]					= _XXXX,

		[I.copper_rod]						= _XXXX,
		[I.bronze_rod]						= _XXXX,
		[I.gold_rod]						= _X,
		[I.aluminum_rod]					= _XXXX,
		[I.tin_rod]							= _XXXX,
		[I.iron_rod]						= _XXXX,
		[I.invar_rod]						= _XXXX,
		[I.steel_rod]						= _XXXX,
		[I.calorite_rod]					= _XXXX,
		[I.desh_rod]						= _XXXX,
		[I.tungstensteel_rod]				= _XXXX,
		[I.stainless_steel_rod]				= _XXXX,

		[I.copper_ring]						= _XXXX,
		[I.bronze_ring]						= _XXXX,
		[I.gold_ring]						= _X,
		[I.aluminum_ring]					= _XXXX,
		[I.tin_ring]						= _XXXX,
		[I.iron_ring]						= _XXXX,
		[I.invar_ring]						= _XXXX,
		[I.steel_ring]						= _XXXX,
		[I.calorite_ring]					= _XXXX,
		[I.desh_ring]						= _XXXX,
		[I.tungstensteel_ring]				= _XXXX,
		[I.stainless_steel_ring]			= _XXXX,
		
		[I.copper_gear]						= _X,
		[I.bronze_gear]						= _XXXX,
		[I.gold_gear]						= _X,
		[I.aluminum_gear]					= _XXXX,
		[I.tin_gear]						= _X, -- Minimum use
		[I.iron_gear]						= _XXXX,
		[I.invar_gear]						= _XXXX,
		[I.steel_gear]						= _XXXX,
		[I.calorite_gear]					= _X, -- Minimum use
		[I.desh_gear]						= _XXXX,
		[I.tungstensteel_gear]				= _X, -- No use
		[I.stainless_steel_gear]			= _XXXX,

		[I.copper_blade]					= _X,
		[I.bronze_blade]					= _X,
		[I.aluminum_blade]					= _XX,
		[I.tin_blade]						= _XXXX,
		[I.stainless_steel_blade]			= _XXXX,

		[I.copper_rotor]					= _XXXX,
		[I.bronze_rotor]					= _XXXX,
		[I.aluminum_rotor]					= _XX,
		[I.tin_rotor]						= _XXXX,
		[I.stainless_steel_rotor]			= _XXXX,
		
		[I.copper_wire]						= _XXXX,
		[I.copper_fine_wire]				= _XXXX,
		[I.aluminum_wire]					= _XXXX,
		[I.electrum_wire]					= _XXXXXXXX,
		[I.electrum_fine_wire]				= _XXXXXXXX,
		[I.silver_wire]						= _X,
		[I.tin_wire]						= _XXXX,
		[I.cupronickel_wire]				= _XXXX,
		[I.annealed_copper_wire]			= _XXXX,
		[I.platinum_wire]					= _XXXX,
		[I.platinum_fine_wire]				= _XXXX,
		[I.tungstensteel_wire]				= _XXXX,
		[I.kanthal_wire]					= _XXXX,

		[I.copper_drill_head]				= _X,
		[I.bronze_drill_head]				= _X,
		[I.gold_drill_head]					= _X,
		[I.aluminum_drill_head]				= _X,
		[I.steel_drill_head]				= _X,
		[I.desh_drill_head]					= _X,
		[I.stainless_steel_drill_head]		= _X,

	}
	
	-- Chips related
	goalMaker {
		-- Analog
		[Fluid.raw_synthetic_oil]			= _X * 1000,
		[Fluid.synthetic_oil]				= _X * 1000,
		[Fluid.synthetic_rubber]			= _X * 1000,
		[I.rubber_sheet]					= _XXXX,
		[I.resistor]						= _XXXX,
		[I.inductor]						= _XXXX,
		[I.capacitor]						= _XXXX,
		[I.analog_circuit_board]			= _XXXX,
		[I.analog_circuit]					= _XXXX,
		[I.silicon_dust]					= _XXXX,
		[I.silicon_plate]					= _XXXX,

		-- Electronic
		[I.aluminum_tiny_dust]				= _XXXX,
		[I.antimony_tiny_dust]				= _XXXX,
		[I.silicon_p_doped_plate]			= _XXXX,
		[I.silicon_n_doped_plate]			= _XXXX,
		[I.diode]							= _XXXX,
		[I.transistor]						= _XXXX,
		[I.electronic_circuit_board]		= _XXXX,
		[I.electronic_circuit]				= _XXXX,
	}
	
	-- Special needs
	goalMaker {
		[I.steel_dust]						= _XXXX,
		[I.annealed_copper_dust]			= _XXXX,
	}

	-- Other Basic Materials
	goalMaker {
		[I.coke_dust]						= _XXXX,
		[I.paper]							= _XXXX,
		[I.gravel]							= _XXXX,
		[I.sand]							= _XXXX,
		[I.glass]							= _XXXX,
		[I.glass_pane]						= _XXXX,
	}

	-- Progress Related
	goalMaker {
		[I.fluid_pipe]						= _XXXX,
		[I.item_pipe]						= _XXXX,

		[I.tin_cable]						= _XXXX,
		[I.copper_cable]					= _XXXX,
		[I.steel_rod_magnetic]				= _XXXX,
		[I.motor]							= _XXXX,
		[I.pump]							= _XXXX,
		[I.conveyor]						= _XXXX,
		[I.piston]							= _XXXX,
		[I.robot_arm]						= _XXXX,
		[I.steel_machine_casing]			= _XXXX,
		[I.redstone_battery]				= _XXXX,
		[I.basic_machine_hull]				= _XXXX,
		[I.cupronickel_wire_magnetic]		= _XX,
		[I.cupronickel_cable]				= _XX,
		[I.electrum_cable]					= _XXXX,
		[I.advanced_machine_casing]			= _XXXX,
		[I.silicon_battery]					= _XXXX,
		[I.advanced_machine_hull]			= _XXXX,
		[I.large_motor]						= _XXXX,
		[I.large_pump]						= _XXXX
	}
else
	goalMaker {
		[I.emerald_tiny_dust] = 64 * 9,
		[I.emerald_dust] = 64
	}
end

local function makeAutoGoals(seedGoals, dps, prodGraph)
	-- local cnt = 0
	-- for mat, methods in pairs(prodGraph) do
	-- 	if #methods > 1 then
	-- 		cnt = cnt + 1
	-- 		print(Helper.dispNameMaker(mat), #methods, cnt)
	-- 	end
	-- end

	local tmpGoals = Ctlg:new()
	local hasChainSet = {}

	local function hasValidChain(id)
		if hasChainSet[id] ~= nil then
			return hasChainSet[id]
		end
	
		local methods = prodGraph[id]
		if methods == nil then
			if dps[id] == nil then
				print("WARN:", id, "does not have recipe! (Is it Direct Product?)")
				-- Fail to make production chain; Goal should NOT be made.
				hasChainSet[id] = false
				return false
			else
				-- Succeed to make production chain; Goal should be made.
				hasChainSet[id] = true
				return true
			end
		end
		local ret = false
		for _, unitCltg in ipairs(methods) do
			local isValidMethod = true
			for matID in pairs(unitCltg) do
				isValidMethod = isValidMethod and hasValidChain(matID)
			end
			ret = ret or isValidMethod
		end

		hasChainSet[id] = ret
		return ret
	end

	local function addDerivedGoalsFor(targetItem, amt)
		if dps[targetItem] ~= nil then
			-- Is Direct product; no goals set.
			return
		end
		tmpGoals[targetItem] = (tmpGoals[targetItem] or 0) + amt
		if not hasValidChain(targetItem) then
			-- Does not have any valid production chain, but just.. put it in the goals.
			return
		end

		local methods = prodGraph[targetItem]
		local validMethods = {}
		for _, unitCltg in ipairs(methods) do
			local isValidMethod = true
			for matID, matAmt in pairs(unitCltg) do
				isValidMethod = isValidMethod and hasValidChain(matID)
			end
			if isValidMethod then
				table.insert(validMethods, unitCltg)
			end
		end
		
		for _, unitCtlg in ipairs(validMethods) do
			for matID, matAmt in pairs(unitCtlg) do
				matAmt = matAmt * amt / #validMethods
				addDerivedGoalsFor(matID, matAmt)
			end
		end
	end

	for id, amt in pairs(seedGoals) do
		addDerivedGoalsFor(id, amt)
	end
	tmpGoals:map(function(_, amt) return math.ceil(amt) end)
	Helper.printPretty(tmpGoals)
	return tmpGoals
end

function Goals.init(directProducts, prodGraph)
	Goals.DerivedGoalsCtlg = makeAutoGoals(Goals.SeedGoalsCtlg, directProducts, prodGraph)
end

return Goals