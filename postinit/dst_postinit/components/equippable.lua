local Equippable = require("components/equippable")
GLOBAL.setfenv(1, GLOBAL)

-- 帮Klei擦屁股
local _ToPocket = Equippable.ToPocket
function Equippable:ToPocket(owner, ...)
    _ToPocket(self, owner or self.inst.components.inventoryitem.owner, ...)
end