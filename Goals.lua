local Ctlg = require("__Catalouge")
local I = require("Dict").Item
local F = require("Dict").Fluid

return Ctlg:new {
    [I.large_motor] = 16,
    [I.large_pump] = 16,
    [I.bronze_drill] = 16,
    [I.steel_drill] = 16,
    [I.mv_steam_turbine] = 2,
}