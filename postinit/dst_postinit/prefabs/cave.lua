local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("cave", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:AddComponent("katanaspawner")
end)
