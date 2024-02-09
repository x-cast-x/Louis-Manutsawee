local assets = {
	Asset("ANIM", "anim/tokishin.zip"),
	Asset("ANIM", "anim/swap_tokishin.zip"),
	Asset("ANIM", "anim/sc_tokishin.zip"),
}


local function OnAttack(inst, attacker, target)

end

local function OnPutInInventory(inst, owner)
    -- body
end

local function OnEquip(inst, owner)
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    inst.components.weapon:SetDamage(TUNING.TOKISHIN_DAMAGE + (owner.kenjutsulevel * 2))
    if owner.kenjutsulevel < 6 then
        inst.components.equippable.dapperness = TUNING.CRAZINESS_MED
        owner.SwitchControlled(inst, true)
    end
end

local function OnUnequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    owner.AnimState:ClearOverrideSymbol("face")

    inst.components.equippable.dapperness = 0
	inst.components.weapon:SetDamage(TUNING.TOKISHIN_DAMAGE)

    owner.SwitchControlled(inst, false)
end

local function OnPocket(inst, owner)
    if not owner:HasTag("notshowscabbard") and owner:HasTag("player") then
        owner.SwitchControlled(inst, true)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("tokishin")
    inst.AnimState:SetBuild("tokishin")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("nosteal")
    inst:AddTag("sharp")
    inst:AddTag("waterproofer")

    --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

    MakeInventoryFloatable(inst, nil, 0.1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(0)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.TOKISHIN_DAMAGE)
    inst.components.weapon:SetOnAttack(OnAttack)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.nobounce = true
    inst.components.inventoryitem.keepondeath = true
    inst.components.inventoryitem.keepondrown = true
    inst.components.inventoryitem.canonlygoinpocket = true
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)

    -- inst:AddComponent("finiteuses")
    -- inst.components.finiteuses:SetMaxUses(TUNING.KATANA.USES)
    -- inst.components.finiteuses:SetUses(TUNING.KATANA.USES)
    -- inst.components.finiteuses:SetOnFinished(OnFinished)

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
    inst.components.equippable:SetOnPocket(OnPocket)
    inst.components.equippable.is_magic_dapperness = true

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("tokishin", fn, assets)
