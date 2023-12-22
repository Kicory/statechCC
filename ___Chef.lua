local Recipes = require("Recipes")
local GoalsCtlg, DirectProductsCtlg = table.unpack(require("Goals"))
local M = require("__Machines")
local St = require("__Storage")
local Helper = require("__Helpers")

-- Main program
Chef = {}
local moni

function Chef.init()
	M.init()
	St.init()
	moni = peripheral.find("monitor")
end

function Chef.step(prevLackingStatus, prevMachineLackingStatus)
	St.refreshCatalogue()
	
	if moni then
		St.printStatusToMonitor(GoalsCtlg, DirectProductsCtlg, prevLackingStatus, prevMachineLackingStatus, moni)
	end

	local craftRequirements = St.getRequirements(Recipes, GoalsCtlg)

	M.harvestToBufferSlow(St.bufferAE)
	local factoryScd, lackingStatus, machineLackingStatus = M.makeFactoryCraftSchedule(craftRequirements, St.getCatalogueCopy())

	os.sleep(0.01)	-- 1 tick for AE system to prepare.

	local harvestedCtlg = M.harvestFromBuffer(St.bufferAE, St.BufferStorages, St.BufferTanks, St.mainAE)
	
	local fedCtlg, expectedCtlg = M.feedFactory(factoryScd, St.mainAE)
	
	St.applyExpectedCatalogue(expectedCtlg)
	St.applyHarvestedCatalogue(harvestedCtlg)

	if (rs.getInput("left")) then
		if moni then
			local x, y = moni.getCursorPos()
			local xx, yy = moni.getSize()
			moni.setCursorPos(xx / 2 - 2, y + (yy - y) / 2)
			moni.write("FROZEN")
		end
		while rs.getInput("left") do
			os.sleep(0.1)
			M.harvestToBufferSlow(St.bufferAE)
			os.sleep(0.01)
			-- Pulling back outputs from factory should not stop
			St.applyHarvestedCatalogue(M.harvestFromBuffer(St.bufferAE, St.BufferStorages, St.BufferTanks, St.mainAE))
		end
	end
	return lackingStatus, machineLackingStatus
end

print("Initializing...")
local cur = os.clock()
Chef.init()
print("Initializing took " .. Helper.tickFrom(cur) .. " ticks")

local lackingStatus = {}
local machineLackingStatus = {}
while true do
	local cur = os.clock()
	lackingStatus, machineLackingStatus = Chef.step(lackingStatus, machineLackingStatus)
	print(Helper.tickFrom(cur) .. " ticks for previous step.")
end