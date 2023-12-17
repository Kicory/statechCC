local Helper = require("__Helpers")
local TH = require("__ThreadingHelpers")
require("__Storage")

local ae = "ae2:creative_energy_cell_0"
local st = "modern_industrialization:configurable_chest_4"
local b = "minecraft:barrel_0"
local stw = peripheral.wrap(st)
local aew = peripheral.wrap(ae)
local bw = peripheral.wrap(b)
local pullItem = aew.pullItem

local limit = 257

local function pullEveryItem()
    pullItem(st)
end
function getItems()
    return stw.items()
end
function getItemsb()
    return bw.list()
end
function getSize()
    return bw.size()
end
function hehe()
    return 10
end

while true do
    local cur = os.clock()
    -- TH.doMany(getItems, limit)
    -- TH.doMany(pullEveryItem, limit)
    parallel.waitForAll(function() TH.doMany(getItemsb, 256) end, function() TH.doMany(getSize, 1) end)
    TH.doMany(getItemsb, 257)
    -- pullEveryItem(st)
    print(Helper.tickFrom(cur))
end