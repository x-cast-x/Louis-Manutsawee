local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("world", function(inst)
    if not TheWorld.ismastersim then
        return
    end
    inst:AddComponent("katanaspawner")

    -- Do not misunderstand :P
    inst:AddComponent("datingmanager")
end)
