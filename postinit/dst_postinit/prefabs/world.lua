local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("world", function(inst)
    if not TheWorld.ismastersim then
        return
    end


end)
