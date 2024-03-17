local Assets = {
    Asset("ANIM", "anim/mmiko_armor.zip"),
}

local prefabs = {
    "mforcefieldfx"
}

local function miko_fxanim(inst)
    inst._fx.AnimState:PlayAnimation("hit")
    inst._fx.AnimState:PushAnimation("idle_loop")
end

local function miko_oncooldown(inst)
    inst._task = nil
end

local function miko_unproc(inst)
    if inst:HasTag("forcefield") then
        inst:RemoveTag("forcefield")
        if inst._fx ~= nil then
            inst._fx:kill_fx()
            inst._fx = nil
        end
        inst:RemoveEventCallback("armordamaged", miko_fxanim)

        if inst.components.armor ~= nil then
            inst.components.armor:SetAbsorption(TUNING.ARMOR_RUINSHAT_ABSORPTION)
            inst.components.armor.ontakedamage = nil
        end

        if inst._task ~= nil then
            inst._task:Cancel()
        end
        inst._task = inst:DoTaskInTime(TUNING.ARMOR_RUINSHAT_COOLDOWN, miko_oncooldown)
    end
end

local function miko_proc(inst, owner)
    inst:AddTag("forcefield")
    if inst._fx ~= nil then
        inst._fx:kill_fx()
    end
    inst._fx = SpawnPrefab("mforcefieldfx")
    owner.components.talker:Say("Spiritual power is protecting me.")
    inst._fx.entity:SetParent(owner.entity)
    inst._fx.Transform:SetPosition(0, 0.2, 0)
    inst:ListenForEvent("armordamaged", miko_fxanim)

    if inst.components.armor ~= nil then
        inst.components.armor:SetAbsorption(TUNING.FULL_ABSORPTION)
        inst.components.armor.ontakedamage = function(inst, damage_amount)
            if owner ~= nil and owner.components.sanity ~= nil then
                owner.components.sanity:DoDelta(-damage_amount * TUNING.ARMOR_RUINSHAT_DMG_AS_SANITY, false)
            end
        end
    end

    if inst._task ~= nil then
        inst._task:Cancel()
    end
    inst._task = inst:DoTaskInTime(TUNING.ARMOR_RUINSHAT_DURATION, miko_unproc)
end

local function tryproc(inst, owner, data)
    if inst._task == nil and not data.redirected and math.random() < TUNING.ARMOR_RUINSHAT_PROC_CHANCE and inst.components.armor ~= nil then
        miko_proc(inst, owner)
    end
end

local function Armormode(inst, owner)
    if not inst.armorstatus then
        owner.AnimState:OverrideSymbol("swap_body", "mmiko_armor", "swap_body")
        inst:AddComponent("armor")
        inst.components.armor:InitCondition(TUNING.MMIKO_ARMOR_AMOUNT, TUNING.MMIKO_ARMOR_PRECENT)
    else
        owner.AnimState:ClearOverrideSymbol("swap_body")
        inst:RemoveComponent("armor")
    end
end

local function OnEquip(inst, owner)
    Armormode(inst, owner)
    inst.onattach(owner)
end

local function OnUnequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    inst.ondetach()
end

local function CastFn(inst, target, position, owner)
    local owner = inst.components.inventoryitem.owner

    if owner.prefab ~= "manutsawee" then
        return
    end

    if inst.armorstatus then
        inst.armorstatus = false
    else
        inst.armorstatus = true
    end

    Armormode(inst, owner)
end

local function OnSave(inst, data)
    data.armorstatus = inst.armorstatus
end

local function OnLoad(inst, data)
    if data ~= nil then
        inst.armorstatus = data.armorstatus or false
    end
end

local function miko_onremove(inst)
    if inst._fx ~= nil then
        inst._fx:kill_fx()
        inst._fx = nil
    end
end

local function MainFunction()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("mmiko_armor")
    inst.AnimState:SetBuild("mmiko_armor")
    inst.AnimState:PlayAnimation("anim")

    inst:AddTag("mikoarmor")
    inst.spelltype = "SCIENCE"

    MakeInventoryFloatable(inst, "small", 0.2, 1.1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_MED)

    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(CastFn)
    inst.components.spellcaster.canusefrominventory = true
    inst.components.spellcaster.quickcast = true

    inst:AddComponent("equippable")
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_SMALL
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

    inst.OnRemoveEntity = miko_onremove

    inst._fx = nil
    inst._task = nil
    inst._owner = nil

    inst.procfn = function(owner, data)
        tryproc(inst, owner, data)
    end

    inst.onattach = function(owner)
        if inst._owner ~= nil then
            inst:RemoveEventCallback("attacked", inst.procfn, inst._owner)
            inst:RemoveEventCallback("onremove", inst.ondetach, inst._owner)
        end
        inst:ListenForEvent("attacked", inst.procfn, owner)
        inst:ListenForEvent("onremove", inst.ondetach, owner)
        inst._owner = owner
        inst._fx = nil
    end

    inst.ondetach = function()
        miko_unproc(inst)
        if inst._owner ~= nil then
            inst:RemoveEventCallback("attacked", inst.procfn, inst._owner)
            inst:RemoveEventCallback("onremove", inst.ondetach, inst._owner)
            inst._owner = nil
            inst._fx = nil
        end
    end

    inst.armorstatus = false
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("mmiko_armor", MainFunction, Assets, prefabs)
