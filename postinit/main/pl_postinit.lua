if not PL_ENABLED then
    return
end

local modimport = modimport

local porkland_postinit = {

}

for k, v in pairs(porkland_postinit) do
    for i = 1, #v do
        modimport("postinit/porkland/" .. k .. "/" .. porkland_postinit[k][i])
    end
end
