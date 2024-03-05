local Layouts = require("map/layouts").Layouts
local StaticLayout = require("map/static_layout")
GLOBAL.setfenv(1, GLOBAL)

Layouts["DevCemetery"] = StaticLayout.Get("map/static_layouts/dev_cemetery")
