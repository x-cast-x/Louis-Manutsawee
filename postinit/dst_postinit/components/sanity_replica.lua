local Sanity_Replica = require("components/sanity_replica")
GLOBAL.setfenv(1, GLOBAL)

function Sanity_Replica:IsEnlightened()
    return self.inst:HasTag("controlled") or not self._isinsanitymode:value() and not self._issane:value()
end