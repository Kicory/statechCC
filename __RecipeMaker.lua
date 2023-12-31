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

--- Only materials in idList will counted as output, and used when calculating required crafting
function Recipe:setEffectiveOutput(...)
	local ps = table.pack(...)
	local set = {}
	for _, v in ipairs(ps) do
		set[v] = true
	end
	self.effUnitOutputCtlg:filter(function(id, _) return set[id] ~= nil end)
	return self
end

function Recipe:setAlwaysProc()
	self.alwaysProc = true
	return self
end

-- Mini class RecipeList (multiple recipes)
local RecipeList = { }

local recipeListMt = {
	__index = RecipeList
}

function RecipeList:new(o)
	assert(o ~= nil)
	setmetatable(o, recipeListMt)
	return o
end

function RecipeList:setPriority(prio)
	for _, r in ipairs(self) do
		r:setPriority(prio)
	end
	return self
end

--- Only materials in idList will counted as output, and used when calculating required crafting
function RecipeList:setEffectiveOutput(...)
	for _, r in ipairs(self) do
		r:setEffectiveOutput(...)
	end
	return self
end

function RecipeList:setAlwaysProc()
	for _, r in ipairs(self) do
		r:setAlwaysProc()
	end
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
		-- Outputs considered as result of this recipe when calculating required crafting.
		-- e.g., hydrogen output from butadiene production should not considered as hydrogen production method.
		effUnitOutputCtlg = Helper.IO2Catalogue(specs.unitOutput),
		-- Schedule if there is input material.
		alwaysProc = false,
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

local function doSingleIO(ps, tab, idx, multiplier)
	multiplier = multiplier or 1
	while(ps[idx]) do
		tab[ps[idx]] = ps[idx + 1] * multiplier
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

--- Make single recipe maker
---@param mt string Machine type
---@param itemIn boolean
---@param fluidIn boolean
---@param itemOut boolean
---@param fluidOut boolean
function Recipes.makeSingleRecipeMaker(mt, itemIn, fluidIn, itemOut, fluidOut)
	assert(mt ~= nil and itemIn ~= nil and fluidIn ~= nil and itemOut	~= nil and fluidOut ~= nil)
	
	return function(...)
		local ps = table.pack(...)
		local r = getRecipeTemplate(mt)
	
		local idx = 1
		if itemIn then
			idx = doSingleIO(ps, r.unitInput.item, idx)
		end
		if fluidIn then
			idx = doSingleIO(ps, r.unitInput.fluid, idx)
		end
		if itemOut then
			idx = doSingleIO(ps, r.unitOutput.item, idx)
		end
		if fluidOut then
			idx = doSingleIO(ps, r.unitOutput.fluid, idx)
		end
		r.dispName = ps[idx]
		idx = idx + 1
		r.minimumPower = ps[idx]
		return Recipes.add(r)
	end
end

--- Make both single/large recipes. [ID], [amt], [ID], [amt], nil, [ID], [amt], ...
--- [Item inputs], nil, [Fluid Inputs], nil, [Item outputs], nil, [Fluid outputs], nil, [DispName], [minimum Power]
--- @return	table Added recipe (single)
--- @return table Added recipe (large)
function Recipes.makeSingleChemicalReactorRecipe(...)
	local ps = table.pack(...)
	local rBig = getRecipeTemplate(MultiMachine.chemicalReactorLarge)
	local r = getRecipeTemplate(Machine.chemical_reactor)

	local idxBig = 1
	idxBig = doSingleIO(ps, rBig.unitInput.item, idxBig, 4)
	idxBig = doSingleIO(ps, rBig.unitInput.fluid, idxBig, 4)
	idxBig = doSingleIO(ps, rBig.unitOutput.item, idxBig, 4)
	idxBig = doSingleIO(ps, rBig.unitOutput.fluid, idxBig, 4)
	rBig.dispName = ps[idxBig] .. " Big"
	idxBig = idxBig + 1
	rBig.minimumPower = ps[idxBig] * 2
	local bigRecipe = Recipes.add(rBig)
	
	local idx = 1
	idx = doSingleIO(ps, r.unitInput.item, idx)
	idx = doSingleIO(ps, r.unitInput.fluid, idx)
	idx = doSingleIO(ps, r.unitOutput.item, idx)
	idx = doSingleIO(ps, r.unitOutput.fluid, idx)
	r.dispName = ps[idx]
	idx = idx + 1
	r.minimumPower = ps[idx]
	local singleRecipe = Recipes.add(r)
	
	local ret = RecipeList:new({singleRecipe, bigRecipe})
	return ret
end

return {
	Recipes = Recipes,
	Recipe = Recipe
}