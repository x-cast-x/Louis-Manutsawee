if not IA_ENABLED then
    return
end

local modimport = modimport

local shipwrecked_postinit = {

}

for k, v in pairs(shipwrecked_postinit) do
    for i = 1, #v do
        modimport("postinit/shipwrecked/" .. shipwrecked_postinit[k][i])
    end
end
