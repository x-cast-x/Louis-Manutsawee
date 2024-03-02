GLOBAL.setfenv(1, GLOBAL)

local manutsawee = {}

for _, v in ipairs(M_SKIN_NAMES) do
    table.insert(manutsawee, "manutsawee_" .. v)
end

table.insert(manutsawee, "manutsawee_none")

GlassicAPI.SkinHandler.AddModSkins({
    manutsawee = manutsawee
})
