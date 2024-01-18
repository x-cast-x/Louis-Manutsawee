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

    Asset("ANIM", "anim/player_idles_wanda.zip"),
}

local MANUTSAWEE_DAMAGE = 1
local MANUTSAWEE_CRIDMG = 0.1
local hitcount = 0
local criticalrate = 5

local start_inv = {}
if M_CONFIG.START_ITEM > 0 then
    TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.MANUTSAWEE = {KATANA[M_CONFIG.START_ITEM]}
else
    TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.MANUTSAWEE = {}
end

for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.MANUTSAWEE
end
local prefabs = FlattenTree(start_inv, true)

local function _SkillRemove(inst)
    SkillRemove(inst)

	inst.mafterskillndm = nil
	inst.inspskill = nil
	inst.components.combat:SetRange(inst._range)
	inst.components.combat:EnableAreaDamage(false)
	inst.AnimState:SetDeltaTimeMultiplier(1)
end

local function MindRegenFn(inst)
	inst.mindpower = inst.mindpower + 1
	local mindregenfx = SpawnPrefab("battlesong_instant_electric_fx")
	mindregenfx.Transform:SetScale(.7, .7, .7)
	mindregenfx.Transform:SetPosition(inst:GetPosition():Get())
	mindregenfx.entity:AddFollower()
    mindregenfx.Follower:FollowSymbol(inst.GUID, "swap_body", 0, 0, 0)
	if inst.mindpower >= 3 then
        inst.components.talker:Say("󰀈: "..inst.mindpower.."\n", 2, true)
    end
end

local function mindregen(inst)
	if inst.mindpower < inst.max_mindpower/2 then
		 MindRegenFn(inst)
	end
	inst:DoTaskInTime(M_CONFIG.MINDREGEN_RATE, mindregen)
end

local HAIR_BITS = { "_cut", "_short", "_medium",  "_long" }
local HAIR_TYPES = { "", "_yoto", "_ronin", "_pony", "_twin", "_htwin","_ball"}
local function OnChangeHair(inst, skinname)
    if inst.hairlong == 1 and inst.hairtype > 1 then
        inst.hairtype = 1
    end

    if skinname == nil then
        inst.AnimState:OverrideSymbol("hairpigtails", "hair"..HAIR_BITS[inst.hairlong]..HAIR_TYPES[inst.hairtype], "hairpigtails")
        inst.AnimState:OverrideSymbol("hair", "hair"..HAIR_BITS[inst.hairlong]..HAIR_TYPES[inst.hairtype], "hair")
        inst.AnimState:OverrideSymbol("hair_hat", "hair"..HAIR_BITS[inst.hairlong]..HAIR_TYPES[inst.hairtype], "hair_hat")
        inst.AnimState:OverrideSymbol("headbase", "hair"..HAIR_BITS[inst.hairlong]..HAIR_TYPES[inst.hairtype], "headbase")
        inst.AnimState:OverrideSymbol("headbase_hat", "hair"..HAIR_BITS[inst.hairlong]..HAIR_TYPES[inst.hairtype], "headbase_hat")
    else
        inst.AnimState:OverrideSkinSymbol("hairpigtails", skinname, "hairpigtails" )
        inst.AnimState:OverrideSkinSymbol("hair", skinname, "hair" )
        inst.AnimState:OverrideSkinSymbol("hair_hat", skinname, "hair_hat" )
        inst.AnimState:OverrideSkinSymbol("headbase", skinname, "headbase" )
        inst.AnimState:OverrideSkinSymbol("headbase_hat", skinname, "headbase_hat" )
    end

    if inst.hairtype <= 2 then
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

local function kenjutsuupgrades(inst)
	if inst.kenjutsulevel >= 2 and not inst:HasTag("kenjutsu") then
        inst:AddTag("kenjutsu")
    end

    if inst.kenjutsulevel >= 4 and inst.startregen == nil then
        inst.startregen = inst:DoTaskInTime(M_CONFIG.MINDREGEN_RATE, mindregen)
    end

    if inst.kenjutsulevel >= 5 and not inst:HasTag("manutsaweecraft2") then
        inst:AddTag("manutsaweecraft2")
    end

	if inst.kenjutsulevel >= 1 then
		inst.components.sanity.neg_aura_mult = 1 - ((inst.kenjutsulevel / 2) / 10)
		inst.kenjutsumaxexp = 500 * inst.kenjutsulevel

		local hunger_percent = inst.components.hunger:GetPercent()
		local health_percent = inst.components.health:GetPercent()
		local sanity_percent = inst.components.sanity:GetPercent()

		if M_CONFIG.HEALTH_MAX > 0 then
            inst.components.health.maxhealth = math.ceil(TUNING.MANUTSAWEE.HEALTH + inst.kenjutsulevel * M_CONFIG.HEALTH_MAX)
            inst.components.health:SetPercent(health_percent)
		end
		if M_CONFIG.HUNGER_MAX > 0 then
            inst.components.hunger.max = math.ceil(TUNING.MANUTSAWEE.HUNGER + inst.kenjutsulevel * M_CONFIG.HUNGER_MAX)
            inst.components.hunger:SetPercent(hunger_percent)
		end
		if M_CONFIG.SANITY_MAX > 0 then
            inst.components.sanity.max = math.ceil(TUNING.MANUTSAWEE.SANITY + inst.kenjutsulevel * M_CONFIG.SANITY_MAX)
            inst.components.sanity:SetPercent(sanity_percent)
		end
	end

	if inst.kenjutsulevel >= 5 then
		inst.components.sanity:AddSanityAuraImmunity("ghost")
		inst.components.workmultiplier:AddMultiplier(ACTIONS.CHOP,   1, inst)
		inst.components.workmultiplier:AddMultiplier(ACTIONS.MINE,  1, inst)
		inst.components.workmultiplier:AddMultiplier(ACTIONS.HAMMER, 1, inst)
    end

	if inst.kenjutsulevel >= 6 then
		inst.components.temperature.inherentinsulation = TUNING.INSULATION_TINY /2
		inst.components.temperature.inherentsummerinsulation = TUNING.INSULATION_TINY /2
		inst.components.sanity:SetPlayerGhostImmunity(true)
    end

    if inst.kenjutsulevel >= 10 then
        inst.kenjutsuexp = 0
    end

	MANUTSAWEE_CRIDMG = 0.1 + ((inst.kenjutsulevel / 2) / 10)

	inst.max_mindpower = M_CONFIG.MIND_MAX + inst.kenjutsulevel

	local fx = SpawnPrefab("fx_book_light_upgraded")
    fx.Transform:SetScale(.9, 2.5, 1)
    fx.entity:AddFollower()
    fx.Follower:FollowSymbol(inst.GUID, "swap_body", 0, 0, 0)
end

local function KenjutsuLevelUp(inst)
	inst.kenjutsulevel = inst.kenjutsulevel + 1
	kenjutsuupgrades(inst)
end

local smallScale = 1
local medScale = 2
local largeScale = 4
local function OnKilled(inst, data)
	local target = data.victim
	local scale = (target:HasTag("smallcreature") and smallScale) or (target:HasTag("largecreature") and largeScale) or medScale

    if target ~= nil and scale ~= nil then
		if not ((target:HasTag("prey")or target:HasTag("bird")or target:HasTag("insect")) and not target:HasTag("hostile")) and inst.components.sanity:GetPercent() <= .8  then
            inst.components.sanity:DoDelta(scale)
        end
	end
end

local function OnAttack(inst, data)
    if inst.components.rider:IsRiding() then
        return
    end
    local target = data.target
    local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    local tx, ty, tz = target.Transform:GetWorldPosition()

    if equip ~= nil and not equip:HasTag("projectile") and not equip:HasTag("rangedweapon") then
        if equip:HasTag("katanaskill") and not inst.components.timer:TimerExists("HitCD") and
            not inst.sg:HasStateTag("skilling") then -- GainKenExp
            if inst.kenjutsulevel < 10 then
                inst.kenjutsuexp = inst.kenjutsuexp + (1 * M_CONFIG.KEXPMTP)
            end
            inst.components.timer:StartTimer("HitCD", .5)
        end

        if inst.kenjutsuexp >= inst.kenjutsumaxexp then
            inst.kenjutsuexp = inst.kenjutsuexp - inst.kenjutsumaxexp
            KenjutsuLevelUp(inst)
        end

        if not ((target:HasTag("prey") or target:HasTag("bird") or target:HasTag("insect") or target:HasTag("wall")) and
            not target:HasTag("hostile")) then
            if math.random(1, 100) <= criticalrate + inst.kenjutsulevel and
                not inst.components.timer:TimerExists("CriCD") and not inst.sg:HasStateTag("skilling") then
                inst.components.timer:StartTimer("CriCD", 15 - (inst.kenjutsulevel / 2)) -- critical
                local hitfx = SpawnPrefab("slingshotammo_hitfx_rock")
                if hitfx then
                    hitfx.Transform:SetScale(.8, .8, .8)
                    hitfx.Transform:SetPosition(tx, ty, tz)
                end
                inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
                inst.components.combat.damagemultiplier = (MANUTSAWEE_DAMAGE + MANUTSAWEE_CRIDMG)
                inst:DoTaskInTime(.1, function(inst)
                    inst.components.combat.damagemultiplier = MANUTSAWEE_DAMAGE
                end)
            end
        end

        if not ((target:HasTag("prey") or target:HasTag("bird") or target:HasTag("insect") or target:HasTag("wall")) and
            not target:HasTag("hostile")) then
            if not inst.components.timer:TimerExists("HeartCD") and not inst.sg:HasStateTag("skilling") and
                not inst.inspskill then
                inst.components.timer:StartTimer("HeartCD", .3) -- mind gain
                hitcount = hitcount + 1
                if hitcount >= M_CONFIG.MINDREGEN_COUNT and inst.kenjutsulevel >= 1 then
                    if inst.mindpower < inst.max_mindpower then
                        MindRegenFn(inst)
                    else
                        inst.components.sanity:DoDelta(1)
                    end
                    hitcount = 0
                end
            end
        end
    end
end

local function OnDeath(inst)
	_SkillRemove(inst)
end

local function OnSave(inst, data)
	data.kenjutsulevel = inst.kenjutsulevel
	data.kenjutsuexp = inst.kenjutsuexp
	data.mindpower = inst.mindpower
	data._mlouis_health = inst.components.health.currenthealth
    data._mlouis_sanity = inst.components.sanity.current
    data._mlouis_hunger = inst.components.hunger.current
	data.hairlong = inst.hairlong
	data.hairtype = inst.hairtype
    data.glassesstatus = inst.glassesstatus
end

local function OnLoad(inst, data)
	if data ~= nil then
		if data.kenjutsulevel ~= nil then
            inst.kenjutsulevel = data.kenjutsulevel
        end

        if data.kenjutsuexp  ~= nil then
            inst.kenjutsuexp = data.kenjutsuexp
        end

		if data.mindpower  ~= nil then
            inst.mindpower = data.mindpower
        end

		kenjutsuupgrades(inst)

		if inst.kenjutsulevel > 0 and data._mlouis_health ~= nil and data._mlouis_sanity ~= nil and data._mlouis_hunger ~= nil then
			inst.components.health:SetCurrentHealth(data._mlouis_health)
			inst.components.sanity.current = data._mlouis_sanity
			inst.components.hunger.current = data._mlouis_hunger
		end

		if data.hairlong ~= nil then
            inst.hairlong = data.hairlong
        end

        if data.hairtype ~= nil then
            inst.hairtype = data.hairtype
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

local function CooldownSkillFx(inst, fxnum)
    local fxlist = {
        "ghostlyelixir_retaliation_dripfx",
        "ghostlyelixir_shield_dripfx",
        "ghostlyelixir_speed_dripfx",
        "battlesong_instant_panic_fx",
        "monkey_deform_pre_fx",
        "fx_book_birds",
    }
    local fx = SpawnPrefab(fxlist[fxnum])
    fx.Transform:SetScale(.9, .9, .9)
    fx.entity:AddFollower()
    fx.Follower:FollowSymbol(inst.GUID, "swap_body", 0, 0, 0)
end

local function OnTimerDone(inst, data)
	if data.name ~= nil then
        local name = data.name
        local fxnum

        local fx_data = {
            ["skill1cd"] = 1,
            ["skill2cd"] = 2,
            ["skill3cd"] = 3,
            ["skillcountercd"] = 4,
            ["skillT2cd"] = 5,
            ["skillT3cd"] = 6,
        }

        for i, v in ipairs(fx_data) do
            if name == i then
                fxnum = v
                CooldownSkillFx(inst, fxnum)
                return
                break
            end
        end
	end
end

local function OnChangeChar(inst)
	_SkillRemove(inst)
    if inst.kenjutsulevel > 0 then
        local x, y, z = inst.Transform:GetWorldPosition()
        for i = 1, inst.kenjutsulevel do
            local fruit = SpawnPrefab("mfruit")
            if fruit ~= nil then
                if fruit.Physics ~= nil then
                    local speed = 2 + math.random()
                    local angle = math.random() * 2 * PI
                    fruit.Physics:Teleport(x, y + 1, z)
                    fruit.Physics:SetVel(speed * math.cos(angle), speed * 3, speed * math.sin(angle))
                else
                    fruit.Transform:SetPosition(x, y, z)
                end

                if fruit.components.propagator ~= nil then
                    fruit.components.propagator:Delay(5)
                end
            end
        end
        inst.kenjutsulevel = 0
    end
end

local function OnEat(inst, food)
    if food ~= nil and food.components.edible ~= nil then
        if food.prefab == "mfruit" and inst.kenjutsulevel < 10 then
            KenjutsuLevelUp(inst)
        end
    end
end

local function OnMounted(inst)
    _SkillRemove(inst)
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

    if M_CONFIG.IDLE_ANIM then
        inst.AnimState:AddOverrideBuild("player_idles_wanda")
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
	inst.hairlong = 2
	inst.components.beard.bits = BEARD_BITS[1]
    OnChangeHair(inst, skinname)
end

local function OnGrowMediumHair(inst, skinname)
	inst.hairlong = 3
	inst.components.beard.bits = BEARD_BITS[2]
	OnChangeHair(inst, skinname)
end

local function OnGrowLongHair(inst, skinname)
	inst.hairlong = 4
	inst.components.beard.bits = BEARD_BITS[3]
	OnChangeHair(inst, skinname)
end

local function OnResetHair(inst, skinname)
	if inst.hairlong == 4 then
		inst.components.beard.daysgrowth = BEARD_DAYS[2]
		OnGrowMediumHair(inst, skinname)
	elseif inst.hairlong == 3 then
		inst.components.beard.daysgrowth = BEARD_DAYS[1]
		OnGrowShortHair(inst, skinname)
	else
        inst.hairlong = 1
        inst.hairtype = 1
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
    if data.item ~= nil and (data.item.prefab == "onemanband" or data.item.prefab == "armorsnurtleshell") then
        if inst:HasTag("notshowscabbard") then
            inst:RemoveTag("notshowscabbard")
        end
    end

    if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) == nil then
        _SkillRemove(inst)
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

local function RegisterEventListeners(inst)
    inst:ListenForEvent("death", OnDeath)
    inst:ListenForEvent("ms_playerreroll", OnChangeChar)
    inst:ListenForEvent("timerdone", OnTimerDone)
    inst:ListenForEvent("onattackother", OnAttack)
    inst:ListenForEvent("killed", OnKilled)
    inst:ListenForEvent("mounted", OnMounted)
    inst:ListenForEvent("unequip", OnUnEquip)
    inst:ListenForEvent("equip", OnEquip)
    inst:ListenForEvent("dropitem", OnDroped)
    inst:ListenForEvent("itemlose", OnDroped)
end

local function DoPostInit(inst)
    for i, v in ipairs(Skills) do
        inst.components.skillreleaser:AddSkill(v)
    end

    RegisterEventListeners(inst)
end

local master_postinit = function(inst)
	inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

    if M_CONFIG.IDLE_ANIM then
        inst.customidleanim = "idle_wanda"
    end

	--custom start level
	if M_CONFIG.IS_MASTER then
        inst:DoTaskInTime(2, function()
            if inst.kenjutsulevel < M_CONFIG.MASTER_VALUE then
                inst.kenjutsulevel = M_CONFIG.MASTER_VALUE
                kenjutsuupgrades(inst)
            end
        end)
    end

	--small character
    inst.AnimState:SetScale(0.88, 0.90, 1)

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
    inst.components.combat.damagemultiplier = MANUTSAWEE_DAMAGE
	-- grogginess rate (optional)
	inst.components.grogginess.decayrate = TUNING.WES_GROGGINESS_DECAY_RATE
	-- clothing is less effective
	inst.components.temperature.inherentinsulation = -TUNING.INSULATION_TINY
	inst.components.temperature.inherentsummerinsulation = -TUNING.INSULATION_TINY

    if inst.components.eater ~= nil then
        inst.components.eater:SetCanEatMfruit()
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

	inst.kenjutsulevel = 0
	inst.kenjutsuexp = 0
	inst.kenjutsumaxexp = 250

	inst.mindpower = 0
	inst.max_mindpower = M_CONFIG.MIND_MAX

	inst.glassesstatus = false
	inst.hairlong = 1
	inst.hairtype = 1
	inst._range = inst.components.combat.hitrange

    inst.PutGlasses = PutGlasses
    inst.OnChangeHair = OnChangeHair
	inst.OnLoad = OnLoad
	inst.OnSave = OnSave

    DoPostInit(inst)
end

return MakePlayerCharacter("manutsawee", prefabs, assets, common_postinit, master_postinit, start_inv)
