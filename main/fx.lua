local fx = {
    "m_shadowhand_fx",
    "mforcefield",
}

for _, v in pairs(fx) do
    table.insert(PrefabFiles, v)
end

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
    {
        name = "m_battlesong_instant_electric_fx",
        bank = "fx_wathgrithr_buff",
        build = "fx_wathgrithr_buff",
        anim = "quote_electric",
    },
    {
        name = "fx_attack_pop",
        bank = "fx_dock_crackleandpop",
        build = "fx_dock_crackleandpop",
        anim = "pop",
        sound = "turnoftides/common/together/moon_glass/mine",
    },
}

-- Sneakily add these to the FX table
-- Also force-load the assets because the fx file won't do for some reason

local fx = require("fx")

for _, v in ipairs(m_fx) do
    table.insert(fx, v)
end
