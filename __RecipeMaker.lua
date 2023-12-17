require("Dict")
require("__Helpers")

local function basePowerChecker(basePowerRequired)
	return function (machineInfo) return machineInfo.getBasePower() >= basePowerRequired end
end

Recipes = {}

function Recipes:new(specs)
	if (not specs.dispName) or (type(specs.dispName) ~= "string") then error("Recipe Display Name not specified!") return end

	local dispName = specs.dispName

	if not specs.unitInput then error("No input for recipe: " .. dispName) return end
	if not specs.unitOutput then error("No output for recipe: " .. dispName) return end
	if not specs.machineTypes then error("No machine type specified for recipe: " .. dispName) return end
	if not specs.minimumPower then error("No machine minimum power requirement: " .. dispName) return end

	local order = #Recipes + 1
	Recipes[order] = {
		-- Lower comes first
		rank = order,
		dispName = specs.dispName,
		unitInput = specs.unitInput,
		unitOutput = specs.unitOutput,
		machineTypes = specs.machineTypes,
		minimumPower = specs.minimumPower,
	}
end

function Recipes:getMaterialsUsedEmptyCtlg()
	local ret = {}
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
				machineTypes = {
					Machine.electric_compressor
				},
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
			machineTypes = {
				Machine.electric_compressor
			},
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
				machineTypes = {
					Machine.electric_cutting_machine
				},
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
				machineTypes = {
					Machine.electric_cutting_machine
				},
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
			machineTypes = {
				Machine.electric_packer
			},
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
			machineTypes = {
				Machine.assembler
			},
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
					[Fluid.soldering_alloy] = 100,
				}
			},
			unitOutput = {
				item = {
					[dhID] = 1,
				}
			},
			machineTypes = {
				Machine.assembler
			},
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
			machineTypes = {
				Machine.assembler
			},
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
				machineTypes = {
					Machine.electric_wiremill
				},
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
				machineTypes = {
					Machine.electric_wiremill
				},
				minimumPower = 2
			}
		end
	end
end

