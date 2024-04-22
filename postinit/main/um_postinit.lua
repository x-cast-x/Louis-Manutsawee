if not UM_ENABLED then
    return
end

local modimport = modimport

local uncompromising_postinit = {
    prefabs = {
        "liceloaf",
    }
}

for k, v in pairs(uncompromising_postinit) do
    for i = 1, #v do
        modimport("postinit/uncompromisingmode/" .. uncompromising_postinit[k][i])
    end
end
