local ENV = env
local STRINGS = GLOBAL.STRINGS
local path = "scripts/languages/"
GLOBAL.setfenv(1, GLOBAL)
require("translator")

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
    tc = "chinese_t", -- traditional chinese
    cht = "chinese_t",  -- traditional chinese
    zht = "chinese_t",  -- traditional chinese
}

local speech = {
    "manutsawee",
}

local new_speech = {
    "generic",
}

local ia_speech = {
    "ia_manutsawee",
}

local pl_speech = {
    "pl_manutsawee",
}

local um_speech = {
    "um_manutsawee",
}

local function import(module_name, env)
    module_name = module_name .. ".lua"
    print("modimport (strings file): " .. env.MODROOT .. "strings/" .. module_name)
    local result = kleiloadlua(env.MODROOT .. "strings/" .. module_name)

    if result == nil then
        error("Error in custom import: Stringsfile " .. module_name .. " not found!")
    elseif type(result) == "string" then
        error("Error in custom import: Pork Land importing strings/" .. module_name .. "!\n" .. result)
    else
        setfenv(result, env) -- in case we use mod data
        return result()
    end
end

M_Util.merge_table(STRINGS, import("common", ENV))

local IsTheFrontEnd = rawget(_G, "TheFrontEnd") and rawget(_G, "IsInFrontEnd") and IsInFrontEnd()

local function TranslateString(prefix)
    local desiredlang = nil
    local M_CONFIG = rawget(_G, "M_CONFIG")
    if M_CONFIG and M_CONFIG.locale then
        desiredlang = M_CONFIG.locale
    elseif (IsTheFrontEnd or M_CONFIG) and LanguageTranslator.defaultlang then  -- only use default in FrontEnd or if locale is not set
        desiredlang = LanguageTranslator.defaultlang
    end

    if desiredlang and languages[desiredlang] then
        local temp_lang = desiredlang .. "_temp"

        ENV.LoadPOFile(path .. languages[desiredlang] .. ".po", temp_lang)
        M_Util.merge_table(LanguageTranslator.languages[desiredlang], LanguageTranslator.languages[temp_lang])
        TranslateStringTable(STRINGS)
        LanguageTranslator.languages[temp_lang] = nil
        LanguageTranslator.defaultlang = desiredlang
    end
end

local function LoadString(speech)
    if not IsTheFrontEnd then
        for _, character in pairs(speech) do
            M_Util.merge_table(STRINGS.CHARACTERS[string.upper(character)], import(character, ENV))
        end
    end
end

for _, character in pairs(speech) do
    STRINGS.CHARACTERS[string.upper(character)] = import(character, ENV)
end

TranslateString()
LoadString(new_speech)

-- if IA_ENABLED then
--     TranslateString("ia_")
--     LoadString(ia_speech)
-- end

-- if PL_ENABLED then
--     TranslateString("pl_")
--     LoadString(pl_speech)
-- end

-- if UM_ENABLED then
--     TranslateString("um_")
--     LoadString(um_speech)
-- end
