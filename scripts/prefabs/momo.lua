local LIGHT_INTENSITY_MAX = .94

local function CreateLight()
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddFollower()

    inst.Light:SetFalloff(.9)
    inst.Light:SetIntensity(LIGHT_INTENSITY_MAX)
    inst.Light:SetRadius(TUNING.WINONA_SPOTLIGHT_RADIUS)
    inst.Light:SetColour(255 / 255, 248 / 255, 198 / 255)
    inst.Light:Enable(true)

    return inst
end

local assets = {
    Asset("ANIM", "anim/player_basic.zip"),
    Asset("ANIM", "anim/player_actions.zip"),
    Asset("ANIM", "anim/player_attacks.zip"),
    Asset("ANIM", "anim/player_actions_item.zip"),
    Asset("ANIM", "anim/player_idles_wanda.zip"),
    Asset("ANIM", "anim/player_attack_prop.zip"),
    Asset("ANIM", "anim/player_parryblock.zip"),
    Asset("ANIM", "anim/player_actions_uniqueitem.zip"),
    Asset("ANIM", "anim/player_actions_useitem.zip"),
    Asset("ANIM", "anim/player_actions_item.zip"),
    Asset("ANIM", "anim/player_attack_leap.zip"),
    Asset("ANIM", "anim/wortox_portal.zip"),
    Asset("ANIM", "anim/player_lunge.zip"),
    Asset("ANIM", "anim/player_multithrust.zip"),
    Asset("ANIM", "anim/player_superjump.zip"),
    Asset("ANIM", "anim/player_pocketwatch_portal.zip"),
    Asset("ANIM", "anim/wanda_casting.zip"),
	Asset("ANIM", "anim/wendy_recall.zip"),

    Asset("ANIM", "anim/momo.zip"),
    Asset("ANIM", "anim/momo_maid.zip"),
    Asset("ANIM", "anim/momo_school.zip"),
    Asset("ANIM", "anim/momo_sailor.zip"),
    Asset("ANIM", "anim/momo_dark.zip"),
}

local prefabs = {
    "fx_book_light_upgraded",
    "mnaginata",
    "momo_hat",
    "battlesong_instant_taunt_fx",
    "mortalblade",
}

local momo_skins = {
    "momo",
	"momo_sailor",
	"momo_school",
	"momo_maid",
}

local brain = require("brain/momobrain")

local function IsPantsu(item)
    return item:HasTag("pantsu")
end

local function TheHoney(inst)
    -- Only save userid and use LookupPlayerInstByUserID to get data from networking.lua
    if inst.honey == nil and inst.honey_userid ~= nil then
        inst.honey = LookupPlayerInstByUserID(inst.honey_userid)
    end
    return inst.honey or nil
end

-- only accept pantsu and fruit from Louis, reject everything else
local function ShouldAcceptItem(inst, item, giver, count)
    local honey = inst:TheHoney()
    if honey ~= nil then
        return giver == honey and ((item:HasTag("mfruit")) or (inst:IsPantsu(item)))
    end
end

local function OnAccept(inst, giver, item)
    if item ~= nil then
        if (inst:IsPantsu(item)) or (inst.numberofbribes > 3) then
            inst:PushEvent("admitdefeated")
        end

        if item:HasTag("mfruit") then
            inst.numberofbribes = inst.numberofbribes + 1
        end
    end
end

local function OnRefuse(inst, giver, item)
    local honey = inst:TheHoney()
    if honey ~= nil and giver == honey then
        inst.components.talker:Say(STRINGS.MOMO.ONREFUSE.LIST[math.random(1, #STRINGS.MOMO.ONREFUSE.LIST)])
    else
        inst.components.talker:Say(STRINGS.MOMO.ONREFUSE.IRRELEVANT)
    end
end

local function Defeated(inst)
    local honey = inst:TheHoney()
    if honey ~= nil then
        honey.momo_light:Remove()
        inst.momo_light:Remove()
    end
end

local function ChargeEffects(inst, time)
    local x, y, z = inst.Transform:GetWorldPosition()
    for i = 0, 2 do
        inst:DoTaskInTime(time, function()
            local battlesong_instant_taunt_fx = SpawnPrefab("battlesong_instant_taunt_fx")
            battlesong_instant_taunt_fx.Transform:SetPosition(x, y, z)
            time = i + 0.5
        end)
    end
    local thunderbird_fx_idle = SpawnPrefab("thunderbird_fx_idle")
    thunderbird_fx_idle.Transform:SetPosition(x, y, z)

    inst:DoTaskInTime(3, function()
        local battlesong_instant_taunt_fx = SpawnPrefab("thunderbird_fx_shoot")
        battlesong_instant_taunt_fx.Transform:SetPosition(x, y, z)
    end)
end

local function ReleaseLightFx(inst)
    local fx = SpawnPrefab("fx_book_light_upgraded")
    local x, y, z = inst.Transform:GetWorldPosition()
    fx.Transform:SetScale(.9, 2.5, 1)
    fx.Transform:SetPosition(x, y, z)
end

local function SetUpEquip(inst)
    local inventory = inst.components.inventory
    if inventory ~= nil then
        -- priority use mnaginata
        if not inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
            local weapon = SpawnPrefab("mnaginata")
            inventory:Equip(weapon)
        end

        -- just a decoration, no effect
        if not inventory:GetEquippedItem(EQUIPSLOTS.HEAD) then
            local hat = SpawnPrefab("momo_hat")
            inventory:Equip(hat)
        end

        local mortalblade = SpawnPrefab("mortalblade")
        inventory:GiveItem(mortalblade)
    end
end

-- switch weapon, mnaginata or mortalblade
local function SwitchWeapon(inst, weapon)
    local inventory = inst.components.inventory
    if inventory ~= nil and type(weapon) == "string" then
        -- first take off the weapon in your hand and equip it with a new weapon
        local _weapon = inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if _weapon ~= nil then
            inventory:Unequip(_weapon)
            inventory:GiveItem(_weapon)
        end

        local weapon = inventory:FindItem(function(inst) return inst:HasTag(weapon) end)
        inventory:Equip(weapon)
        if weapon ~= nil and weapon.UnsheathMode ~= nil then
            weapon:UnsheathMode(inst)
        end
    end
end

local function OnSave(inst, data)
    if inst.honey ~= nil then
        data.honey_userid = inst.honey.userid
    end
end

local function OnLoad(inst, data)
    if data ~= nil then
        inst.honey_userid = data.honey_userid
    end
end

-- initialization
local function OnPostInit(inst)
    -- release lighting effects when appearing
    inst:ReleaseLightFx()

    -- fade in
    inst.components.spawnfader:FadeIn()
end

local function OnChangePhase(inst, phase)
    local honey = inst:TheHoney()
    if honey ~= nil then
        -- open up the aperture for honey and self at night
        if phase == "night" then
            if honey.momo_light == nil and inst.momo_light == nil then
                honey.momo_light = CreateLight()
                honey.momo_light.Follower:FollowSymbol(honey.GUID)
                inst:PushEvent("releaselight", {phase = phase})
                inst:DoTaskInTime(2, function(inst)
                    inst.momo_light = CreateLight()
                    inst.momo_light.Follower:FollowSymbol(inst.GUID)
                end)
            else
                honey.momo_light.Light:Enable(true)
                inst.momo_light.Light:Enable(true)
                inst:PushEvent("releaselight", {sametime = true, phase = phase})
            end
        elseif phase == "day" then
            if honey.momo_light ~= nil and inst.momo_light ~= nil then
                inst.momo_light.Light:Enable(false)
                honey.momo_light.Light:Enable(false)
                inst:PushEvent("releaselight", {phase = phase})
            end
        end
    end
end

local function OnStartADate(inst)
    inst:SetUpEquip()

    -- cancel invincible
    inst.components.health:SetInvincible(false)

    local honey = inst:TheHoney()

    -- track target and pantsu
    if honey ~= nil then
        -- lock the target and never give up
        inst.components.combat:SetTarget(honey)

        -- track all status of target, health, hunger, san
        inst.components.tracktargetstatus:StartTrack(honey)
    end
end

local function OnAttackOther(inst, data)

end

local function RegisterMasterEventListeners(inst)
    inst:ListenForEvent("onattackother", OnAttackOther)
    inst:ListenForEvent("admitdefeated", Defeated)
end

local function RegisterWorldStateWatchers(inst)
    inst:WatchWorldState("phase", OnChangePhase)
end

local function SetInstanceValue(inst)
    inst.numberofbribes = 0
    inst.customidleanim = "idle_wanda"
    inst.soundsname = "wendy"
    inst.momo_skins = momo_skins
end

local function SetInstanceFunctions(inst)
    inst.OnPostInit = OnPostInit
    inst.SetUpEquip = SetUpEquip
    inst.SwitchWeapon = SwitchWeapon
    inst.ReleaseLightFx = ReleaseLightFx
    inst.Defeated = Defeated
    inst.ChargeEffects = ChargeEffects
    inst.IsPantsu = IsPantsu
    inst.TheHoney = TheHoney
    inst.CreateLight = CreateLight
    inst.OnStartADate = OnStartADate

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddDynamicShadow()
	inst.entity:AddNetwork()

    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild(momo_skins[math.random(1, #momo_skins)])
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetScale(0.94, 0.94, 1)

    inst.AnimState:Hide("ARM_carry")
    inst.AnimState:Hide("HAT")
    inst.AnimState:Hide("HAIR_HAT")
    inst.AnimState:Show("HAIR_NOHAT")
    inst.AnimState:Show("HAIR")
    inst.AnimState:Show("HEAD")
    inst.AnimState:Hide("HEAD_HAT")
    inst.AnimState:Hide("HEAD_HAT_NOHELM")
    inst.AnimState:Hide("HEAD_HAT_HELM")

    inst.AnimState:AddOverrideBuild("player_idles_wanda")
    inst.AnimState:AddOverrideBuild("player_multithrust")
    inst.AnimState:AddOverrideBuild("player_attack_leap")
    inst.AnimState:AddOverrideBuild("player_superjump")
    inst.AnimState:AddOverrideBuild("player_actions_uniqueitem")

    inst.DynamicShadow:SetSize(1.3, .6)

    -- inst.MiniMapEntity:SetIcon("momo.tex")
    -- inst.MiniMapEntity:SetPriority(10)

    MakeCharacterPhysics(inst, 75, .5)

    inst:AddTag("character")
    inst:AddTag("girl")

    -- inst:AddTag("momo_npc")

    -- trader (from trader component) added to pristine state for optimization
    inst:AddTag("trader")

    inst:AddComponent("spawnfader")

    inst:AddComponent("talker")
    inst.components.talker.offset = Vector3(0, -400, 0)
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.colour = Vector3(238 / 255, 69 / 255, 105 / 255)

	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
		return inst
	end

    inst:AddComponent("timer")
    inst:AddComponent("inventory")
    inst:AddComponent("entitytracker")
    inst:AddComponent("tracktargetstatus")
    inst:AddComponent("inspectable")
    inst:AddComponent("colouradder")

    inst:AddComponent("follower")
    inst.components.follower.canaccepttarget = true

    -- inst:AddComponent("healthtrigger")
	-- for i, v in pairs(PHASES) do
        -- 	inst.components.healthtrigger:AddTrigger(v.hp, v.fn)
	-- end

	inst:AddComponent("locomotor")
	inst.components.locomotor.walkspeed = TUNING.MOMO_WALKSPEED
	inst.components.locomotor.runspeed = TUNING.MOMO_RUNSPEED

	inst:AddComponent("health")
	inst.components.health:SetMinHealth(1)
	inst.components.health:SetMaxHealth(TUNING.MOMO_HEALTH)

    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnAccept
    inst.components.trader:SetOnRefuse(OnRefuse)
    inst.components.trader.deleteitemonaccept = false

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.UNARMED_DAMAGE)
    inst.components.combat.hiteffectsymbol = "torso"
    inst.components.combat:SetAttackPeriod(0.2)
    inst.components.combat:SetRange(TUNING.DEFAULT_ATTACK_RANGE)

    MakeMediumBurnableCharacter(inst, "torso")
    inst.components.burnable:SetBurnTime(TUNING.PLAYER_BURN_TIME)
    inst.components.burnable.nocharring = true

    MakeLargeFreezableCharacter(inst, "torso")

	inst:SetStateGraph("SGmomo")
	inst:SetBrain(brain)

    SetInstanceValue(inst)
    SetInstanceFunctions(inst)
    RegisterWorldStateWatchers(inst)
    RegisterMasterEventListeners(inst)

    inst:DoTaskInTime(0, OnPostInit)

    return inst
end

return Prefab("momo", fn, assets, prefabs)
    -- Prefab("momo_npc", fn, assets, prefabs)
