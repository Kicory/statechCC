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
	M.init()
	St.init()
	moni = peripheral.find("monitor")
end

function Chef.step()
	St.refreshCatalogue()
	
	local cur = os.clock()
	
	if moni then
		St.printStatusToMonitor(Goals, moni)
	end

	local craftRequirements = St.getRequirements(Recipes, Goals)

	M.harvestToBufferSlow(St.bufferAE)
	local factoryScd = M.makeFactoryCraftSchedule(craftRequirements, St.getCatalogueCopy())

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
			M.harvestToBufferSlow(St.bufferAE)
			os.sleep(0.01)
			-- Pulling back outputs from factory should not stop
			St.applyHarvestedCatalogue(M.harvestFromBuffer(St.bufferAE, St.BufferStorages, St.BufferTanks, St.mainAE))
		end
	end
end

print("Initializing...")
local cur = os.clock()
Chef.init()
print("Initializing took " .. Helper.tickFrom(cur) .. " ticks")

while true do
	local cur = os.clock()
	Chef.step()
	print(Helper.tickFrom(cur) .. " ticks for previous step.")
end