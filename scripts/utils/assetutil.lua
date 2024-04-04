local RegisterInventoryItemAtlas = RegisterInventoryItemAtlas
local AddMinimapAtlas = AddMinimapAtlas
local resolvefilepath = GLOBAL.resolvefilepath

local function RegisterImageAtlas(atlas_path)
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

local function AddMinimap(atlas_path, assets_table)
    local file_path = "images/map_icons/"..atlas_path
    if assets_table then
        table.insert(assets_table, Asset("ATLAS", file_path .. ".xml"))
        table.insert(assets_table, Asset("IMAGE", file_path .. ".tex"))
    end
    AddMinimapAtlas(file_path .. ".xml")
end

return {
    RegisterImageAtlas = RegisterImageAtlas,
    AddMinimap = AddMinimap,
}
