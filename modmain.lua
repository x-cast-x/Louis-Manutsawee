local modimport = modimport

local modules = {
    "config",
    "assets",
    "strings",
    "fx",
    "constants",
    "tuning",
    "actions",
    "postinit",
    "recipes",
    "containers",
    "RPC",
    "commands",
    "characters",
    "prefabskin",
    "loadingtips",
}

local mod_modules = {
    "pl_postinit",
    "um_postinit",
    "ia_postinit",
    "hof_postinit",
}

for i = 1, #modules do
    modimport("main/" .. modules[i])
end

for i = 1, #mod_modules do
    modimport("postinit/main/" .. mod_modules[i])
end

GLOBAL.setfenv(1, GLOBAL)

if IsRail() then
    error("Ban WeGame");
end
