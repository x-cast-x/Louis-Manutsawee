local Eater = require("components/eater")

GLOBAL.setfenv(1, GLOBAL)

function Eater:SetCanEatMfruit()
    table.insert(self.preferseating, FOODTYPE.MFRUIT)
    table.insert(self.caneat, FOODTYPE.MFRUIT)
    self.inst:AddTag(FOODTYPE.MFRUIT.."_eater")
end
