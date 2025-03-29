local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("cookpot", function(inst)
    if not TheWorld.ismastersim then
        return
    end
end)
