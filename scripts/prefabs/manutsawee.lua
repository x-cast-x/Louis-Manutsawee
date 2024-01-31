local MakePlayerCharacter = require "prefabs/player_common"
local Skills = require "skillfns"

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


    Asset("ANIM", "anim/wurt_peruse.zip"),
    Asset("ANIM", "anim/wurt_mount_peruse.zip"),
}

local start_inv = {}

for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.MANUTSAWEE
end
local prefabs = FlattenTree(start_inv, true)

local function SkillRemove(inst)
    inst.components.skillreleaser:SkillRemove()

	inst.mafterskillndm = nil
	inst.inspskill = nil
	inst.components.combat:SetRange(inst._range)
	inst.components.combat:EnableAreaDamage(false)
	inst.AnimState:SetDeltaTimeMultiplier(1)
end

local function OnMindPowerRegen(inst, self)
	self.mindpower = self.mindpower + 1
	local mindregenfx = SpawnPrefab("battlesong_instant_electric_fx")
	mindregenfx.Transform:SetScale(.7, .7, .7)
	mindregenfx.Transform:SetPosition(inst:GetPosition():Get())
	mindregenfx.entity:AddFollower()
    mindregenfx.Follower:FollowSymbol(inst.GUID, "swap_body", 0, 0, 0)
	if self.mindpower >= 3 then
        inst.components.talker:Say("󰀈: ".. self.mindpower .."\n", 2, true)
    end
end

local HAIR_BITS = {"cut", "short", "medium", "long"}
local HAIR_TYPES = {"", "yoto", "ronin", "pony", "twin", "htwin", "ball"}
local function OnChangeHair(inst, skinname)
    if inst.hair_bit == "cut" and not (inst.hair_type == HAIR_TYPES[""]) then
        inst.hair_type = HAIR_TYPES[""]
    end

    if skinname == nil then
        local override_build = "hair_" .. HAIR_BITS[inst.hair_bit] .. "_" .. HAIR_TYPES[inst.hair_type]
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

local function PutGlasses(inst, skinname)
    if skinname == nil then
        inst.AnimState:OverrideSymbol("face", "eyeglasses", "face")
    else
        inst.AnimState:OverrideSkinSymbol("face", skinname, "face" )
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

    if kenjutsulevel >= 5 and not inst:HasTag("manutsaweecraft2") then
        inst:AddTag("manutsaweecraft2")
        inst.components.sanity:AddSanityAuraImmunity("ghost")
		inst.components.workmultiplier:AddMultiplier(ACTIONS.CHOP,   1, inst)
		inst.components.workmultiplier:AddMultiplier(ACTIONS.MINE,  1, inst)
		inst.components.workmultiplier:AddMultiplier(ACTIONS.HAMMER, 1, inst)
    end

	if kenjutsulevel >= 6 then
		inst.components.temperature.inherentinsulation = TUNING.INSULATION_TINY /2
		inst.components.temperature.inherentsummerinsulation = TUNING.INSULATION_TINY /2
		inst.components.sanity:SetPlayerGhostImmunity(true)
    end

    if kenjutsulevel >= 10 then
        inst:AddTag("kenjutsu_master")
        kenjutsuexp = 0
    end

	inst.components.kenjutsuka.max_mindpower = M_CONFIG.MIND_MAX + kenjutsulevel

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
	data.hair_bit = inst.hair_bit
	data.hair_type = inst.hair_type
    data.glassesstatus = inst.glassesstatus
end

local function OnLoad(inst, data)
	if data ~= nil then
		if inst.components.kenjutsuka.kenjutsulevel > 0 and data._louis_health ~= nil and data._mlouis_sanity ~= nil and data._louis_hunger ~= nil then
			inst.components.health:SetCurrentHealth(data._louis_health)
			inst.components.sanity.current = data._louis_sanity
			inst.components.hunger.current = data._louis_hunger
		end

		if data.hair_bit ~= nil then
            inst.hair_bit = data.hair_bit
        end

        if data.hair_type ~= nil then
            inst.hair_type = data.hair_type
        end

        if data.glassesstatus ~= nil then
            inst.glassesstatus = data.glassesstatus
            if inst.glassesstatus then
                PutGlasses(inst)
            else
                inst.AnimState:ClearOverrideSymbol("face")
            end
        end

        OnChangeHair(inst)
	end
end

local function OnEat(inst, food)
    if food ~= nil and food.components.edible ~= nil then
        if food.prefab == "mfruit" and inst.kenjutsulevel < 10 then
            inst.components.kenjutsuka:KenjutsuLevelUp(inst)
        end
    end
end

local function GetPointSpecialActions(inst, pos, useitem, right)
	local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    local rider = inst.replica.rider
    if equip ~= nil and not (equip:HasTag("Iai") or equip:HasTag("katana_quickdraw")) and equip:HasTag("katanaskill") and inst:HasTag("kenjutsu") and right and GetTime() - inst.last_dodge_time > inst.dodge_cooldown then
		if rider == nil or not rider:IsRiding() then
			return {ACTIONS.MDODGE}
		end
    elseif inst:HasTag("kenjutsu") and right and GetTime() - inst.last_dodge_time > inst.dodge_cooldown then
		if rider == nil or not rider:IsRiding() then
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

    inst.AnimState:AddOverrideBuild("wurt_peruse")

    if M_CONFIG.IDLE_ANIM then
        inst.AnimState:AddOverrideBuild("player_idles_wes")
        inst.AnimState:AddOverrideBuild("player_idles_wendy")
        inst.AnimState:AddOverrideBuild("player_idles_wanda")
        inst.AnimState:AddOverrideBuild("player_idles_waxwell")
    end

	inst:AddTag("bearded")
	inst:AddTag("manutsaweecraft")
	inst:AddTag("stronggrip")

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
	inst.components.keyhandler:AddActionListener("manutsawee", M_CONFIG.KEYLEVELCHECK, "levelcheck")
	inst.components.keyhandler:AddActionListener("manutsawee", M_CONFIG.PUT_GLASSES_KEY, "glasses")
	inst.components.keyhandler:AddActionListener("manutsawee", M_CONFIG.CHANGE_HAIRS_KEY, "Hairs")

	if M_CONFIG.ENABLE_SKILL then
        inst.components.keyhandler:AddActionListener("manutsawee", M_CONFIG.SKILL1_KEY, "skill1")
        inst.components.keyhandler:AddActionListener("manutsawee", M_CONFIG.SKILL2_KEY, "skill2")
        inst.components.keyhandler:AddActionListener("manutsawee", M_CONFIG.SKILL3_KEY, "skill3")
        inst.components.keyhandler:AddActionListener("manutsawee", M_CONFIG.SKILL_COUNTER_ATK_KEY, "skillcounterattack")
        inst.components.keyhandler:AddActionListener("manutsawee", M_CONFIG.QUICK_SHEATH_KEY, "quicksheath")
        inst.components.keyhandler:AddActionListener("manutsawee", M_CONFIG.SKILL_CANCEL_KEY, "skillcancel")
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
	inst.hair_bit = "short"
	inst.components.beard.bits = BEARD_BITS[1]
    OnChangeHair(inst, skinname)
end

local function OnGrowMediumHair(inst, skinname)
	inst.hair_bit = "medium"
	inst.components.beard.bits = BEARD_BITS[2]
	OnChangeHair(inst, skinname)
end

local function OnGrowLongHair(inst, skinname)
	inst.hair_bit = "long"
	inst.components.beard.bits = BEARD_BITS[3]
	OnChangeHair(inst, skinname)
end

local function OnResetHair(inst, skinname)
	if inst.hair_bit == "long" then
		inst.components.beard.daysgrowth = BEARD_DAYS[2]
		OnGrowMediumHair(inst, skinname)
	elseif inst.hair_bit == "medium" then
		inst.components.beard.daysgrowth = BEARD_DAYS[1]
		OnGrowShortHair(inst, skinname)
	else
        inst.hair_bit = "cut"
        inst.hair_type = ""
        inst.AnimState:ClearOverrideSymbol("hairpigtails")
        inst.AnimState:ClearOverrideSymbol("hair")
        inst.AnimState:ClearOverrideSymbol("hair_hat")
        inst.AnimState:ClearOverrideSymbol("headbase")
        inst.AnimState:ClearOverrideSymbol("headbase_hat")
	end
end

local function OnEquip(inst, data)
    if data.item ~= nil and (data.item.prefab == "onemanband" or data.item.prefab == "armorsnurtleshell") then
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

local Funny_Idle_Anim = {
    waxwell = "idle3_waxwell",
    wes = "wes_funnyidle",
    wortox = "idle_wortox",
    wilson = "idle_wilson",
    wendy = "idle_wendy",
    wanda = "idle_wanda",
    wathgrithr = "idle_wathgrithr",
    winona = "idle_winona",
    walter = "idle_walter",
}

local skin_idle_anim = {
    ["manutsawee_yukatalong_purple"] = "wendy",
    ["manutsawee_yukatalong"] = "wendy",
    ["manutsawee_yukata"] = "wendy",
    ["manutsawee_shinsengumi"] = "wathgrithr",
    ["manutsawee_fuka"] = "wathgrithr",
    ["manutsawee_sailor"] = "wortox",
    ["manutsawee_jinbei"] = "wortox",
    ["manutsawee_maid"] = "wanda",
    ["manutsawee_qipao"] = "wes",
    ["manutsawee_taohuu"] = "winona",
    ["manutsawee_miko"] = "waxwell",
}

local function CustomIdleAnimFn(inst)
    local skin_build = inst:GetSkinBuild()
    local skin_name = inst:GetSkinName()

    if skin_build ~= nil then
        return Funny_Idle_Anim[skin_idle_anim[skin_name]]
    else
        return Funny_Idle_Anim["wilson"]
    end
end

local function SetUpCustomIdle(inst)
    inst.customidleanim = CustomIdleAnimFn

    for k, _ in pairs(Funny_Idle_Anim) do
        table.insert(assets, Asset("ANIM", "anim/player_idles_" .. k .. ".zip"))
    end
end

local function RegisterEventListeners(inst)
    inst:ListenForEvent("death", SkillRemove)
    inst:ListenForEvent("killed", OnKilled)
    inst:ListenForEvent("mounted", SkillRemove)
    inst:ListenForEvent("unequip", OnUnEquip)
    inst:ListenForEvent("equip", OnEquip)
    inst:ListenForEvent("dropitem", OnDroped)
    inst:ListenForEvent("itemlose", OnDroped)
end

local function DoPostInit(inst)
    for k, v in ipairs(Skills) do
        inst.components.skillreleaser:AddSkill(string.lower(k), v)
    end

    if M_CONFIG.RANDOM_IDLE_ANIMATION then
        SetUpCustomIdle(inst)
    end

    RegisterEventListeners(inst)
end

local master_postinit = function(inst)
	inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

	--small character
    inst.AnimState:SetScale(0.88, 0.9, 1)

    inst:AddComponent("kenjutsuka")
    inst.components.kenjutsuka:SetOnUpgradeFn(OnUpgrades)
    inst.components.kenjutsuka:SetOnMindPowerRegenFn(OnMindPowerRegen)

    inst:AddComponent("skillreleaser")
    inst.components.skillreleaser:OnPostInit()

	inst:AddComponent("houndedtarget")
    inst.components.houndedtarget.target_weight_mult:SetModifier(inst, TUNING.WES_HOUND_TARGET_MULT, "misfortune")
	inst.components.houndedtarget.hound_thief = true

	inst.components.foodaffinity:AddPrefabAffinity("baconeggs", TUNING.AFFINITY_15_CALORIES_HUGE)
	inst.components.foodaffinity:AddPrefabAffinity("unagi", TUNING.AFFINITY_15_CALORIES_TINY)
	inst.components.foodaffinity:AddPrefabAffinity("kelp_cooked", 1)
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
    inst.components.hunger:SetRate(TUNING.WILSON_HUNGER_RATE * 1.5)

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

    inst.soundsname = "wortox"

	inst.glassesstatus = false
	inst.hair_bit = ""
	inst.hair_type = "cut"
	inst._range = inst.components.combat.hitrange

    inst.SkillRemove = SkillRemove
    inst.PutGlasses = PutGlasses
    inst.OnChangeHair = OnChangeHair
	inst.OnLoad = OnLoad
	inst.OnSave = OnSave

    DoPostInit(inst)
end

return MakePlayerCharacter("manutsawee", prefabs, assets, common_postinit, master_postinit, start_inv)
