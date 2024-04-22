if not HOF_ENABLED then
    return
end

local modimport = modimport

local hof_postinit = {

}

for k, v in pairs(hof_postinit) do
    for i = 1, #v do
        modimport("postinit/heapofoods/" .. hof_postinit[k][i])
    end
end
