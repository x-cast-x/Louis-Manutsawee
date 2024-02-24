local ENV = env
local STRINGS = GLOBAL.STRINGS
local GlassicAPI = ENV.GlassicAPI
local MODROOT = MODROOT
GLOBAL.setfenv(1, GLOBAL)

if not PL_ENABLED then
    return
end

M_Util.merge_table(STRINGS.CHARACTERS.MANUTSAWEE, GlassicAPI.ImportStringsFile("pl_manutsawee", ENV))
GlassicAPI.MergeTranslationFromPO(MODROOT.."scripts/languages/pl_")
