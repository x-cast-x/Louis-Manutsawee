local MakeKatana = require "prefabs/katana_def"

local katana_data = {
    "hitokiri",
    "shirasaya",
    "raikiri",
    "koshirae",
    -- "kurokatana"
}

local rets = {}
for _, v in pairs(katana_data) do
    local data = {
        name = v,
        build = v,
        damage = TUNING.KATANA.DAMAGE
    }
    table.insert(rets, MakeKatana(data))
end

return unpack(rets)
