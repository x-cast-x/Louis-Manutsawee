table.insert(PrefabFiles, "mforcefield")

local Assets = Assets
GLOBAL.setfenv(1, GLOBAL)

local function SetSortOrder(inst)
    inst.AnimState:SetSortOrder(2)
end

local m_fx = {
    {
        name = "thunderbird_fx_idle",
        bank = "thunderbird_fx",
        build = "thunderbird_fx",
        anim = "idle",
        fn = SetSortOrder,
    },
    {
        name = "thunderbird_fx_shoot",
        bank = "thunderbird_fx",
        build = "thunderbird_fx",
        anim = "shoot",
        fn = SetSortOrder,
    },
    {
        name = "thunderbird_fx_charge_loop",
        bank = "thunderbird_fx",
        build = "thunderbird_fx",
        anim = "charge_loop",
        fn = SetSortOrder,
    },
    {
        name = "thunderbird_fx_charge_pre",
        bank = "thunderbird_fx",
        build = "thunderbird_fx",
        anim = "charge_pre",
        fn = SetSortOrder,
    },
    {
        name = "thunderbird_fx_charge_pst",
        bank = "thunderbird_fx",
        build = "thunderbird_fx",
        anim = "charge_pst",
        fn = SetSortOrder,
    },
}

-- Sneakily add these to the FX table
-- Also force-load the assets because the fx file won't do for some reason

local fx = require("fx")

for _, v in ipairs(m_fx) do
    table.insert(fx, v)
    if Settings.last_asset_set ~= nil then
        table.insert(Assets, Asset("ANIM", "anim/" .. v.build .. ".zip"))
    end
end
