local prefabs = {}

table.insert(prefabs, CreatePrefabSkin("manutsawee_none", {
    base_prefab = "manutsawee",
    build_name_override = "manutsawee",
    type = "base",
    rarity = "Elegant",
    skip_item_gen = true,
    skip_giftable_gen = true,
    skin_tags = { "BASE", "MANUTSAWEE", },
    skins = {
        normal_skin = "manutsawee",
        ghost_skin = "ghost_manutsawee_build",
    },
    assets = {
        Asset( "ANIM", "anim/manutsawee.zip" ),
        Asset( "ANIM", "anim/ghost_manutsawee_build.zip" ),
    },
}))

for k, v in ipairs(M_SKIN_NAMES) do
    table.insert(prefabs, CreatePrefabSkin("manutsawee_" .. v, {
        base_prefab = "manutsawee",
        build_name_override = "manutsawee_" .. v,
        type = "base",
        rarity = "Elegant",
        skip_item_gen = true,
        skip_giftable_gen = true,
        skin_tags = {"BASE", "MANUTSAWEE", "SURVIVOR"},
        skins = {
            normal_skin = "manutsawee_" .. v,
            ghost_skin = "ghost_manutsawee_build",
        },

        assets = {
            Asset("ANIM", "anim/manutsawee_" .. v .. ".zip"),
            Asset("ANIM", "anim/ghost_manutsawee_build.zip"),
        },
    }))
end

return unpack(prefabs)
