local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("catcoon", function(inst)
    if not TheWorld.ismastersim then
        return
    end



end)
