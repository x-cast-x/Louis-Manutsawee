local Sanity_Replica = require("components/sanity_replica")
GLOBAL.setfenv(1, GLOBAL)

local _IsEnlightened = Sanity_Replica.IsEnlightened
function Sanity_Replica:IsEnlightened(...)
    return self.inst:HasTag("controlled") or _IsEnlightened(self, ...)
end