local MakePlayerCharacter = require "prefabs/player_common"
local Skill_Data = require "skill_data"

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

local UnlockRecipes = {
    "rainhat",
    "portabletent_item",
}

local enable_idle_anim = M_CONFIG.IDLE_ANIMATION
local LouisManutsawee = "LouisManutsawee"

local start_inv = {}

for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.MANUTSAWEE
end

prefabs = FlattenTree({prefabs, start_inv}, true)

local function SkillRemove(inst)
    inst.components.skillreleaser:SkillRemove()
end

local function OnDeath(inst)
    local fx = SpawnPrefab("fx_book_light_upgraded")
    local x, y, z = inst.Transform:GetWorldPosition()
    fx.Transform:SetScale(.9, 2.5, 1)
    fx.Transform:SetPosition(x, y, z)

    SkillRemove(inst)
end

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

local HAIR_BITS = {"cut", "short", "medium", "long"}
local HAIR_TYPES = {"", "_yoto", "_ronin", "_pony", "_twin", "_htwin", "_ball"}
local function OnChangeHair(inst, skinname)
    if inst.hair_long == 1 and inst.hair_type > 1 then
        inst.hair_type = 1
    end

    if skinname == nil then
        -- When loading, bocchi's headgear will be pushed off. I don't want to deal with it anymore.
        local override_build = "hair_" .. HAIR_BITS[inst.hair_long] .. HAIR_TYPES[inst.hair_type]
        inst.AnimState:OverrideSymbol("hairpigtails", override_build, "hairpigtails")
        inst.AnimState:OverrideSymbol("hair", override_build, "hair")
        inst.AnimState:OverrideSymbol("hair_hat", override_build, "hair_hat")
        inst.AnimState:OverrideSymbol("headbase", override_build, "headbase")
        inst.AnimState:OverrideSymbol("headbase_hat", override_build, "headbase_hat")
    else
        inst.AnimState:OverrideSkinSymbol("hairpigtails", skinname, "hairpigtails")
        inst.AnimState:OverrideSkinSymbol("hair", skinname, "hair")
        inst.AnimState:OverrideSkinSymbol("hair_hat", skinname, "hair_hat")
        inst.AnimState:OverrideSkinSymbol("headbase", skinname, "headbase")
        inst.AnimState:OverrideSkinSymbol("headbase_hat", skinname, "headbase_hat")
    end

    if inst.hair_type <= 2 then
        inst.components.beard.insulation_factor = 1
    else
        inst.components.beard.insulation_factor = .1
    end
end

local glasses_map = {
    ["manutsawee_uniform_black"] = "sunglasses",
    ["manutsawee_bocchi"] = "starglasses",
}

local function PutGlasses(inst)
    local skinname = glasses_map[inst.AnimState:GetBuild()]
    if skinname ~= nil then
        inst.AnimState:OverrideSymbol("swap_face", skinname, "swap_face")
    else
        inst.AnimState:OverrideSymbol("swap_face", "eyeglasses", "swap_face")
    end
end

local function OnUpgrades(inst, kenjutsulevel, kenjutsuexp)
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

    if kenjutsulevel >= 2 and not inst:HasTag("kenjutsu") then
        inst:AddTag("kenjutsu")
    end

    if kenjutsulevel >= 4 then
        inst.components.kenjutsuka:StartRegenMindPower()
    end

    if kenjutsulevel >= 5 then
        if not inst:HasTag("katanakaji") then
            inst:AddTag("katanakaji")
        end
        inst.components.sanity:AddSanityAuraImmunity("ghost")
        inst.components.workmultiplier:AddMultiplier(ACTIONS.CHOP,   1, inst)
        inst.components.workmultiplier:AddMultiplier(ACTIONS.MINE,   1, inst)
        inst.components.workmultiplier:AddMultiplier(ACTIONS.HAMMER, 1, inst)

        if inst.components.builder ~= nil then
            for k, recipe in pairs(UnlockRecipes) do
                inst.components.builder:UnlockRecipe(recipe)
            end
        end
    end

    if kenjutsulevel >= 6 then
        inst.components.temperature.inherentinsulation = TUNING.INSULATION_TINY /2
        inst.components.temperature.inherentsummerinsulation = TUNING.INSULATION_TINY /2
        inst.components.sanity:SetPlayerGhostImmunity(true)
    end

    if kenjutsulevel >= 10 then
        kenjutsuexp = 0
    end

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
    data._louis_health = inst.components.health.currenthealth
    data._louis_sanity = inst.components.sanity.current
    data._louis_hunger = inst.components.hunger.current
    data.hair_long = inst.hair_long
    data.hair_type = inst.hair_type
    data.glasses_status = inst.glasses_status
end

local function OnLoad(inst, data)
    if data ~= nil then
        if inst.components.kenjutsuka ~= nil and inst.components.kenjutsuka:GetKenjutsuLevel() > 0 and data._louis_health ~= nil and data._mlouis_sanity ~= nil and data._louis_hunger ~= nil then
            inst.components.health:SetCurrentHealth(data._louis_health)
            inst.components.sanity.current = data._louis_sanity
            inst.components.hunger.current = data._louis_hunger
        end

        if data.hair_long ~= nil then
            inst.hair_long = data.hair_long
        end

        if data.hair_type ~= nil then
            inst.hair_type = data.hair_type
        end

        if data.glasses_status ~= nil then
            inst.glasses_status = data.glasses_status
            if inst.glasses_status then
                PutGlasses(inst)
            else
                inst.AnimState:ClearOverrideSymbol("swap_face")
            end
        end

        OnChangeHair(inst)
    end
end

local function OnEat(inst, food)
    if food ~= nil and food.components.edible ~= nil then
        if food.prefab == "mfruit" and inst.components.kenjutsuka:GetKenjutsuLevel() < 10 then
            inst.components.kenjutsuka:KenjutsuLevelUp()
        end
    end
end

local function GetPointSpecialActions(inst, pos, useitem, right)
    local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    local rider = inst.replica.rider
    if equip ~= nil and not (equip:HasTag("iai") or equip:HasTag("katana_quickdraw")) and equip:HasTag("katanaskill") and inst:HasTag("kenjutsu") and right and GetTime() - inst.last_dodge_time > inst.dodge_cooldown and not inst:HasTag("sitting_on_chair") and not inst.sg:HasStateTag("boating") then
        if rider == nil or not rider:IsRiding() then
            return {ACTIONS.MDODGE}
        end
    elseif inst:HasTag("kenjutsu") and right and GetTime() - inst.last_dodge_time > inst.dodge_cooldown and not inst:HasTag("sitting_on_chair") then
        if rider == nil or not rider:IsRiding() and not inst.sg:HasStateTag("boating") then
            return {ACTIONS.MDODGE2}
        end
    end
    return {}
end

local function OnSetOwner(inst)
    if inst.components.playeractionpicker ~= nil then
        inst.components.playeractionpicker.pointspecialactionsfn = GetPointSpecialActions
    end
end

local common_postinit = function(inst)
    inst.MiniMapEntity:SetIcon("manutsawee.tex")

    if M_CONFIG.IDLE_ANIMATION then
        inst.AnimState:AddOverrideBuild("player_idles_wes")
        inst.AnimState:AddOverrideBuild("player_idles_wendy")
        inst.AnimState:AddOverrideBuild("player_idles_wanda")
    end

    inst:AddTag("bearded")
    inst:AddTag("bladesmith")
    inst:AddTag("stronggrip")
    inst:AddTag("handyperson")
    inst:AddTag("fastbuilder")
    inst:AddTag("hungrybuilder")
    inst:AddTag("naughtychild")
    inst:AddTag("miko")
    inst:AddTag("ghostlyfriend")
    inst:AddTag("alchemist")
    inst:AddTag("ore_alchemistI")
    inst:AddTag("ick_alchemistI")
    inst:AddTag("ick_alchemistII")

    if IA_ENABLED then
        inst:AddTag("surfer")
    end

    if M_CONFIG.CANCRAFTTENT then
        inst:AddTag("pinetreepioneer")
    end

    if M_CONFIG.CANUSESLINGSHOT then
        inst:AddTag("slingshot_sharpshooter")
        inst:AddTag("pebblemaker")
    end

    inst:AddComponent("keyhandler")
    inst.components.keyhandler:AddActionListener(LouisManutsawee, M_CONFIG.LEVEL_CHECK_KEY, "LevelCheck")
    inst.components.keyhandler:AddActionListener(LouisManutsawee, M_CONFIG.PUT_GLASSES_KEY, "PutGlasses")
    inst.components.keyhandler:AddActionListener(LouisManutsawee, M_CONFIG.CHANGE_HAIRS_KEY, "ChangeHairsStyle")

    if M_CONFIG.ENABLE_SKILL then
        inst.components.keyhandler:AddActionListener(LouisManutsawee, M_CONFIG.SKILL1_KEY, "Skill1")
        inst.components.keyhandler:AddActionListener(LouisManutsawee, M_CONFIG.SKILL2_KEY, "Skill2")
        inst.components.keyhandler:AddActionListener(LouisManutsawee, M_CONFIG.SKILL3_KEY, "Skill3")
        inst.components.keyhandler:AddActionListener(LouisManutsawee, M_CONFIG.SKILL4_KEY, "Skill4")
        inst.components.keyhandler:AddActionListener(LouisManutsawee, M_CONFIG.SKILL_COUNTER_ATK_KEY, "CounterAttack")
        inst.components.keyhandler:AddActionListener(LouisManutsawee, M_CONFIG.QUICK_SHEATH_KEY, "QuickSheath")
        inst.components.keyhandler:AddActionListener(LouisManutsawee, M_CONFIG.SKILL_CANCEL_KEY, "SkillCancel")
    end

    if M_CONFIG.ENABLE_DODGE then
        inst.dodgetime = net_bool(inst.GUID, "player.dodgetime", "dodgetimedirty")
        inst:ListenForEvent("dodgetimedirty", function()
            inst.last_dodge_time = GetTime()
        end)
        inst.dodge_cooldown = M_CONFIG.DODGE_CD
        inst:ListenForEvent("setowner", OnSetOwner)
        inst.last_dodge_time = GetTime()
    end
end

local BEARD_DAYS = {3, 7, 16}
local BEARD_BITS = {2, 3, 3}
local function OnGrowShortHair(inst, skinname)
    inst.hair_long = 2
    inst.components.beard.bits = BEARD_BITS[1]
    OnChangeHair(inst, skinname)
end

local function OnGrowMediumHair(inst, skinname)
    inst.hair_long = 3
    inst.components.beard.bits = BEARD_BITS[2]
    OnChangeHair(inst, skinname)
end

local function OnGrowLongHair(inst, skinname)
    inst.hair_long = 4
    inst.components.beard.bits = BEARD_BITS[3]
    OnChangeHair(inst, skinname)
end

local function OnResetHair(inst, skinname)
    if inst.hair_long == 4 then
        inst.components.beard.daysgrowth = BEARD_DAYS[2]
        OnGrowMediumHair(inst, skinname)
    elseif inst.hair_long == 3 then
        inst.components.beard.daysgrowth = BEARD_DAYS[1]
        OnGrowShortHair(inst, skinname)
    else
        inst.hair_long = 1
        inst.hair_type = 1
        inst.AnimState:ClearOverrideSymbol("hairpigtails")
        inst.AnimState:ClearOverrideSymbol("hair")
        inst.AnimState:ClearOverrideSymbol("hair_hat")
        inst.AnimState:ClearOverrideSymbol("headbase")
        inst.AnimState:ClearOverrideSymbol("headbase_hat")
    end
end

local function OnEquip(inst, data)
    local item = data.item
    if item ~= nil and (item.prefab == "onemanband" or item.prefab == "armorsnurtleshell") then
        if not inst:HasTag("notshowscabbard") then
            inst:AddTag("notshowscabbard")
        end
    end

    if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) ~= nil then
        OnChangeHair(inst)
    end
end

local function OnUnEquip(inst, data)
    local item = data.item
    if item ~= nil and (item.prefab == "onemanband" or item.prefab == "armorsnurtleshell") then
        if inst:HasTag("notshowscabbard") then
            inst:RemoveTag("notshowscabbard")
        end
    end

    if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) == nil then
        SkillRemove(inst)
    end
end

local function OnDroped(inst, data)
    local item = data ~= nil and (data.prev_item or data.item)

    if item ~= nil and item:HasTag("katanaskill") and not item:HasTag("woodensword") then
        if not inst:HasTag("notshowscabbard") then
            inst.AnimState:ClearOverrideSymbol("swap_body_tall")
        end
    end
end

local function SwitchControlled(inst, enabled)
    local grogginess = inst.components.grogginess

    if grogginess ~= nil and not inst:HasTag("playerghost") then
        if enabled then
            inst:AddTag("groggy")
            inst:AddTag("controlled")
            inst.AnimState:OverrideSymbol("face", "face_controlled", "face")
            local pct = grogginess.grog_amount < grogginess:GetResistance() and grogginess.grog_amount / grogginess:GetResistance() or 1
            grogginess.speedmod = Remap(pct, 1, 0, TUNING.MIN_GROGGY_SPEED_MOD, TUNING.MAX_GROGGY_SPEED_MOD)
            inst.components.locomotor:SetExternalSpeedMultiplier(inst, "controlled", grogginess.speedmod)
            if inst.components.sanity ~= nil then
                inst.components.sanity:SetInducedInsanity(inst, true)
            end
        else
            inst:RemoveTag("groggy")
            inst:RemoveTag("controlled")
            inst.AnimState:ClearOverrideSymbol("face")
            grogginess.speedmod = nil
            inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "controlled")
            if inst.components.sanity ~= nil then
                inst.components.sanity:SetInducedInsanity(inst, false)
            end
        end
    end
end

local OnStrike = function(inst)
    local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if weapon ~= nil and weapon:HasTag("lightningcutter") then
        local electricchargedfx = SpawnPrefab("electricchargedfx")
        electricchargedfx.entity:AddFollower()
        electricchargedfx.Follower:FollowSymbol(inst.GUID)

        local thunderbird_fx_charge_loop = SpawnPrefab("thunderbird_fx_charge_loop")
        thunderbird_fx_charge_loop.entity:AddFollower()
        thunderbird_fx_charge_loop.Follower:FollowSymbol(inst.GUID)

        weapon:PushEvent("lightningstrike")
        inst:PushEvent("lightningdamageavoided", weapon:HasTag("lightningcutter"))
    else
        if inst.components.health ~= nil and not (inst.components.health:IsDead() or inst.components.health:IsInvincible()) then
            if not inst.components.inventory:IsInsulated() then
                local mult = TUNING.ELECTRIC_WET_DAMAGE_MULT * inst.components.moisture:GetMoisturePercent()
                local damage = TUNING.LIGHTNING_DAMAGE + mult * TUNING.LIGHTNING_DAMAGE

                inst.components.health:DoDelta(-damage, false, "lightning")
                if not inst.sg:HasStateTag("dead") then
                    inst.sg:GoToState("electrocute")
                end
            else
                inst:PushEvent("lightningdamageavoided")
            end
        end
    end
end

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

local function CustomIdleAnimFn(inst)
    if enable_idle_anim == "Random" then
        return Idle_Anim[math.random(1, #Idle_Anim)]
    elseif enable_idle_anim == "Default" then
        local build = inst.AnimState:GetBuild()
        local idle_anim = Idle_Anim[build]

        if build == "manutsawee" then
            local item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            return item ~= nil and item.prefab == "bernie_inactive" and "idle_willow" or "idle_wilson"
        else
            return idle_anim ~= nil and idle_anim or nil
        end
    end
end

local function CustomIdleStateFn(inst)
    if enable_idle_anim == "Random" then
        return Funny_Idle_Anim[math.random(1, #Funny_Idle_Anim)]
    elseif enable_idle_anim == "Default" then
        local build = inst.AnimState:GetBuild()
        local funny_idle_anim = Funny_Idle_Anim[build]
        return funny_idle_anim ~= nil and funny_idle_anim or nil
    end
end

local function SetUpCustomIdle(inst)
    inst.customidleanim = CustomIdleAnimFn
    inst.customidlestate = CustomIdleStateFn
end

local function RegisterEventListeners(inst)
    inst:ListenForEvent("death", OnDeath)
    inst:ListenForEvent("killed", OnKilled)
    inst:ListenForEvent("mounted", SkillRemove)
    inst:ListenForEvent("unequip", OnUnEquip)
    inst:ListenForEvent("equip", OnEquip)
    inst:ListenForEvent("dropitem", OnDroped)
    inst:ListenForEvent("itemlose", OnDroped)
end

local function SetInstanceFunctions(inst)
    inst.SkillRemove = SkillRemove
    inst.PutGlasses = PutGlasses
    inst.OnChangeHair = OnChangeHair
    inst.OnGrowShortHair = OnGrowShortHair
    inst.OnGrowMediumHair = OnGrowMediumHair
    inst.OnGrowLongHair = OnGrowLongHair
    inst.OnLoad = OnLoad
    inst.OnSave = OnSave
    inst.SwitchControlled = SwitchControlled
end

local function SetInstanceValue(inst)
    inst.soundsname = "wortox"

    inst.glasses_status = false
    inst.hair_long = 1
    inst.hair_type = 1
    inst._hitrange = inst.components.combat.hitrange

    inst.skeleton_prefab = nil

    inst.HAIR_BITS = HAIR_BITS
    inst.HAIR_TYPES = HAIR_TYPES
    inst.Funny_Idle_Anim = Funny_Idle_Anim
    inst.glasses_map = glasses_map
end

local master_postinit = function(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

    inst.AnimState:SetScale(0.88, 0.9, 1)

    inst:AddComponent("skillreleaser")
    inst.components.skillreleaser:OnPostInit()
    inst.components.skillreleaser:AddSkills(Skill_Data)

    inst:AddComponent("kenjutsuka")
    inst.components.kenjutsuka:SetOnUpgradeFn(OnUpgrades)
    inst.components.kenjutsuka:SetOnMindPowerRegenFn(OnMindPowerRegen)

    inst:AddComponent("houndedtarget")
    inst.components.houndedtarget.target_weight_mult:SetModifier(inst, TUNING.WES_HOUND_TARGET_MULT, "misfortune")
    inst.components.houndedtarget.hound_thief = true

    inst.components.foodaffinity:AddPrefabAffinity("baconeggs", TUNING.AFFINITY_15_CALORIES_HUGE)
    inst.components.foodaffinity:AddPrefabAffinity("unagi", TUNING.AFFINITY_15_CALORIES_TINY)
    inst.components.foodaffinity:AddPrefabAffinity("kelp_cooked", 1)
    inst.components.foodaffinity:AddPrefabAffinity("justeggs", 1)
    -- The original author is Thai
    inst.components.foodaffinity:AddPrefabAffinity("durian", 1)
    inst.components.foodaffinity:AddPrefabAffinity("durian_cooked", 1)
    if IA_ENABLED then
        inst.components.foodaffinity:AddPrefabAffinity("californiaroll", TUNING.AFFINITY_15_CALORIES_TINY)
        inst.components.foodaffinity:AddPrefabAffinity("caviar", TUNING.AFFINITY_15_CALORIES_TINY)
    end

    if PL_ENABLED then
        inst.components.foodaffinity:AddPrefabAffinity("caviar", TUNING.AFFINITY_15_CALORIES_TINY)
    end

    if UM_ENABLED then
        inst.components.foodaffinity:AddPrefabAffinity("liceloaf", TUNING.AFFINITY_15_CALORIES_TINY)
        inst.components.foodaffinity:AddPrefabAffinity("blueberrypancakes", TUNING.AFFINITY_15_CALORIES_TINY)
    end

    inst:AddComponent("beard")
    inst.components.beard.insulation_factor = 1
    inst.components.beard.onreset = OnResetHair
    inst.components.beard.prize = "beardhair"
    inst.components.beard.is_skinnable = false
    inst.components.beard:AddCallback(BEARD_DAYS[1], OnGrowShortHair)
    inst.components.beard:AddCallback(BEARD_DAYS[2], OnGrowMediumHair)
    inst.components.beard:AddCallback(BEARD_DAYS[3], OnGrowLongHair)

    -- Stats
    inst.components.health:SetMaxHealth(TUNING.MANUTSAWEE.HEALTH)
    inst.components.hunger:SetMax(TUNING.MANUTSAWEE.HUNGER)
    inst.components.sanity:SetMax(TUNING.MANUTSAWEE.SANITY)
    inst.components.hunger:SetRate(TUNING.WILSON_HUNGER_RATE * .5)

    -- Damage multiplier (optional)
    inst.components.combat.damagemultiplier = 1
    -- grogginess rate (optional)
    inst.components.grogginess.decayrate = TUNING.WES_GROGGINESS_DECAY_RATE
    -- clothing is less effective
    inst.components.temperature.inherentinsulation = -TUNING.INSULATION_TINY
    inst.components.temperature.inherentsummerinsulation = -TUNING.INSULATION_TINY

    if inst.components.eater ~= nil then
        inst.components.eater:SetCanEatMfruit()
        inst.components.eater:SetOnEatFn(OnEat)

        inst.components.eater:SetRejectEatingTag("terriblefood")
    end

    if inst.components.playerlightningtarget ~= nil then
        inst.components.playerlightningtarget:SetOnStrikeFn(OnStrike)
    end

    -- Slow Worker
    inst.components.workmultiplier:AddMultiplier(ACTIONS.CHOP,   TUNING.WES_WORKEFFECTIVENESS_MODIFIER, inst)
    inst.components.workmultiplier:AddMultiplier(ACTIONS.MINE,   TUNING.WES_WORKEFFECTIVENESS_MODIFIER, inst)
    inst.components.workmultiplier:AddMultiplier(ACTIONS.HAMMER, TUNING.WES_WORKEFFECTIVENESS_MODIFIER, inst)

    inst:AddComponent("efficientuser")
    inst.components.efficientuser:AddMultiplier(ACTIONS.CHOP,   TUNING.WES_WORKEFFECTIVENESS_MODIFIER, inst)
    inst.components.efficientuser:AddMultiplier(ACTIONS.MINE,   TUNING.WES_WORKEFFECTIVENESS_MODIFIER, inst)
    inst.components.efficientuser:AddMultiplier(ACTIONS.HAMMER, TUNING.WES_WORKEFFECTIVENESS_MODIFIER, inst)
    inst.components.efficientuser:AddMultiplier(ACTIONS.ATTACK, TUNING.WES_WORKEFFECTIVENESS_MODIFIER, inst)

    if enable_idle_anim then
        SetUpCustomIdle(inst)
    end

    SetInstanceFunctions(inst)
    SetInstanceValue(inst)
    RegisterEventListeners(inst)
end

return MakePlayerCharacter("manutsawee", prefabs, assets, common_postinit, master_postinit, start_inv)
