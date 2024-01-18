local MakeKatana = require "prefabs/katana_def"

local katana_data = {
    "hitokiri",
    "shirasaya",
    "raikiri",
    "koshirae",
    "kurokatana"
}

local katana = {}
for _, v in pairs(katana_data) do
    table.insert(katana, MakeKatana({name = v, damage = TUNING.KATANA.DAMAGE}))
end

return unpack(katana)
