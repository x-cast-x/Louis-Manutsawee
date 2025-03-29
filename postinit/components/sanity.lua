local Sanity = require("components/sanity")
GLOBAL.setfenv(1, GLOBAL)

local _IsEnlightened = Sanity.IsEnlightened
function Sanity:IsEnlightened(...)
	return self.inst:HasTag("controlled") or _IsEnlightened(self, ...)
end