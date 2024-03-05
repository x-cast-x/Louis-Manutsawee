local ENV = env
local GlassicAPI = ENV.GlassicAPI
local MODROOT = MODROOT
local modimport = modimport
GLOBAL.setfenv(1, GLOBAL)

local languages = {
    -- en = "strings.pot",
    de = "german",  -- german
    es = "spanish",  -- spanish
    fr = "french",  -- french
    it = "italian",  -- italian
    ko = "korean",  -- korean
    pt = "portuguese_br",  -- portuguese and brazilian portuguese
    br = "portuguese_br",  -- brazilian portuguese
    pl = "polish",  -- polish
    ru = "russian",  -- russian
    zh = "chinese_s",  -- chinese
    chs = "chinese_s", -- chinese mod
    sc = "chinese_s", -- simple chinese
    tc = "chinese_t", -- simple chinese
    cht = "chinese_t",  -- simple chinese
}

local strings = {
    CHARACTERS = {
        GENERIC = GlassicAPI.ImportStringsFile("generic", ENV),
        MANUTSAWEE = GlassicAPI.ImportStringsFile("manutsawee", ENV),
    }
}

local common = GlassicAPI.ImportStringsFile("common", ENV)

GlassicAPI.MergeStringsToGLOBAL(common)
GlassicAPI.MergeStringsToGLOBAL(strings)
GlassicAPI.MergeTranslationFromPO(MODROOT.."scripts/languages", languages[M_CONFIG.locale])

-- modimport("scripts/languages/porkland")
-- modimport("scripts/languages/uncompromisingmode")
