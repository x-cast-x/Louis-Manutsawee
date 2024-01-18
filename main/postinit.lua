local modimport = modimport
GLOBAL.setfenv(1, GLOBAL)

modimport("postinit/entityscript")

local postinit = {
    prefabs = {
        "world",
        "nightmarefissure",
    },
    stategraphs = {
        "SGwilson",
        "SGwilson_client",
    },
    components = {
        "eater"
    },
}

for k, v in pairs(postinit) do
    for i = 1, #v do
        modimport("postinit/dst_postinit/" .. k .. "/" .. postinit[k][i])
    end
end
