local assets = {
    Asset("ANIM", "anim/momo.zip"),
}

local prefabs = {
    "fx_book_light_upgraded",
    "mnaginata",
    "momo_hat",
    "battlesong_instant_taunt_fx",
    "mortalblade",
}

local brain = require("brain/momobrain")

local function GetPantsu(inst)
    return inst.components.entitytracker:GetEntity("m_pantsu")
end

local function GetTarget(inst)
    return inst.locksummoner ~= nil and inst.components.entitytracker:GetEntity(inst.locksummoner.prefab) or nil
end

local function ShouldAcceptItem(inst, item)
    return (item:HasTag("mfruit")) or (item.prefab == inst:GetPantsu())
end

local function OnAccept(inst, giver, item)
    if item ~= nil then
        if (item.prefab == inst:GetPantsu()) or (inst.numberofbribes > 3) then
            inst:PushEvent("admitdefeated")
        end

        if item:HasTag("mfruit") then
            inst.numberofbribes = inst.numberofbribes + 1
        end
    end
end

local function OnRefuse(inst, giver, item)

end

local function Defeated(inst)

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
        thunderbird_fx_shoot.Transform:SetPosition(x, y, z)
    end)
end

local function ReleaseLightFx(inst)
    local fx = SpawnPrefab("fx_book_light_upgraded")
    local x, y, z = inst.Transform:GetWorldPosition()
    fx.Transform:SetScale(.9, 2.5, 1)
    fx.Transform:SetPosition(x, y, z)
end

local function OnSave(inst, data)
    -- body
end

local function OnLoad(inst, data)
    -- body
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

        local weapon = inventory:GetItemSlot(weapon)
        inventory:Equip(weapon)
    end
end

-- initialization
local function OnPostInit(inst)
    -- release lighting effects when appearing
    inst:ReleaseLightFx()

    -- fade in
    if inst.components.spawnfader ~= nil then
        inst.components.spawnfader:FadeIn()
    end

    -- set invincible on spawn
    inst.components.health:SetInvincible(true)

    -- can only be summoned after defeating the alterguardian
    local moonstormmanager = TheWorld.components.moonstormmanager
    if (moonstormmanager ~= nil and (moonstormmanager:GetCelestialChampionsKilled() < 1)) then
        inst:PushEvent("taunt")
        return
    end

    -- If the alterguardian is defeated, then the battle begins
    SetUpEquip(inst)

    -- cancel invincible
    inst.components.health:SetInvincible(false)
end

local phase = {
    [1] = {
        percent = 30,
        fn = function()

        end
    }
}

--
local function OnHealthDelta(inst, data)

end

local function OnAttackOther(inst, data)

end

local function RegisterMasterEventListeners(inst)
    inst:ListenForEvent("healthdelta", OnHealthDelta)
    inst:ListenForEvent("onattackother", OnAttackOther)
    inst:ListenForEvent("admitdefeated", Defeated)
end

local function OnChangePhase(inst, phase)
    if phase == "night" then
        local target = inst.locksummoner
        if target ~= nil then

        end
    end
end

local function RegisterWorldStateWatchers(inst)
    inst:WatchWorldState("phase", OnChangePhase)
end

local function SetInstanceValue(inst)
    inst.numberofbribes = 0
end

local function SetInstanceFunctions(inst)
    inst.OnPostInit = OnPostInit
    inst.SetUpEquip = SetUpEquip
    inst.SwitchWeapon = SwitchWeapon
    inst.ReleaseLightFx = ReleaseLightFx
    inst.Defeated = Defeated
    inst.ChargeEffects = ChargeEffects
    inst.GetPantsu = GetPantsu
    inst.GetTarget = GetTarget
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
    inst.AnimState:SetBuild("momo")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetScale(0.94, 0.94, 1)

    inst.DynamicShadow:SetSize(1.3, .6)

    inst.MiniMapEntity:SetIcon("momo.tex")
    inst.MiniMapEntity:SetPriority(10)

    MakeCharacterPhysics(inst, 75, .5)

    inst:AddComponent("spawnfader")

    inst:AddComponent("talker")
    inst.components.talker.offset = Vector3(0, -400, 0)

	inst:AddTag("epic")
    inst:AddTag("character")

    -- trader (from trader component) added to pristine state for optimization
    inst:AddTag("trader")

	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
		return inst
	end

    inst:AddComponent("timer")
    inst:AddComponent("inventory")
    inst:AddComponent("entitytracker")

	inst:AddComponent("locomotor")
	inst.components.locomotor.walkspeed = TUNING.MOMO_WALKSPEED
	inst.components.locomotor.runspeed = TUNING.MOMO_RUNSPEED

	inst:AddComponent("health")
	inst.components.health:SetMinHealth(1)
	inst.components.health:SetMaxHealth(TUNING.MOMO_HEALTH)

    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader:SetOnAccept(OnAccept)
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
    inst.components.freezable:SetResistance(4)
    inst.components.freezable:SetDefaultWearOffTime(TUNING.PLAYER_FREEZE_WEAR_OFF_TIME)

	inst:SetStateGraph("SGmomo")
	inst:SetBrain(brain)

    SetInstanceValue(inst)
    SetInstanceFunctions(inst)
    RegisterWorldStateWatchers(inst)
    RegisterMasterEventListeners(inst)

    return inst
end

return Prefab("momo", fn, assets, prefabs)
