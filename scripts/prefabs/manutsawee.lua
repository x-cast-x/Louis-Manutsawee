local MakePlayerCharacter = require "prefabs/player_common"
local Manutsawee_Extensions = require "prefabs/manutsawee_extensions"

local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),

    Asset("ANIM", "anim/hair_cut.zip"),
    Asset("ANIM", "anim/hair_short.zip"),
    Asset("ANIM", "anim/hair_medium.zip"),
    Asset("ANIM", "anim/hair_long.zip"),

    Asset("ANIM", "anim/hair_short_pony.zip"),
    Asset("ANIM", "anim/hair_medium_pony.zip"),
    Asset("ANIM", "anim/hair_long_pony.zip"),

    Asset("ANIM", "anim/hair_short_twin.zip"),
    Asset("ANIM", "anim/hair_medium_twin.zip"),
    Asset("ANIM", "anim/hair_long_twin.zip"),

    Asset("ANIM", "anim/hair_short_htwin.zip"),
    Asset("ANIM", "anim/hair_medium_htwin.zip"),
    Asset("ANIM", "anim/hair_long_htwin.zip"),

    Asset("ANIM", "anim/hair_short_yoto.zip"),
    Asset("ANIM", "anim/hair_medium_yoto.zip"),
    Asset("ANIM", "anim/hair_long_yoto.zip"),

    Asset("ANIM", "anim/hair_short_ronin.zip"),
    Asset("ANIM", "anim/hair_medium_ronin.zip"),
    Asset("ANIM", "anim/hair_long_ronin.zip"),

    Asset("ANIM", "anim/hair_short_ball.zip"),
    Asset("ANIM", "anim/hair_medium_ball.zip"),
    Asset("ANIM", "anim/hair_long_ball.zip"),

    Asset("ANIM", "anim/eyeglasses.zip"),
    Asset("ANIM", "anim/sunglasses.zip"),
    Asset("ANIM", "anim/starglasses.zip"),

    Asset("ANIM", "anim/face_controlled.zip"),

	Asset("ANIM", "anim/wendy_recall.zip"),

    Asset("ANIM", "anim/player_idles_bocchi.zip"),
    Asset("ANIM", "anim/player_idles_walter.zip"),
    Asset("ANIM", "anim/player_idles_winona.zip"),
    Asset("ANIM", "anim/player_idles_wathgrithr.zip"),
    Asset("ANIM", "anim/player_idles_wanda.zip"),
    Asset("ANIM", "anim/player_idles_wendy.zip"),
    Asset("ANIM", "anim/player_idles_wilson.zip"),
    Asset("ANIM", "anim/player_idles_wortox.zip"),
    Asset("ANIM", "anim/player_idles_wes.zip"),
    Asset("ANIM", "anim/player_idles_willow.zip"),
}

local prefabs = {
    "m_battlesong_instant_electric_fx",
    "fx_book_light_upgraded",
}

local unlockrecipes = {
    "rainhat",
    -- "portabletent_item",
    "bedroll_shraw",
}

local LouisManutsawee = "LouisManutsawee"

local start_inv = {}

for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.MANUTSAWEE
end

prefabs = FlattenTree({prefabs, start_inv}, true)

local function OnMindPowerRegen(inst, mindpower)
    local mindregenfx = SpawnPrefab("m_battlesong_instant_electric_fx")
    mindregenfx.Transform:SetScale(.7, .7, .7)
    mindregenfx.Transform:SetPosition(inst:GetPosition():Get())
    mindregenfx.entity:AddFollower()
    mindregenfx.Follower:FollowSymbol(inst.GUID, "swap_body", 0, 0, 0)
    if mindpower >= 3 then
        inst.components.talker:Say("󰀈: ".. mindpower .."\n", 2, true)
    end
end

local OnKenjutsuLevels = {
    [1] = function(inst, kenjutsulevel, kenjutsuexp)
        if kenjutsulevel >= 1 then
            inst.components.sanity.neg_aura_mult = 1 - ((kenjutsulevel / 2) / 10)
            inst.components.kenjutsuka.kenjutsumaxexp = 500 * kenjutsulevel

            local hunger_percent = inst.components.hunger:GetPercent()
            local health_percent = inst.components.health:GetPercent()
            local sanity_percent = inst.components.sanity:GetPercent()

            if M_CONFIG.HEALTH_MAX > 0 then
                inst.components.health.maxhealth = math.ceil(TUNING.MANUTSAWEE.HEALTH + kenjutsulevel * M_CONFIG.HEALTH_MAX)
                inst.components.health:SetPercent(health_percent)
            end
            if M_CONFIG.HUNGER_MAX > 0 then
                inst.components.hunger.max = math.ceil(TUNING.MANUTSAWEE.HUNGER + kenjutsulevel * M_CONFIG.HUNGER_MAX)
                inst.components.hunger:SetPercent(hunger_percent)
            end
            if M_CONFIG.SANITY_MAX > 0 then
                inst.components.sanity.max = math.ceil(TUNING.MANUTSAWEE.SANITY + kenjutsulevel * M_CONFIG.SANITY_MAX)
                inst.components.sanity:SetPercent(sanity_percent)
            end
        end
    end,
    [2] = function(inst, kenjutsulevel, kenjutsuexp)
        if kenjutsulevel >= 2 and not inst:HasTag("kenjutsu") then
            inst:AddTag("kenjutsu")
        end
    end,
    [3] = function(inst, kenjutsulevel, kenjutsuexp)
        if kenjutsulevel >= 4 then
            inst.components.kenjutsuka:StartRegenMindPower()
        end
    end,
    [4] = function(inst, kenjutsulevel, kenjutsuexp)
        if kenjutsulevel >= 4 then
            inst.components.kenjutsuka:StartRegenMindPower()
        end
    end,
    [5] = function(inst, kenjutsulevel, kenjutsuexp)
        if kenjutsulevel >= 5 then
            if not inst:HasTag("katanakaji") then
                inst:AddTag("katanakaji")
            end
            inst.components.sanity:AddSanityAuraImmunity("ghost")
            inst.components.workmultiplier:AddMultiplier(ACTIONS.CHOP,   1, inst)
            inst.components.workmultiplier:AddMultiplier(ACTIONS.MINE,   1, inst)
            inst.components.workmultiplier:AddMultiplier(ACTIONS.HAMMER, 1, inst)

            if inst.components.builder ~= nil then
                for k, recipe in pairs(unlockrecipes) do
                    inst.components.builder:UnlockRecipe(recipe)
                end
            end
        end
    end,
    [6] = function(inst, kenjutsulevel, kenjutsuexp)
        if kenjutsulevel >= 6 then
            inst.components.temperature.inherentinsulation = TUNING.INSULATION_TINY /2
            inst.components.temperature.inherentsummerinsulation = TUNING.INSULATION_TINY /2
            inst.components.sanity:SetPlayerGhostImmunity(true)
        end
    end,
    [7] = function(inst, kenjutsulevel, kenjutsuexp)
        if kenjutsulevel >= 10 then
            kenjutsuexp = 0
        end
    end
}

local function OnKenjutsuLevelUp(inst, kenjutsulevel, kenjutsuexp)
    inst.components.kenjutsuka:SetMaxMindpower(M_CONFIG.MIND_MAX + kenjutsulevel)

    local fx = SpawnPrefab("fx_book_light_upgraded")
    fx.Transform:SetScale(.9, 2.5, 1)
    fx.entity:AddFollower()
    fx.Follower:FollowSymbol(inst.GUID, "swap_body", 0, 0, 0)
end

local function OnKilled(inst, data)
    local target = data.victim
    local scale = (target:HasTag("smallcreature") and 1) or (target:HasTag("largecreature") and 4) or 2

    if target ~= nil and scale ~= nil then
        if not ((target:HasTag("prey")or target:HasTag("bird")or target:HasTag("insect")) and not target:HasTag("hostile")) and inst.components.sanity:GetPercent() <= .8  then
            inst.components.sanity:DoDelta(scale)
        end
    end
end

local function OnSave(inst, data)
    data._health = inst.components.health.currenthealth
    data._sanity = inst.components.sanity.current
    data._hunger = inst.components.hunger.current
end

local function OnLoad(inst, data)
    if data ~= nil then
        if inst.components.kenjutsuka ~= nil and inst.components.kenjutsuka:GetKenjutsuLevel() > 0 and data._health ~= nil and data._sanity ~= nil and data._hunger ~= nil then
            inst.components.health:SetCurrentHealth(data._health)
            inst.components.sanity.current = data._sanity
            inst.components.hunger.current = data._hunger
        end
    end
end

local common_postinit = function(inst)
    inst.MiniMapEntity:SetIcon("manutsawee.tex")

    inst:AddTag("bearded")
    inst:AddTag("bladesmith")
    inst:AddTag("stronggrip")
    inst:AddTag("handyperson")
    inst:AddTag("fastbuilder")
    inst:AddTag("hungrybuilder")
    inst:AddTag("naughtychild")
    inst:AddTag("ghostlyfriend")
    inst:AddTag("alchemist")
    inst:AddTag("ore_alchemistI")
    inst:AddTag("ick_alchemistI")
    inst:AddTag("ick_alchemistII")
    inst:AddTag("kenjutsuka")

    inst:AddComponent("keyhandler")
    inst.components.keyhandler:AddActionListener(LouisManutsawee, M_CONFIG.LEVEL_CHECK_KEY, "LevelCheck")
    inst.components.keyhandler:AddActionListener(LouisManutsawee, M_CONFIG.PUT_GLASSES_KEY, "PutGlasses")
    inst.components.keyhandler:AddActionListener(LouisManutsawee, M_CONFIG.CHANGE_HAIRS_KEY, "ChangeHairsStyle")

    Manutsawee_Extensions.common_postinit(inst)
end

local function RegisterEventListeners(inst)
    inst:ListenForEvent("killed", OnKilled)
end

local function SetInstanceFunctions(inst)
    inst.OnLoad = OnLoad
    inst.OnSave = OnSave
end

local function SetInstanceValue(inst)
    inst.soundsname = "wortox"
    inst.skeleton_prefab = nil
end

local master_postinit = function(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

    inst.AnimState:SetScale(0.88, 0.9, 1)

    inst:AddComponent("hair")
    inst:AddComponent("glasses")
    inst:AddComponent("playerskillmanager")
    inst:AddComponent("customidleanim")

    inst:AddComponent("kenjutsuka")
    inst.components.kenjutsuka:SetOnLevelUp(OnKenjutsuLevelUp)
    inst.components.kenjutsuka:SetOnMindPowerRegenFn(OnMindPowerRegen)
    inst.components.kenjutsuka:AddLevelUpFns(OnKenjutsuLevels)

    inst:AddComponent("houndedtarget")
    inst.components.houndedtarget.target_weight_mult:SetModifier(inst, TUNING.WES_HOUND_TARGET_MULT, "misfortune")
    inst.components.houndedtarget.hound_thief = true

    inst.components.foodaffinity:AddPrefabAffinity("baconeggs", TUNING.AFFINITY_15_CALORIES_HUGE)
    inst.components.foodaffinity:AddPrefabAffinity("unagi", TUNING.AFFINITY_15_CALORIES_TINY)
    inst.components.foodaffinity:AddPrefabAffinity("kelp_cooked", 1)
    inst.components.foodaffinity:AddPrefabAffinity("justeggs", 1)
    -- The original author is Thai?
    -- I heard that Thai durian is very famous
    inst.components.foodaffinity:AddPrefabAffinity("durian", 1)
    inst.components.foodaffinity:AddPrefabAffinity("durian_cooked", 1)

    inst.components.health:SetMaxHealth(TUNING.MANUTSAWEE.HEALTH)
    inst.components.hunger:SetMax(TUNING.MANUTSAWEE.HUNGER)
    inst.components.sanity:SetMax(TUNING.MANUTSAWEE.SANITY)
    inst.components.hunger:SetRate(TUNING.WILSON_HUNGER_RATE * 1.3)

    inst.components.combat.damagemultiplier = 1
    inst.components.grogginess.decayrate = TUNING.WES_GROGGINESS_DECAY_RATE
    inst.components.temperature.inherentinsulation = -TUNING.INSULATION_TINY
    inst.components.temperature.inherentsummerinsulation = -TUNING.INSULATION_TINY

    if inst.components.eater ~= nil then
        inst.components.eater:SetCanEatMfruit()
        inst.components.eater:SetRejectEatingTag("terriblefood")
    end

    inst.components.workmultiplier:AddMultiplier(ACTIONS.CHOP,   TUNING.WES_WORKEFFECTIVENESS_MODIFIER, inst)
    inst.components.workmultiplier:AddMultiplier(ACTIONS.MINE,   TUNING.WES_WORKEFFECTIVENESS_MODIFIER, inst)
    inst.components.workmultiplier:AddMultiplier(ACTIONS.HAMMER, TUNING.WES_WORKEFFECTIVENESS_MODIFIER, inst)

    inst:AddComponent("efficientuser")
    inst.components.efficientuser:AddMultiplier(ACTIONS.CHOP,   TUNING.WES_WORKEFFECTIVENESS_MODIFIER, inst)
    inst.components.efficientuser:AddMultiplier(ACTIONS.MINE,   TUNING.WES_WORKEFFECTIVENESS_MODIFIER, inst)
    inst.components.efficientuser:AddMultiplier(ACTIONS.HAMMER, TUNING.WES_WORKEFFECTIVENESS_MODIFIER, inst)
    inst.components.efficientuser:AddMultiplier(ACTIONS.ATTACK, TUNING.WES_WORKEFFECTIVENESS_MODIFIER, inst)

    SetInstanceFunctions(inst)
    SetInstanceValue(inst)
    RegisterEventListeners(inst)

    Manutsawee_Extensions.master_postinit(inst)
end

return MakePlayerCharacter("manutsawee", prefabs, assets, common_postinit, master_postinit, start_inv)
