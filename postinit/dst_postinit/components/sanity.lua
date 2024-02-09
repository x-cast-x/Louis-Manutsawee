local Sanity = require("components/sanity")
GLOBAL.setfenv(1, GLOBAL)

function Sanity:IsEnlightened()
	return self.inst:HasTag("controlled") or self.mode == SANITY_MODE_LUNACY and (not self.inducedinsanity and not self.sane)
end