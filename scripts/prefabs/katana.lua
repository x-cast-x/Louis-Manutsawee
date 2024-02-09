local MakeKatana = require "prefabs/katana_def"

local katana_data = {
    "hitokiri",
    "shirasaya",
    "raikiri",
    "koshirae",
    -- "kurokatana"
}

local katana = {}
for _, v in pairs(katana_data) do
    local data = {
        name = v,
        build = v,
        damage = TUNING.KATANA.DAMAGE
    }
    table.insert(katana, MakeKatana(data))
end

return unpack(katana)
