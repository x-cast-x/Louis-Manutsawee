local assets = {
    Asset("ANIM", "anim/mkabuto2.zip"),
    Asset("ANIM", "anim/mkabuto2_swap.zip"),
}

local function OnEquip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_hat", "mkabuto2_swap", "swap_hat")
    owner.AnimState:Show("HAT")
    owner.AnimState:Show("HAIR_HAT")
    owner.AnimState:Hide("HAIR_NOHAT")
    owner.AnimState:Hide("HAIR")

    if owner:HasTag("player") then
        owner.AnimState:Hide("HEAD")
        owner.AnimState:Show("HEAD_HAT")
    end
end

local function OnUnequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_hat")
    owner.AnimState:Hide("HAT")
    owner.AnimState:Hide("HAIR_HAT")
    owner.AnimState:Show("HAIR_NOHAT")
    owner.AnimState:Show("HAIR")

    if owner:HasTag("player") then
        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAT")
    end
end

local function fn()
 local inst = CreateEntity()

	inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

	inst:AddTag("hat")

    MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("mkabuto2")  --MAKE SURE TO REFERENCE THE RIGHT BANK WHEN MAKING DROPPED ITEMS
    inst.AnimState:SetBuild("mkabuto2")
    inst.AnimState:PlayAnimation("idle")

	MakeInventoryFloatable(inst)
	inst.components.floater:SetSize("med")
    inst.components.floater:SetVerticalOffset(0.1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
	inst:AddComponent("tradable")

	inst:AddComponent("armor")
    inst.components.armor:InitCondition(TUNING.ARMOR_FOOTBALLHAT*2, TUNING.ARMOR_FOOTBALLHAT_ABSORPTION)

	inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

	MakeHauntableLaunch(inst)

    return inst
end

return Prefab("mkabuto2", fn, assets)
