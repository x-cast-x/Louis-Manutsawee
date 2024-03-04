local modimport = modimport
GLOBAL.setfenv(1, GLOBAL)

modimport("postinit/entityscript")
modimport("postinit/dst_postinit/modules/recipe")

local postinit = {
    prefabs = {
        "world",
        "nightmarefissure",
        "winter_tree",
    },
    stategraphs = {
        "SGwilson",
        "SGwilson_client",
    },
    components = {
        "eater",
        "sanity",
        "sanity_replica",
        "grogginess",
        "equippable",
        "wisecracker",
        "combat",
    },
    widgets = {
        "skinspuppet",
    },
}

for k, v in pairs(postinit) do
    for i = 1, #v do
        modimport("postinit/dst_postinit/" .. k .. "/" .. postinit[k][i])
    end
end
