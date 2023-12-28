local Machine = require("Dict").Machine
local MultiMachine = require("Dict").MultiblockMachine
local Item = require("Dict").Item
local Fluid = require("Dict").Fluid
local Helper = require("__Helpers")
local Ctlg = require("__Catalouge")

local function basePowerChecker(basePowerRequired)
	return function (machineInfo) return machineInfo.getBasePower() >= basePowerRequired end
end

local Recipes = {}

-- Mini class Recipe
local Recipe = {
	PRIO_ULTIMATE = 100,
	PRIO_HIGH = 90,
	PRIO_NORMAL = 80,
	PRIO_LOW = 70,
	PRIO_RELUCTANT = 60,
}

local recipeMt = {
	__index = Recipe
}

function Recipe:new(o)
	assert(o ~= nil)
	setmetatable(o, recipeMt)
	return o
end

function Recipe:setPriority(prio)
	self.priority = prio
	return self
end

--- Add to Recipes list
---@param specs table Recipe info
---@return table Added Recipe (Can be customized)
function Recipes.add(specs)
	if (not specs.dispName) or (type(specs.dispName) ~= "string") then error("Recipe Display Name not specified!:" .. debug.traceback()) end

	local dispName = specs.dispName

	if not specs.unitInput then error("No input for recipe: " .. dispName) end
	if not specs.unitOutput then error("No output for recipe: " .. dispName) end
	if not specs.machineType then error("No machine type specified for recipe: " .. dispName) end
	if not specs.minimumPower then error("No machine minimum power requirement: " .. dispName) end

	local order = #Recipes + 1
	local r = Recipe:new {
		-- Lower comes first
		rank = order,
		priority = Recipe.PRIO_NORMAL,
		dispName = specs.dispName,
		unitInput = specs.unitInput,
		unitOutput = specs.unitOutput,
		machineType = specs.machineType,
		minimumPower = specs.minimumPower,
	}
	Recipes[order] = r

	-- Return r to customize later
	return r
end

function Recipes.getMaterialsUsedEmptyCtlg()
	local ret = Ctlg:new()
	for _, r in ipairs(Recipes) do
		for id, _ in pairs(r.unitInput.item or {}) do
			ret[id] = 0
		end
		for id, _ in pairs(r.unitInput.fluid or {}) do
			ret[id] = 0
		end
		for id, _ in pairs(r.unitOutput.item or {}) do
			ret[id] = 0
		end
		for id, _ in pairs(r.unitOutput.fluid or {}) do
			ret[id] = 0
		end
	end
	return ret
end

--- Make basic compressor recipes. [ingot ID, double ingot ID, plate ID, curved plate ID, rod ID, ring ID]. Give "false" if there is no corresponding item.
function Recipes.makeCompressorRecipesBasic(...)
	local ps = table.pack(...)
	local function addOne(inputID, outputID, outputCnt, dispNamePostfix)
		if inputID and outputID then
			Recipes.add {
				dispName = Helper.dispNameMaker(outputID) .. dispNamePostfix,
				unitInput = {
					item = {
						[inputID] = 1
					}
				},
				unitOutput = {
					item = {
						[outputID] = outputCnt
					}
				},
				machineType = Machine.electric_compressor,
				minimumPower = 2
			}
		end
	end
	for idx = 1, #ps, 6 do
		local ingotID = ps[idx]
		local doubleIngotID = ps[idx + 1]
		local plateID = ps[idx + 2]
		local curvedPlateID = ps[idx + 3]
		local rodID = ps[idx + 4]
		local ringID = ps[idx + 5]
		addOne(doubleIngotID, plateID, 2, " from Double Ingot")
		addOne(ingotID, plateID, 1, "")
		addOne(plateID, curvedPlateID, 1, "")
		addOne(rodID, ringID, 1, "")
	end
end

--- Make other compressor recipes. [inputID, outputID, output amount, minimum energy]. Give "false" if there is no corresponding item.
function Recipes.makeCompressorRecipesCustom(...)
	local ps = table.pack(...)
	for idx = 1, #ps, 2 do
		local fromID = ps[idx]
		local toID = ps[idx + 1]
		Recipes.add {
			dispName = Helper.dispNameMaker(toID),
			unitInput = {
				item = {
					[fromID] = 1
				}
			},
			unitOutput = {
				item = {
					[toID] = 1
				}
			},
			machineType = Machine.electric_compressor,
			minimumPower = 2
		}
	end
end

--- Make rod recipes. [single Ingot ID, double ingot ID (if there's no double ingot, give false or nil; anything evaluated to 'false'), rod ID]
function Recipes.makeCutterRodRecipes(...)
	local ps = table.pack(...)
	for idx = 1, #ps, 3 do
		local fromID = ps[idx]
		local fromDoubleID = ps[idx + 1]
		local toID = ps[idx + 2]
		if fromDoubleID then
			Recipes.add {
				dispName = Helper.dispNameMaker(toID) .. " from Double",
				unitInput = {
					item = {
						[fromDoubleID] = 1
					},
					fluid = {
						[Fluid.lubricant] = 10
					}
				},
				unitOutput = {
					item = {
						[toID] = 4
					}
				},
				machineType = Machine.electric_cutting_machine,
				minimumPower = 2
			}
		end
		if fromID then
			Recipes.add {
				dispName = Helper.dispNameMaker(toID),
				unitInput = {
					item = {
						[fromID] = 1
					},
					fluid = {
						[Fluid.lubricant] = 10
					}
				},
				unitOutput = {
					item = {
						[toID] = 2
					}
				},
				machineType = Machine.electric_cutting_machine,
				minimumPower = 2
			}
		end
	end
end

--- Make blade recipes. [Curved plate ID, rod ID, blade ID]
function Recipes.makePackerBladeRecipes(...)
	local ps = table.pack(...)
	for idx = 1, #ps, 3 do
		local curvedID = ps[idx]
		local rodID = ps[idx + 1]
		local bladeID = ps[idx + 2]
		Recipes.add {
			dispName = Helper.dispNameMaker(bladeID) .. " with Packer",
			unitInput = {
				item = {
					[curvedID] = 2,
					[rodID] = 1,
				}
			},
			unitOutput = {
				item = {
					[bladeID] = 4,
				}
			},
			machineType = Machine.electric_packer,
			minimumPower = 2
		}
	end
end

--- Make tiny dust to big dust recipes (only needed ones) [tinyDustID, dustID]
function Recipes.makePackerDustRecipes(...)
	local ps = table.pack(...)
	for idx = 1, #ps, 2 do
		local tinyDustID = ps[idx]
		local dustID = ps[idx + 1]
		Recipes.add {
			dispName = Helper.dispNameMaker(dustID) .. " with Packer",
			unitInput = {
				item = {
					[tinyDustID] = 9,
				}
			},
			unitOutput = {
				item = {
					[dustID] = 1,
				}
			},
			machineType = Machine.electric_packer,
			minimumPower = 2
		}
	end
end

-- Make big dust to tiny dust recipes (only needed ones) [dustID, tinyDustID]
function Recipes.makeUnpackerTinyDustRecipes(...)
	local ps = table.pack(...)
	for idx = 1, #ps, 2 do
		local dustID = ps[idx]
		local tinyDustID = ps[idx + 1]
		Recipes.add {
			dispName = Helper.dispNameMaker(tinyDustID) .. " with Unpacker",
			unitInput = {
				item = {
					[dustID] = 1,
				}
			},
			unitOutput = {
				item = {
					[tinyDustID] = 9,
				}
			},
			machineType = Machine.electric_unpacker,
			minimumPower = 2
		}
	end
end

--- Make blade recipes. [plate ID, ring ID, gear ID]
function Recipes.makeAssemGearRecipes(...)
	local ps = table.pack(...)
	for idx = 1, #ps, 3 do
		local plateID = ps[idx]
		local ringID = ps[idx + 1]
		local gearID = ps[idx + 2]
		Recipes.add {
			dispName = Helper.dispNameMaker(gearID) .. " with Assembler",
			unitInput = {
				item = {
					[plateID] = 4,
					[ringID] = 1,
				},
				fluid = {
					[Fluid.soldering_alloy] = 100,
				}
			},
			unitOutput = {
				item = {
					[gearID] = 2,
				}
			},
			machineType = Machine.assembler,
			minimumPower = 2
		}
	end
end

--- Make drill head recipes. [plate ID, curved plate ID, rod ID, gear ID, drill head ID]
function Recipes.makeAssemDrillHeadRecipes(...)
	local ps = table.pack(...)
	for idx = 1, #ps, 5 do
		local plateID = ps[idx]
		local curvedID = ps[idx + 1]
		local rodID = ps[idx + 2]
		local gearID = ps[idx + 3]
		local dhID = ps[idx + 4]
		Recipes.add {
			dispName = Helper.dispNameMaker(dhID) .. " with Assembler",
			unitInput = {
				item = {
					[plateID] = 1,
					[curvedID] = 2,
					[rodID] = 1,
					[gearID] = 2,
				},
				fluid = {
					[Fluid.soldering_alloy] = 75,
				}
			},
			unitOutput = {
				item = {
					[dhID] = 1,
				}
			},
			machineType = Machine.assembler,
			minimumPower = 2
		}
	end
end

--- Make rotor recipes. [Blade ID, ring ID, rotor ID]
function Recipes.makeAssemRotorRecipes(...)
	local ps = table.pack(...)
	for idx = 1, #ps, 3 do
		local bladeID = ps[idx]
		local ringID = ps[idx + 1]
		local rotorID = ps[idx + 2]
		Recipes.add {
			dispName = Helper.dispNameMaker(rotorID) .. " with Assembler",
			unitInput = {
				item = {
					[bladeID] = 4,
					[ringID] = 1,
				},
				fluid = {
					[Fluid.soldering_alloy] = 100,
				}
			},
			unitOutput = {
				item = {
					[rotorID] = 1,
				}
			},
			machineType = Machine.assembler,
			minimumPower = 2
		}
	end
end

--- Make wiremill recipes. [plate ID, wire ID, fineWire ID (if there is no finewire, give false or nil; anything evaluated to 'false')]
function Recipes.makeWiremillRecipes(...)
	local ps = table.pack(...)
	for idx = 1, #ps, 3 do
		local plateID = ps[idx]
		local wireID = ps[idx + 1]
		local fineWireID = ps[idx + 2]
		if wireID then
			Recipes.add {
				dispName = Helper.dispNameMaker(wireID),
				unitInput = {
					item = {
						[plateID] = 1
					}
				},
				unitOutput = {
					item = {
						[wireID] = 2
					}
				},
				machineType = Machine.electric_wiremill,
				minimumPower = 2
			}
		end
		if wireID and fineWireID then
			Recipes.add {
				dispName = Helper.dispNameMaker(fineWireID),
				unitInput = {
					item = {
						[wireID] = 1
					}
				},
				unitOutput = {
					item = {
						[fineWireID] = 4
					}
				},
				machineType = Machine.electric_wiremill,
				minimumPower = 2
			}
		end
	end
end

function Recipes.makeMixerDustRecipes(ps)
	local function dtmaker(mats, amts)
		local inputs = {
			item = {}
		}
		local outputs = {
			item = {}
		}
		local dustTml = "%m_dust"
		local ig = Helper.getIdOf

		for idx = 1, #mats - 1 do
			inputs.item[ig(mats[idx], dustTml, Item)] = amts[idx]
		end
		local name = ig(mats[#mats], dustTml, Item)

		outputs.item[name] = amts[#mats]

		name = Helper.dispNameMaker(name)

		return inputs, outputs, name
	end

	local function addOne(inputs, outputs, name)
		Recipes.add {
			dispName = name .. " from Mixer",
			unitInput = inputs,
			unitOutput = outputs,
			machineType = Machine.electric_mixer,
			minimumPower = 2,
		}
	end

	for _, ing in pairs(ps) do
		local mats, amts
		mats = {table.unpack(ing, 1, #ing / 2)}
		amts = {table.unpack(ing, (#ing / 2) + 1)}
		local i, o, n = dtmaker(mats, amts)
		addOne(i, o, n)
		-- addOne(ti, to, tn) -- Tiny dust mixing recipes are inefficient, and not mandatory.
	end
end

--- Make furnace and mega-smelter recipe
--- Only requires inputID and outputID (number and required minimum energy is always same)
function Recipes.makeFurnaceRecipes(ps)
	for idx = 1, #ps, 2 do
		local toSmeltID = ps[idx]
		local resultID = ps[idx + 1]
		Recipes.add {
			dispName = "Mega-smelt " .. Helper.dispNameMaker(toSmeltID),
			unitInput = {
				item = {
					[toSmeltID] = 32,
				}
			},
			unitOutput = {
				item = {
					[resultID] = 32,
				}
			},
			machineType = MultiMachine.smelterMega,
			minimumPower = 16
		}
		Recipes.add {
			dispName = "Smelt " .. Helper.dispNameMaker(toSmeltID),
			unitInput = {
				item = {
					[toSmeltID] = 1,
				}
			},
			unitOutput = {
				item = {
					[resultID] = 1,
				}
			},
			machineType = Machine.electric_furnace,
			minimumPower = 2
		}
	end
end

local function doSingleIO(ps, tab, idx)
	while(ps[idx]) do
		tab[ps[idx]] = ps[idx + 1]
		idx = idx + 2
	end
	return idx + 1
end

local function getRecipeTemplate(mt)
	return {
		machineType = mt,
		unitInput = {
			item = {},
			fluid = {}
		},
		unitOutput = {
			item = {},
			fluid = {}
		}
	}
end

--- Make single recipe. [ID], [amt], [ID], [amt], nil, [ID], [amt], ...
--- [Item inputs], nil, [Fluid Inputs], nil, [Item outputs], nil, [Fluid outputs], nil, [DispName], [minimum Power]
--- @return table Added recipe
function Recipes.makeSingleMixerRecipe(...)
	local ps = table.pack(...)
	local r = getRecipeTemplate(Machine.electric_mixer)

	local idx = 1
	idx = doSingleIO(ps, r.unitInput.item, idx)
	idx = doSingleIO(ps, r.unitInput.fluid, idx)
	idx = doSingleIO(ps, r.unitOutput.item, idx)
	idx = doSingleIO(ps, r.unitOutput.fluid, idx)
	r.dispName = ps[idx]
	idx = idx + 1
	r.minimumPower = ps[idx]
	return Recipes.add(r)
end

--- Make single recipe. [ID], [amt], [ID], [amt], nil, [ID], [amt], ...
--- [Item inputs], nil, [Fluid Inputs], nil, [Item outputs], nil, [Fluid outputs], nil, [DispName], [minimum Power]
--- @return	table Added recipe
function Recipes.makeSingleCentrifugeRecipe(...)
	local ps = table.pack(...)
	local r = getRecipeTemplate(Machine.centrifuge)

	local idx = 1
	idx = doSingleIO(ps, r.unitInput.item, idx)
	idx = doSingleIO(ps, r.unitInput.fluid, idx)
	idx = doSingleIO(ps, r.unitOutput.item, idx)
	idx = doSingleIO(ps, r.unitOutput.fluid, idx)
	r.dispName = ps[idx]
	idx = idx + 1
	r.minimumPower = ps[idx]
	return Recipes.add(r)
end

--- Make single recipe. [ID], [amt], [ID], [amt], nil, [ID], [amt], ...
--- [Item inputs], nil, [Item outputs], nil, [DispName], [minimum Power]
--- @return	table Added recipe
function Recipes.makeSingleMaceratorRecipe(...)
	local ps = table.pack(...)
	local r = getRecipeTemplate(Machine.electric_macerator)
	local idx = 1
	idx = doSingleIO(ps, r.unitInput.item, idx)
	idx = doSingleIO(ps, r.unitOutput.item, idx)
	r.dispName = ps[idx]
	idx = idx + 1
	r.minimumPower = ps[idx]
	return Recipes.add(r)
end

--- Make single recipe. [ID], [amt], [ID], [amt], nil, [ID], [amt], ...
--- [Item inputs], nil, [Fluid Inputs], nil, [Item outputs], nil, [Fluid outputs], nil, [DispName], [minimum Power]
--- @return	table Added recipe
function Recipes.makeSingleElectrolyzerRecipe(...)
	local ps = table.pack(...)
	local r = getRecipeTemplate(Machine.electrolyzer)

	local idx = 1
	idx = doSingleIO(ps, r.unitInput.item, idx)
	idx = doSingleIO(ps, r.unitInput.fluid, idx)
	idx = doSingleIO(ps, r.unitOutput.item, idx)
	idx = doSingleIO(ps, r.unitOutput.fluid, idx)
	r.dispName = ps[idx]
	idx = idx + 1
	r.minimumPower = ps[idx]
	return Recipes.add(r)
end

--- Make single recipe. [ID], [amt], [ID], [amt], nil, [ID], [amt], ...
--- [Item inputs], nil, [Item outputs], nil, [DispName], [minimum Power]
--- @return	table Added recipe
function Recipes.makeSinglePolarizerRecipe(...)
	local ps = table.pack(...)
	local r = getRecipeTemplate(Machine.polarizer)
	local idx = 1
	idx = doSingleIO(ps, r.unitInput.item, idx)
	idx = doSingleIO(ps, r.unitOutput.item, idx)
	r.dispName = ps[idx]
	idx = idx + 1
	r.minimumPower = ps[idx]
	return Recipes.add(r)
end

return {
	Recipes = Recipes,
	Recipe = Recipe
}