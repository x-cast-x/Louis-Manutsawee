local modimport = modimport

local modules = {
    "config",
    "mutil",
    "assets",
    "glassicapi",
    "strings",
    "fx",
    "constants",
    "tuning",
    "postinit",
    "actions",
    "recipes",
    "containers",
    "RPC",
    "commands",
    "characters",
    "prefabskin",
    "loadingtips",
}

if IA_ENABLED then
    table.insert(modules, "ia_postinit")
end

if PL_ENABLED then
    table.insert(modules, "pl_postinit")
end

if UM_ENABLED then
    table.insert(modules, "um_postinit")
end

for i = 1, #modules do
    modimport("main/" .. modules[i])
end
