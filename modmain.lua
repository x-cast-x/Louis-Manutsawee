local modimport = modimport

local modules = {
    "modrequirer",
    "config",
    "mutil",
    "assets",
    "strings",
    "fx",
    "constants",
    "tuning",
    "postinit",
    "actions",
    "recipes",
    "containers",
    "commands",
    "characters",
    "rpc",
    "prefabskin",
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

Mmodimport("chatinputscreen")
Mmodimport("consolescreen")
Mmodimport("textedit")
