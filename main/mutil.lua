local ENV = env
local RegisterInventoryItemAtlas = RegisterInventoryItemAtlas
local AddMinimapAtlas = AddMinimapAtlas
local resolvefilepath = GLOBAL.resolvefilepath
GLOBAL.setfenv(1, GLOBAL)

M_Util = {}
ENV.M_Util = M_Util

function M_Util.RegisterImageAtlas(atlas_path)
    local atlas = resolvefilepath(atlas_path)

    local file = io.open(atlas, "r")
    local data = file:read("*all")
    file:close()

    local str = string.gsub(data, "%s+", "")
    local _, _, elements = string.find(str, "<Elements>(.-)</Elements>")

    for s in string.gmatch(elements, "<Element(.-)/>") do
        local _, _, image = string.find(s, "name=\"(.-)\"")
        if image ~= nil then
            RegisterInventoryItemAtlas(atlas, image)
            RegisterInventoryItemAtlas(atlas, hash(image))  -- for client
        end
    end
end

function M_Util.AddMinimapAtlas(atlas_path, assets_table)
    local file_path = "images/map_icons/"..atlas_path
    if assets_table then
        table.insert(assets_table, Asset("ATLAS", file_path .. ".xml"))
        table.insert(assets_table, Asset("IMAGE", file_path .. ".tex"))
    end
    AddMinimapAtlas(file_path .. ".xml")
end

local function is_array(t)
    if type(t) ~= "table" or not next(t) then
        return false
    end

    local n = #t
    for i, v in pairs(t) do
        if type(i) ~= "number" or i <= 0 or i > n then
            return false
        end
    end

    return true
end

function M_Util.merge_table(target, add_table, override)
    target = target or {}

    for k, v in pairs(add_table) do
        if type(v) == "table" then
            if not target[k] then
                target[k] = {}
            elseif type(target[k]) ~= "table" then
                if override then
                    target[k] = {}
                else
                    error("Can not override" .. k .. " to a table")
                end
            end

            M_Util.merge_table(target[k], v, override)
        else
            if is_array(target) and not override then
                table.insert(target, v)
            elseif not target[k] or override then
                target[k] = v
            end
        end
    end
end

function M_Util.ImportStringsFile(module_name, env)
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
