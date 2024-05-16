local Stewer = require("components/stewer")
GLOBAL.setfenv(1, GLOBAL)

local _StartCooking = Stewer.StartCooking
function Stewer:StartCooking(doer, ...)
    if _StartCooking ~= nil then
        _StartCooking(self, doer, ...)
        if doer ~= nil and doer:HasTag("naughtychild") and self.targettime ~= nil then
            self.targettime = self.targettime / 2
        end
    end
end
