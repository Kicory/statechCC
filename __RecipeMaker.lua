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
		machineFilter = basePowerChecker(specs.minimumPower),
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

function Recipes:makeCompressorRecipes(...)
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