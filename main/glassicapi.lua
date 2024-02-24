local ENV = env
local GlassicAPI = ENV.GlassicAPI
GLOBAL.setfenv(1, GLOBAL)

if not GlassicAPI then
    GlassicAPI = rawget(ENV, "GlassicAPI")
end

GlassicAPI.ImportStringsFile = function(module_name, env)
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
