local FOODTYPE = GLOBAL.FOODTYPE
local ENV = env
GLOBAL.setfenv(1, GLOBAL)

-- when MiM enabled, add it
if ENV.is_mim_enabled then
    -- No animation video, only github repository
    CHARACTER_VIDEOS["manutsawee"] = {"https://github.com/Manutsawee/Louis-Manutsawee"}
end

FOODTYPE.MFRUIT = "MFRUIT"

KATANA = {
    "shinai",
    "raikiri",
    "shirasaya",
    "koshirae",
    "hitokiri",
    "katanablade",
    "tokijin",
}

M_SKILLS = {
    "ichimonji",
    "flip",
    "thrust",
    "isshin",
    "heavenlystrike",
    "ryusen",
    "susanoo",
    "soryuha",
}

M_SKIN_NAMES = {
    "sailor",
    "yukata",
    "yukatalong",
    "yukatalong_purple",
    "miko",
    "qipao",
    "fuka",
    "maid",
    "jinbei",
    "shinsengumi",
    "taohuu",
    "uniform_black",
}
