GLOBAL.setfenv(1, GLOBAL)

local katana = {
    "hitokiri",
    "shirasaya",
    "raikiri",
    "koshirae",
}

function c_getkatana()
    for i = 1, #katana do
        c_give(katana[i])
    end
end

function c_gettruekatana()
    for i = 1, #katana do
        c_give("true_" .. katana[i])
    end
end

function c_setmindpower(num)
    local player = ConsoleCommandPlayer()
    if player ~= nil and player.prefab == "manutsawee" then
        player.components.kenjutsuka:SetMindpower(num or 30)
    end
end

if not rawget(_G, "c_revealmap") then
    function c_revealmap()
        local size = 2 * TheWorld.Map:GetSize()
        local player = ThePlayer
        for x = -size, size, 32 do
            for z = -size, size, 32 do
                player.player_classified.MapExplorer:RevealArea(x, 0, z)
            end
        end
    end
end
