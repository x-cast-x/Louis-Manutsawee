local assets = {
    Asset("ANIM", "anim/momo_hat.zip"),
}

local function OnEquip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_hat", "momo_hat", "swap_hat")
    owner.AnimState:Show("HAT")
end

local function OnUnequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_hat")
    owner.AnimState:Hide("HAT")
end

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("momo_hat")
    inst.AnimState:SetBuild("momo_hat")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("hat")

    MakeInventoryFloatable(inst, "small", 0.1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

    MakeHauntableLaunch(inst)

    return inst
end

table.insert(ALL_HAT_PREFAB_NAMES, "momo_hat")

return Prefab("momo_hat", fn, assets)
