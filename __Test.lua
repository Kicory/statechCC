local H = require("__Helpers")
local log = {}

local r = peripheral.wrap("right")

while true do
    local cin = r.getCraftingInformation()
    if cin.currentEfficiency then
        log[cin.currentEfficiency] = cin.currentRecipeCost
        if (cin.currentEfficiency == 64) then
            break
        end
    end
    H.printPretty(log)
end