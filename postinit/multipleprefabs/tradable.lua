local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local tradable_prefabs = {
    "axe",
    "pickaxe",
    "goldenaxe",
    "goldenpickaxe",
}

for k, v in pairs(tradable_prefabs) do
    AddPrefabPostInit(v, function(inst)
        if not TheWorld.ismastersim then
            return
        end

        if not inst.components.tradable then
            inst:AddComponent("tradable")
        end
    end)
end
