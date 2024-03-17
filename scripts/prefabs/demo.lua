local assets =
{
    Asset("ANIM", "anim/backpack.zip"),
    Asset("ANIM", "anim/swap_demo.zip"),
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("backpack", "swap_demo", "backpack")
    owner.AnimState:OverrideSymbol("swap_body", "swap_demo", "swap_body")
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    owner.AnimState:ClearOverrideSymbol("backpack")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    -- inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    -- inst.MiniMapEntity:SetIcon("krampus_sack.png")

    inst.AnimState:SetBank("backpack1")
    inst.AnimState:SetBuild("demo")
    inst.AnimState:PlayAnimation("anim")

    --waterproofer (from waterproofer component) added to pristine state for optimization
    inst:AddTag("waterproofer")

    local swap_data = {bank = "backpack1", anim = "anim"}
    MakeInventoryFloatable(inst, "med", 0.1, 0.65, nil, nil, swap_data)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(0)

    MakeHauntableLaunchAndDropFirstItem(inst)

    return inst
end

return Prefab("demo", fn, assets)
