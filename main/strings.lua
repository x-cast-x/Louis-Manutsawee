local ENV = env
local GlassicAPI = ENV.GlassicAPI
local MODROOT = MODROOT
local modimport = modimport
GLOBAL.setfenv(1, GLOBAL)

local strings = {
    CHARACTERS = {
        GENERIC = GlassicAPI.ImportStringsFile("generic", ENV),
        MANUTSAWEE = GlassicAPI.ImportStringsFile("manutsawee", ENV),
    }
}

local common = GlassicAPI.ImportStringsFile("common", ENV)

GlassicAPI.MergeStringsToGLOBAL(common)
GlassicAPI.MergeStringsToGLOBAL(strings)
GlassicAPI.MergeTranslationFromPO(MODROOT.."scripts/languages")

GeneratePOFile = function()
    local file, errormsg = io.open(MODROOT .. "scripts/languages/strings.pot", "w")
    if not file then
        print("Can't generate " .. MODROOT .. "scripts/languages/strings.pot" .. "\n" .. tostring(errormsg))
        return
    end
    GlassicAPI.MakePOTFromStrings(file, strings)
end

-- modimport("scripts/languages/porkland")
-- modimport("scripts/languages/uncompromisingmode")
