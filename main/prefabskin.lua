local Assets = Assets
GLOBAL.setfenv(1, GLOBAL)

function yari_init_fn(inst, build_name)
    if not TheWorld.ismastersim then
        return
    end

    inst.displaynamefn = function()
        return STRINGS.SKIN_NAMES[build_name]
    end

    basic_init_fn(inst, build_name, "yari")
end

function yari_clear_fn(inst)
    inst.displaynamefn = nil
    basic_clear_fn(inst, "yari")
end

local manutsawee = {}

for _, v in ipairs(M_SKIN_NAMES) do
    table.insert(manutsawee, "manutsawee_" .. v)
    table.insert(Assets, Asset("IMAGE", "bigportraits/manutsawee_" .. v .. ".tex"))
    table.insert(Assets, Asset("ATLAS", "bigportraits/manutsawee_" .. v .. ".xml"))
end

table.insert(manutsawee, "manutsawee_none")

GlassicAPI.SkinHandler.AddModSkins({
    manutsawee = manutsawee,
    cane = {"lcane"},
    yari = {"mnaginata"},
})
