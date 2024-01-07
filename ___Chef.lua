local Recipes = require("Recipes")
local GoalMng = require("__GoalMaker")
local M = require("__Machines")
local St = require("__Storage")
local Helper = require("__Helpers")
local DirectProd = require("Dict").DirectProd
local Ctlg = require("__Catalouge")

local SeedGoalsCtlg = GoalMng.SeedGoalsCtlg

-- Main program
local Chef = {}
local moni
local codeInputSide

function Chef.init()
	M.init()
	St.init()
	GoalMng.init(DirectProd, Recipes.productionGraph)
	local owner = peripheral.find("computer")
	if owner then
		codeInputSide = peripheral.getName(owner)
	end
	moni = peripheral.find("monitor")
end

function Chef.step(prevLackingStatus, prevMachineLackingStatus)
	St.refreshCatalogue() -- Consumes ticks
	
	if moni then
		St.printStatusToMonitor(GoalMng.DerivedGoalsCtlg, prevLackingStatus, prevMachineLackingStatus, moni)
	end

	local craftRequirements = St.getRequirements(Recipes, GoalMng.DerivedGoalsCtlg)

	local harvestedCtlg = M.updateFactory(St.mainAE) -- consumes ticks

	local factoryScd, lackingStatus, machineLackingStatus = M.makeFactoryCraftSchedule(craftRequirements, St.getCatalogueCopy(), GoalMng.DerivedGoalsCtlg)

	local fedCtlg, expectedCtlg = M.feedFactory(factoryScd, St.mainAE)
	
	St.applyExpectedCatalogue(expectedCtlg)
	St.applyHarvestedCatalogue(harvestedCtlg)

	return lackingStatus, machineLackingStatus
end

function Chef.maintenance()
	if not codeInputSide then
		return
	end
	local actionCode = rs.getAnalogInput(codeInputSide)
	while actionCode ~= 0 do
		if actionCode == 1 then
			os.sleep(0.1)
			local harvested = M.updateFactory(St.mainAE)
			os.sleep(0.1)
			-- Pulling back outputs from factory should not stop
			St.applyHarvestedCatalogue(harvested)
		elseif actionCode == 2 then
			os.sleep(0.1)
		elseif actionCode == 3 then
			error("Chef halted by Owner!")
		end
		actionCode = rs.getAnalogInput(codeInputSide)
	end
	M.init()
	GoalMng.init(DirectProd, Recipes.productionGraph)
end

print("Initializing...")
local cur = os.clock()
Chef.init()
print("Initializing took " .. Helper.tickFrom(cur) .. " ticks \n")

local lackingStatus = {}
local machineLackingStatus = {}
local stepsLasted = 0
while true do
	Chef.maintenance()
	local cur = os.clock()
	lackingStatus, machineLackingStatus = Chef.step(lackingStatus, machineLackingStatus)
	stepsLasted = stepsLasted + 1
	Helper.updateTermLine(Helper.tickFrom(cur) .. " ticks from last step (" .. stepsLasted .. ")")
end