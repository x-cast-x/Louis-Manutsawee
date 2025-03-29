local Eater = require("components/eater")
GLOBAL.setfenv(1, GLOBAL)

function Eater:SetCanEatMfruit()
    table.insert(self.preferseating, FOODTYPE.MFRUIT)
    table.insert(self.caneat, FOODTYPE.MFRUIT)
    self.inst:AddTag(FOODTYPE.MFRUIT.."_eater")
end

function Eater:SetRejectEatingTag(tag)
    if self.rejecteatingtag == nil then
        self.rejecteatingtag = { tag }
    else
        table.insert(self.rejecteatingtag, tag)
    end
end

local _PrefersToEat = Eater.PrefersToEat
function Eater:PrefersToEat(food, ...)
    if self.rejecteatingtag ~= nil then
        for i, v in ipairs(self.rejecteatingtag) do
            if food:HasTag(v) then
                return false
            end
        end
    end
    return _PrefersToEat(self, food, ...)
end
