local prefabs = {}

table.insert(prefabs, CreatePrefabSkin("lcane", {
    base_prefab = "cane",
    type = "item",
    rarity = "Elegant",
    assets = {
        Asset("DYNAMIC_ANIM", "anim/dynamic/lcane.zip"),
        Asset("PKGREF", "anim/dynamic/lcane.dyn"),
    },
    init_fn = function(inst)
        cane_init_fn(inst, "lcane")
        GlassicAPI.UpdateFloaterAnim(inst)
    end,
    skin_tags = { "CANE", "Elegant" },
}))

return unpack(prefabs)