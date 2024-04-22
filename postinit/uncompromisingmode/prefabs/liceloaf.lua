local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("liceloaf", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    if inst.components.perishable then
        inst.components.perishable:SetPerishTime(100*TUNING.PERISH_TWO_DAY)
    end
end)
