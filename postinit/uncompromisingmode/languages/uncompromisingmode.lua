local ENV = env
local STRINGS = GLOBAL.STRINGS
local GlassicAPI = ENV.GlassicAPI
local MODROOT = MODROOT
GLOBAL.setfenv(1, GLOBAL)

if not UM_ENABLED then
    return
end

local StringUtil = require("utils/stringutil")

local languages = {
    -- en = "strings.pot",
    -- de = "german",  -- german
    -- es = "spanish",  -- spanish
    -- fr = "french",  -- french
    -- it = "italian",  -- italian
    -- ko = "korean",  -- korean
    -- pt = "portuguese_br",  -- portuguese and brazilian portuguese
    -- br = "portuguese_br",  -- brazilian portuguese
    -- pl = "polish",  -- polish
    -- ru = "russian",  -- russian
    zh = "chinese_s",  -- chinese
    chs = "chinese_s", -- chinese mod
    sc = "chinese_s", -- simple chinese
    tc = "chinese_t", -- simple chinese
    cht = "chinese_t",  -- simple chinese
}

M_Util.merge_table(STRINGS.CHARACTERS.MANUTSAWEE, StringUtil.ImportStringsFile("um_manutsawee", ENV), true)
GlassicAPI.MergeTranslationFromPO(MODROOT.."postinit/uncompromisingmode/languages/um_", languages[M_CONFIG.locale])
