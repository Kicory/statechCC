require("Dict")
require("Recipes")
require("Goals")
require("__Machines")
require("__Storage")
require("__Helpers")

-- Main program
Chef = {}
local moni

function Chef.init()
	M.refreshMachines()
	St.init()
	moni = peripheral.find("monitor")
end

function Chef.step()
	St.refreshCatalogue()
	
	local cur = os.clock()
	
	if moni then
		St.printStatusToMonitor(Goals, moni)
	end

	local requiredRecipes, requiredUnits = table.unpack(St.filterRequired(Recipes, Goals))

	local factoryScd = TH.checkAll(
		function() M.harvestToBuffer(St.bufferAE) end,
		function() return M.makeFactoryCraftSchedule(requiredRecipes, requiredUnits, St.getCatalogueCopy()) end)[2]

	os.sleep(0.01)	-- 1 tick for AE system to prepare.

	local harvestedCtlg, fedCtlg, expectedCtlg = M.moveMaterials(factoryScd, St.bufferAE, St.BufferStorages, St.BufferTanks, St.mainAE)
	
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
			M.harvestToBuffer(St.bufferAE)
			os.sleep(0.01)
			-- Pulling back outputs from factory should not stop
			St.applyHarvestedCatalogue(M.harvestFromBuffer(St.bufferAE, St.BufferStorages, St.BufferTanks, St.mainAE))
		end
	end
end


Chef.init()

while true do
	Chef.step()
end