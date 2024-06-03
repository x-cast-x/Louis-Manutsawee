local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("world", function(inst)
    if not inst.ismastersim then
        return
    end
    inst:AddComponent("katanaspawner")
    print("Adding KatanaSpawner")

    -- Do not misunderstand :P
    inst:AddComponent("datingmanager")
end)
