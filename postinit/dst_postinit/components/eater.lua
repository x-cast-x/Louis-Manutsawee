local AddComponentPostInit = AddComponentPostInit
GLOBAL.setfenv(1, GLOBAL)

AddComponentPostInit("eater", function(self)
    function self:SetCanEatMfruit()
        table.insert(self.preferseating, FOODTYPE.MFRUIT)
        table.insert(self.caneat, FOODTYPE.MFRUIT)
        self.inst:AddTag(FOODTYPE.MFRUIT.."_eater")
    end
end)
