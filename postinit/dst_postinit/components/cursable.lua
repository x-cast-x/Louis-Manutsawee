local Cursable = require("components/cursable")

GLOBAL.setfenv(1, GLOBAL)

local _IsCursable = Cursable.IsCursable
function Cursable:IsCursable(item, ...)
    -- Naughty children already have a curse
    if self.inst:HasTag("naughtychild") then
        return false
    end
    return _IsCursable(self, item, ...)
end
