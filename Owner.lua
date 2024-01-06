local chef = peripheral.find("computer")
local chefSide = peripheral.getName(chef)
local mod = peripheral.find("modem")
local mm = peripheral.getName(mod)
local CHEF_PROT = "CHEF"

local MOD_GO = 0
local MOD_SUCK_ITEMS = 1
local MOD_ADD_MACHINE = 2
local MOD_HALT = 3

rednet.open(mm)
while true do
	local id, code, prot = rednet.receive(CHEF_PROT)
	code = string.upper(code)
	if code == "GO" then
		rs.setAnalogOutput(chefSide, MOD_GO)
	elseif code == "STOP FULL" or code == "FREEZE" then
		rs.setAnalogOutput(chefSide, MOD_ADD_MACHINE)
	elseif code == "STOP FEEDING" or code == "HARVEST" then
		rs.setAnalogOutput(chefSide, MOD_SUCK_ITEMS)
	elseif code == "HALT" then
		rs.setAnalogOutput(chefSide, MOD_HALT)
	end
end