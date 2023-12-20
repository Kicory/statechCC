local Machine = require("Dict").Machine
local Item = require("Dict").Item
local Fluid = require("Dict").Fluid
local Helper = require("__Helpers")
local Ctlg = require("__Catalouge")

local function basePowerChecker(basePowerRequired)
	return function (machineInfo) return machineInfo.getBasePower() >= basePowerRequired end
end

Recipes = {}

local consumables = {}
local craftables = {}

function Recipes:new(specs)
	if (not specs.dispName) or (type(specs.dispName) ~= "string") then error("Recipe Display Name not specified!") return end

	local dispName = specs.dispName

	if not specs.unitInput then error("No input for recipe: " .. dispName) return end
	if not specs.unitOutput then error("No output for recipe: " .. dispName) return end
	if not specs.machineType then error("No machine type specified for recipe: " .. dispName) return end
	if not specs.minimumPower then error("No machine minimum power requirement: " .. dispName) return end

	local order = #Recipes + 1
	Recipes[order] = {
		-- Lower comes first
		rank = order,
		dispName = specs.dispName,
		unitInput = specs.unitInput,
		unitOutput = specs.unitOutput,
		machineType = specs.machineType,
		minimumPower = specs.minimumPower,
	}

	for id in pairs(Helper.IO2Catalogue(specs.unitInput)) do
		consumables[id] = true
	end
	for id in pairs(Helper.IO2Catalogue(specs.unitOutput)) do
		craftables[id] = true
	end
end

function Recipes:getMaterialsUsedEmptyCtlg()
	local ret = Ctlg:new()
	for _, r in ipairs(self) do
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

function Recipes.isCraftable(id)
	return (craftables[id] ~= nil)
end

--- Make basic compressor recipes. [ingot ID, double ingot ID, plate ID, curved plate ID, rod ID, ring ID]. Give "false" if there is no corresponding item.
function Recipes:makeCompressorRecipesBasic(...)
	local ps = table.pack(...)
	local function addOne(inputID, outputID, outputCnt, dispNamePostfix)
		if inputID and outputID then
			self:new {
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
function Recipes:makeCompressorRecipesCustom(...)
	local ps = table.pack(...)
	for idx = 1, #ps, 2 do
		local fromID = ps[idx]
		local toID = ps[idx + 1]
		self:new {
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
function Recipes:makeCutterRodRecipes(...)
	local ps = table.pack(...)
	for idx = 1, #ps, 3 do
		local fromID = ps[idx]
		local fromDoubleID = ps[idx + 1]
		local toID = ps[idx + 2]
		if fromDoubleID then
			self:new {
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
			self:new {
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
function Recipes:makePackerBladeRecipes(...)
	local ps = table.pack(...)
	for idx = 1, #ps, 3 do
		local curvedID = ps[idx]
		local rodID = ps[idx + 1]
		local bladeID = ps[idx + 2]
		self:new {
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

--- Make blade recipes. [plate ID, ring ID, gear ID]
function Recipes:makeAssemGearRecipes(...)
	local ps = table.pack(...)
	for idx = 1, #ps, 3 do
		local plateID = ps[idx]
		local ringID = ps[idx + 1]
		local gearID = ps[idx + 2]
		self:new {
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
function Recipes:makeAssemDrillHeadRecipes(...)
	local ps = table.pack(...)
	for idx = 1, #ps, 5 do
		local plateID = ps[idx]
		local curvedID = ps[idx + 1]
		local rodID = ps[idx + 2]
		local gearID = ps[idx + 3]
		local dhID = ps[idx + 4]
		self:new {
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
function Recipes:makeAssemRotorRecipes(...)
	local ps = table.pack(...)
	for idx = 1, #ps, 3 do
		local bladeID = ps[idx]
		local ringID = ps[idx + 1]
		local rotorID = ps[idx + 2]
		self:new {
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
function Recipes:makeWiremillRecipes(...)
	local ps = table.pack(...)
	for idx = 1, #ps, 3 do
		local plateID = ps[idx]
		local wireID = ps[idx + 1]
		local fineWireID = ps[idx + 2]
		if wireID then
			self:new {
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
			self:new {
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

function Recipes:makeMixerDustRecipes(ps)
	local function dtmaker(mats, amts)
		local inputs = {
			item = {}
		}
		local outputs = {
			item = {}
		}
		local tinyInputs = {
			item = {}
		}
		local tinyOutputs = {
			item = {}
		}
		local dustTml = "%m_dust"
		local tDustTml = "%m_tiny_dust"
		local ig = Helper.getIdOf

		for idx = 1, #mats - 1 do
			inputs.item[ig(mats[idx], dustTml, Item)] = amts[idx]
			tinyInputs.item[ig(mats[idx], tDustTml, Item)] = amts[idx]
		end
		local name = ig(mats[#mats], dustTml, Item)
		local tName = ig(mats[#mats], tDustTml, Item)
		
		outputs.item[name] = amts[#mats]
		tinyOutputs.item[tName] = amts[#mats]

		name = Helper.dispNameMaker(name)
		tName = Helper.dispNameMaker(tName)

		return inputs, outputs, name, tinyInputs, tinyOutputs, tName
	end
	
	local function addOne(inputs, outputs, name)
		self:new {
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
		local i, o, n, ti, to, tn = dtmaker(mats, amts)
		addOne(i, o, n)
		addOne(ti, to, tn)
	end
end

--- Make single Mixer recipe. [ID], [amt], [ID], [amt], nil, [ID], [amt], ...
--- [Item inputs], nil, [Fluid Inputs], nil, [Item outputs], nil, [Fluid outputs], nil, [DispName], [minimum Power]
function Recipes:makeSingleMixerRecipeCustom(...)
	local ps = table.pack(...)
	local r = {
		machineType = Machine.electric_mixer,
		unitInput = {
			item = {},
			fluid = {}
		},
		unitOutput = {
			item = {},
			fluid = {}
		}
	}
	local function doSingleIO(tab, idx)
		while(ps[idx]) do
			tab[ps[idx]] = ps[idx + 1]
			idx = idx + 2
		end
		return idx + 1
	end
	local idx = 1
	idx = doSingleIO(r.unitInput.item, idx)
	idx = doSingleIO(r.unitInput.fluid, idx)
	idx = doSingleIO(r.unitOutput.item, idx)
	idx = doSingleIO(r.unitOutput.fluid, idx)
	r.dispName = ps[idx]
	idx = idx + 1
	r.minimumPower = ps[idx]
	Helper.printPretty(r)
	Recipes:new(r)
end