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
        player.mindpower = num or 30
        player.components.talker:Say("Mindpower: " .. player.mindpower)
    end
end
