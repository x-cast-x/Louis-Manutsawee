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

local Idle_Anim = {
    ["manutsawee_yukatalong"] = "idle_wendy",
    ["manutsawee_yukata"] = "idle_wendy",
    ["manutsawee_shinsengumi"] = "idle_wathgrithr",
    ["manutsawee_fuka"] = "idle_wathgrithr",
    ["manutsawee_sailor"] = "idle_walter",
    ["manutsawee_jinbei"] = "idle_wortox",
    ["manutsawee_maid"] = "idle_wanda",
    ["manutsawee_maid_m"] = "idle_wanda",
    ["manutsawee_lycoris"] = "idle_wanda",
    ["manutsawee_uniform_black"] = "idle_wanda",
    ["manutsawee_taohuu"] = "idle_winona",
    ["manutsawee_miko"] = "emote_impatient",
}

local Funny_Idle_Anim = {
    ["manutsawee_qipao"] = "wes_funnyidle",
    ["manutsawee_bocchi"] = "idle_bocchi",
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

local function OnKilled(inst, data)
    local target = data.victim
    local target_scale = (target:HasTag("smallcreature") and 1) or (target:HasTag("largecreature") and 4) or 2

    if target ~= nil and target_scale ~= nil then
        if not ((target:HasTag("prey")or target:HasTag("bird")or target:HasTag("insect")) and not target:HasTag("hostile")) and inst.components.sanity:GetPercent() <= .8  then
            inst.components.sanity:DoDelta(target_scale)
        end
    end
end

local common_postinit = function(inst)
    inst.MiniMapEntity:SetIcon("manutsawee.tex")

    inst:AddTag("bearded")

    -- for recipess
    inst:AddTag("tosho")

    inst:AddTag("kenjutsuka")

    inst:AddTag("naughtychild")

    inst:AddTag("stronggrip")
    inst:AddTag("handyperson")
    inst:AddTag("fastbuilder")
    inst:AddTag("hungrybuilder")
    inst:AddTag("ghostlyfriend")
    inst:AddTag("alchemist")
    inst:AddTag("ore_alchemistI")
    inst:AddTag("ick_alchemistI")
    inst:AddTag("ick_alchemistII")

    inst:AddComponent("keyhandler")
    inst.components.keyhandler:AddActionListener(LouisManutsawee, M_CONFIG.LEVEL_CHECK_KEY, "LevelCheck")
    inst.components.keyhandler:AddActionListener(LouisManutsawee, M_CONFIG.PUT_GLASSES_KEY, "PutGlasses")
    inst.components.keyhandler:AddActionListener(LouisManutsawee, M_CONFIG.CHANGE_HAIRS_KEY, "ChangeHairStyle")

    inst.components.keyhandler:AddActionListener(LouisManutsawee, M_CONFIG.SKILL1_KEY, "Skill1")
    inst.components.keyhandler:AddActionListener(LouisManutsawee, M_CONFIG.SKILL2_KEY, "Skill2")
    inst.components.keyhandler:AddActionListener(LouisManutsawee, M_CONFIG.SKILL3_KEY, "Skill3")
    inst.components.keyhandler:AddActionListener(LouisManutsawee, M_CONFIG.SKILL4_KEY, "Skill4")
    inst.components.keyhandler:AddActionListener(LouisManutsawee, M_CONFIG.SKILL_COUNTER_ATK_KEY, "CounterAttack")
    inst.components.keyhandler:AddActionListener(LouisManutsawee, M_CONFIG.QUICK_SHEATH_KEY, "QuickSheath")
    inst.components.keyhandler:AddActionListener(LouisManutsawee, M_CONFIG.SKILL_CANCEL_KEY, "SkillCancel")

    Manutsawee_Extensions.common_postinit(inst)
end

local master_postinit = function(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

    inst.AnimState:SetScale(0.88, 0.9, 1)

    inst:AddComponent("hair")
    inst:AddComponent("playerskillcontroller")
    inst.components.playerskillcontroller:RegisterSkillCooldownDoneEffect("ichimonji", "ghostlyelixir_retaliation_dripfx")
    inst.components.playerskillcontroller:RegisterSkillCooldownDoneEffect("ichimonji", "ghostlyelixir_shield_dripfx")
    inst.components.playerskillcontroller:RegisterSkillCooldownDoneEffect("ichimonji", "ghostlyelixir_speed_dripfx")
    inst.components.playerskillcontroller:RegisterSkillCooldownDoneEffect("ichimonji", "battlesong_instant_panic_fx")
    inst.components.playerskillcontroller:RegisterSkillCooldownDoneEffect("ichimonji", "monkey_deform_pre_fx")
    inst.components.playerskillcontroller:RegisterSkillCooldownDoneEffect("ichimonji", "fx_book_birds")
    inst.components.playerskillcontroller:RegisterSkillCooldownDoneEffect("ichimonji", "fx_book_birds")
    inst.components.playerskillcontroller:RegisterSkillCooldownDoneEffect("ichimonji", "fx_book_birds")
    inst.components.playerskillcontroller:RegisterSkillCooldownDoneEffect("ichimonji", "thunderbird_fx_idle")

    inst:AddComponent("glasses")
    inst.components.glasses:AddGlass("manutsawee_bocchi", "starglasses")
    inst.components.glasses:AddGlass("manutsawee_uniform_black", "sunglasses")

    inst:AddComponent("customidleanim")
    inst.components.customidleanim:SetIdleAnim(Idle_Anim, Funny_Idle_Anim)

    inst:AddComponent("kenjutsuka")
    inst.components.kenjutsuka:SetOnMindPowerRegen(OnMindPowerRegen)
    inst.components.kenjutsuka:AddLevelUpCallback(OnKenjutsuLevels)

    inst:AddComponent("houndedtarget")
    inst.components.houndedtarget.target_weight_mult:SetModifier(inst, TUNING.WES_HOUND_TARGET_MULT, "misfortune")
    inst.components.houndedtarget.hound_thief = true

    inst.components.foodaffinity:AddPrefabAffinity("baconeggs", TUNING.AFFINITY_15_CALORIES_HUGE)
    inst.components.foodaffinity:AddPrefabAffinity("unagi", TUNING.AFFINITY_15_CALORIES_TINY)
    inst.components.foodaffinity:AddPrefabAffinity("kelp_cooked", 1)
    inst.components.foodaffinity:AddPrefabAffinity("justeggs", 1)
    inst.components.foodaffinity:AddPrefabAffinity("durian", 1)
    inst.components.foodaffinity:AddPrefabAffinity("durian_cooked", 1)
    inst.components.foodaffinity:AddPrefabAffinity("californiaroll", TUNING.AFFINITY_15_CALORIES_TINY)
    inst.components.foodaffinity:AddPrefabAffinity("caviar", TUNING.AFFINITY_15_CALORIES_TINY)
    inst.components.foodaffinity:AddPrefabAffinity("caviar", TUNING.AFFINITY_15_CALORIES_TINY)
    inst.components.foodaffinity:AddPrefabAffinity("liceloaf", TUNING.AFFINITY_15_CALORIES_TINY)
    inst.components.foodaffinity:AddPrefabAffinity("blueberrypancakes", TUNING.AFFINITY_15_CALORIES_TINY)

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

    inst.soundsname = "wortox"
    inst.skeleton_prefab = nil

    inst:ListenForEvent("killed", OnKilled)

    Manutsawee_Extensions.master_postinit(inst)
end

return MakePlayerCharacter("manutsawee", prefabs, assets, common_postinit, master_postinit, start_inv)
