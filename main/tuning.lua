local ENV = env
local TUNING = GLOBAL.TUNING
local KATANA = GLOBAL.KATANA
GLOBAL.setfenv(1, GLOBAL)

TUNING.MANUTSAWEE_HEALTH = 200
TUNING.MANUTSAWEE_HUNGER = 200
TUNING.MANUTSAWEE_SANITY = 200

local katana = KATANA[M_CONFIG.START_ITEM]

if katana then
    TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.MANUTSAWEE = {"tokijin", katana}
else
    TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.MANUTSAWEE = {"tokijin"}
end

-- Stop here if MiM enabled
if ENV.is_mim_enabled then
    return
end

local wilson_attack = TUNING.BASE_SURVIVOR_ATTACK

local tuning = {
    KATANA = {
        DAMAGE = wilson_attack * 2,
        TRUE_DAMAGE = wilson_attack * 2.4,
        USES = 800,
    },

    TOKIJIN_DAMAGE = wilson_attack * 1.9,
    HARAKIRI_DAMAGE = wilson_attack,
    YARI_DAMAGE = wilson_attack * 1.5,
    MNAGINATA_DAMAGE = wilson_attack * 1.5,

    HARAKIRI_USES = 200,
    YARI_USES = 300,
    MNAGINATA_USES = 300,
    BLADE_USES = 300,

    --mmiko_armor
    MMIKO_ARMOR_AMOUNT = 1500,
    MMIKO_ARMOR_PRECENT = 0.8,
    MMIKO_ARMOR_COOLDOWN = 3,
    MMIKO_ARMOR_DURATION = 8,

    MINGOT_WORK_REQUIRED = 4,
    MINGOT_LOOT = {
        WORK_MAX_SPAWNS = 10,
        LAUNCH_SPEED = -1.8,
        LAUNCH_HEIGHT = 0.5,
        LAUNCH_ANGLE = 65,
    },

    MANUTSAWEE = {
        HEALTH = M_CONFIG.HEALTH,
        HUNGER = M_CONFIG.HUNGER,
        SANITY = M_CONFIG.SANITY,
    }
}

if IA_ENABLED then
    tuning.MSURFBOARD_HEALTH = 300
    tuning.MSURFBOARD_SPEED = 4
end

for key, value in pairs(tuning) do
    if TUNING[key] then
        print("OVERRIDE: " .. key .. " in TUNING")
    end

    TUNING[key] = value
end
