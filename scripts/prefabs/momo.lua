local dialogueutil = require("utils/dialogueutil")
local momo_extensions = require("prefabs/momo_extensions")
local privatefn = momo_extensions.privatefn
local publicfn = momo_extensions.publicfn
local SpawnStartingItems = privatefn.SpawnStartingItems
local PushDialogueScreen = dialogueutil.PushDialogueScreen

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
    Asset("ANIM", "anim/player_jump.zip"),
    Asset("ANIM", "anim/player_actions_scythe.zip"),
    Asset("ANIM", "anim/player_actions_axe.zip"),
    Asset("ANIM", "anim/player_actions_pickaxe.zip"),
    Asset("ANIM", "anim/player_actions_pickaxe_recoil.zip"),

    Asset("ANIM", "anim/momo.zip"),
    Asset("ANIM", "anim/momo_maid.zip"),
    Asset("ANIM", "anim/momo_school.zip"),
    Asset("ANIM", "anim/momo_sailor.zip"),
    Asset("ANIM", "anim/momo_dark.zip"),

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
    "fx_book_light_upgraded",
    "mnaginata",
    "momo_hat",
    "battlesong_instant_taunt_fx",
    "mortalblade",
    "momocube",
    "thunderbird_fx_idle",
    "wanda_attack_shadowweapon_old_fx",
    "thunderbird_fx_shoot",
}

local momo_skins = {
    "momo",
	"momo_sailor",
	"momo_school",
	"momo_maid",
    "momo_dark",
}

local profile_chat_icon = {
    "profileflair_food_steakfrites",
    "profileflair_food_pizza",
    "profileflair_waffle",
    "profileflair_food_jellyroll",
    "profileflair_food_grilledcheese",
}

local starting_inventory = {
    "mnaginata",
    "momo_hat",
    "mortalblade",
    "momocube",
}

local health_phase = {
    [1] = {
        hp = 0.5,
        fn = function(inst)
            inst:SwitchEquip("mortalblade", "HANDS")
        end
    },
}

local brain = require("brain/momobrain")

-- only accept pantsu and fruit from Louis, reject everything else
local function ShouldAcceptItem(inst, item, giver, count)
    local honey = inst:TheHoney()
    if honey ~= nil then
        return (giver == honey) and (item:HasTag("pantsu")) or (item:HasTag("mfruit"))
    end
end

local function OnAccept(inst, giver, item)
    if item ~= nil then
        if (item:HasTag("pantsu")) or (inst.numberofbribes >= 3) then
            inst:PushEvent("admitdefeated", {satisfi = true, str = "satisfi"})
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

local function OnMinHealth(inst, data)
    if data ~= nil then
        if data.str == nil then
            data.str = "defeated"
        end
        if data.str ~= nil then
            inst:MomoSay(data.str)
        end
    end
    inst:RemoveLight()
end

local function SetUpEquip(inst)
    local inventory = inst.components.inventory
    if inventory ~= nil then
        -- priority use mnaginata
        inst:Equip("mnaginata", inventory)
        -- just a decoration, no effect
        inst:Equip("momo_hat", inventory)
    end
end

local function OnSave(inst, data)
    if inst.honey ~= nil then
        data.honey_userid = inst.honey.userid
    end
end

local function OnPreLoad(inst, data)
    if data ~= nil then
        inst.honey_userid = data.honey_userid
    end
end

local function OnLoad(inst, data)
    -- if data ~= nil then
    --     inst.honey_userid = data.honey_userid
    -- end
end

-- initialization
local function OnPostInit(inst)
    -- release lighting effects when appearing
    inst:ReleaseLightFx()

    -- fade in
    inst.components.spawnfader:FadeIn()

    -- get starting items on spawn
    SpawnStartingItems(inst, inst.starting_inventory)

    -- Release Light on spawn
    inst:ReleaseLight(TheWorld.state.isnight)
end

local function OnChangePhase(inst, phase)
    -- Toggle Light on change phase
    inst:ToggleLight(phase)
end

local function OnStartADate(inst)
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

    for i, v in pairs(health_phase) do
        inst.components.healthtrigger:AddTrigger(v.hp, v.fn)
	end
end

local CheckLineList = {
    "CONFUSE",
    "RELIENED",
    "HOPEFUL",
    "DISAPPOINTMENT",
    "GRATEFUL",
    "WORRIED",
    "FRUSTRATED",
    "SURPRISED",
    "CURIOUS",
}

local function GetStatus(inst, viewer)
    local datingmanager = TheWorld.components.datingmanager
    local isdatingrelationship = datingmanager ~= nil and datingmanager:GetIsDatingRelationship() or false
    if viewer ~= nil and viewer:HasTag("naughtychild") and isdatingrelationship then
        return CheckLineList[math.random(1, #CheckLineList)]
    end
end

local function OnHitOtherFn(inst, target, damage, stimuli, weapon, damageresolved, spdamage, damageredirecttarget)
    if weapon ~= nil and target ~= nil and target:IsValid() then
        local fx = SpawnPrefab("wanda_attack_shadowweapon_old_fx")
        local x, y, z = target.Transform:GetWorldPosition()
        local radius = target:GetPhysicsRadius(.5)
        local angle = (inst.Transform:GetRotation() - 90) * DEGREES
        fx.Transform:SetPosition(x + math.sin(angle) * radius, 0, z + math.cos(angle) * radius)
	end
end

local function StartDialogue(inst)
    inst:MomoSay("HELLO")

    inst:DoTaskInTime(18, function(inst)
        local AcceptRequest = function()
            inst:MomoSay("ACCEPT")
        end

        local RejectRequest = function()
            OnStartADate(inst)
            inst:MomoSay("REJECT")
        end

        PushDialogueScreen(inst, STRINGS.MOMO.SELECT_REQUEST, AcceptRequest, RejectRequest)
    end)
end

local function OnRemove(inst)

end

local function RegisterMasterEventListeners(inst)
    inst:ListenForEvent("onstartadate", OnStartADate)
    inst:ListenForEvent("start_dialogue", StartDialogue)
    inst:ListenForEvent("minhealth", OnMinHealth)
    inst:ListenForEvent("admitdefeated", OnMinHealth)
    inst:ListenForEvent("onremove", OnRemove)
end

local function RegisterWorldStateWatchers(inst)
    inst:WatchWorldState("phase", OnChangePhase)
end

local function DoWorldStateInit(inst)
    OnChangePhase(inst, TheWorld.state.phase)
end

local function SetInstanceValue(inst)
    inst.numberofbribes = 0
    inst.customidleanim = "idle_wanda"
    inst.soundsname = "wendy"
    inst.momo_skins = momo_skins
    inst.profile_chat_icon = profile_chat_icon
    inst.starting_inventory = starting_inventory
end

local Idle_Anim = {
    "idle_wendy",
    "idle_wathgrithr",
    "idle_walter",
    "idle_wortox",
    "idle_wanda",
    "idle_winona",
    "idle_wilson",
    "idle_wilson",
    "emote_impatient",
}

local Funny_Idle_Anim = {
    "wes_funnyidle",
    "idle_bocchi",
}

local function CustomIdleAnimFn(inst)
    return Idle_Anim[math.random(1, #Idle_Anim)]
end

local function CustomIdleStateFn(inst)
    return Funny_Idle_Anim[math.random(1, #Funny_Idle_Anim)]
end

local function SetInstanceFunctions(inst)
    for k, v in pairs(publicfn) do
        inst[k] = v
    end

    inst.OnPostInit = OnPostInit
    inst.SetUpEquip = SetUpEquip
    inst.OnStartADate = OnStartADate
    inst.StartDialogue = StartDialogue

    inst.customidleanim = CustomIdleAnimFn
    inst.customidlestate = CustomIdleStateFn

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnPreload = OnPreLoad
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddMiniMapEntity()
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

    inst.AnimState:AddOverrideBuild("player_multithrust")
    inst.AnimState:AddOverrideBuild("player_attack_leap")
    inst.AnimState:AddOverrideBuild("player_superjump")
    inst.AnimState:AddOverrideBuild("player_actions_uniqueitem")

    inst.AnimState:AddOverrideBuild("player_idles_wes")
    inst.AnimState:AddOverrideBuild("player_idles_wendy")
    inst.AnimState:AddOverrideBuild("player_idles_wanda")

    inst.DynamicShadow:SetSize(1.3, .6)

    inst.MiniMapEntity:SetIcon("momo.tex")
    inst.MiniMapEntity:SetPriority(10)

    MakeCharacterPhysics(inst, 75, .5)

    inst:AddTag("character")
    inst:AddTag("girl")
    inst:AddTag("pocketwatchcaster")
    inst:AddTag("naughtychild")
    inst:AddTag("momo_npc")
    -- inst:AddTag("momocubecaster")

    -- trader (from trader component) added to pristine state for optimization
    inst:AddTag("trader")

    inst:AddComponent("spawnfader")
    inst:AddComponent("despawnfader")

    inst:AddComponent("talker")
    inst.components.talker.fontsize = 30
    inst.components.talker.offset = Vector3(0, -400, 0)
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.colour = Vector3(238 / 255, 69 / 255, 105 / 255)
    inst.components.talker.chaticon = profile_chat_icon[math.random(1, #profile_chat_icon)]
    inst.components.talker.chaticonbg = "playerlevel_bg_lavaarena"
    inst.components.talker:MakeChatter()

	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
		return inst
	end

    inst:AddComponent("timer")
    inst:AddComponent("inventory")
    inst:AddComponent("entitytracker")
    inst:AddComponent("tracktargetstatus")
    inst:AddComponent("colouradder")
    inst:AddComponent("healthtrigger")

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

	inst:AddComponent("health")
	inst.components.health:SetMinHealth(1)
	inst.components.health:SetMaxHealth(TUNING.MOMO_HEALTH)

	inst:AddComponent("locomotor")
	inst.components.locomotor.walkspeed = TUNING.MOMO_WALKSPEED
	inst.components.locomotor.runspeed = TUNING.MOMO_RUNSPEED
    inst.components.locomotor.pathcaps = { allowocean = true, ignorecreep = true }
    inst.components.locomotor:SetTriggersCreep(false)

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
    inst.components.combat.onhitotherfn = OnHitOtherFn

    MakeMediumBurnableCharacter(inst, "torso")
    MakeLargeFreezableCharacter(inst, "torso")

	inst:SetBrain(brain)
	inst:SetStateGraph("SGmomo")

    SetInstanceValue(inst)
    SetInstanceFunctions(inst)
    RegisterWorldStateWatchers(inst)
    RegisterMasterEventListeners(inst)

    inst:DoTaskInTime(0, function(inst)
        OnPostInit(inst)
        DoWorldStateInit(inst)
    end)

    return inst
end

return Prefab("momo", fn, assets, prefabs)
