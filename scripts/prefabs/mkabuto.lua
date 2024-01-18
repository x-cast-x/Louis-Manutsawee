local assets = {
    Asset("ANIM", "anim/mkabuto.zip"),
    Asset("ANIM", "anim/mkabuto_swap.zip"),
    Asset("ANIM", "anim/m2kabuto_swap.zip"),
}

local function MaskMode(inst)
	local owner = inst.components.inventoryitem.owner
	if inst.maskstatus then
        owner.AnimState:OverrideSymbol("swap_hat", "mkabuto_swap", "swap_hat")
	else
        owner.AnimState:OverrideSymbol("swap_hat", "m2kabuto_swap", "swap_hat")
	end
end

local function OnEquip(inst, owner)
    MaskMode(inst)

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

local function CastFn(inst, target)
    if inst.maskstatus then
        inst.maskstatus = false
    else
        inst.maskstatus = true
    end

    MaskMode(inst)
end

local function onSave(inst, data)
    data.maskstatus = inst.maskstatus
end

local function onLoad(inst, data)
    if data ~= nil then
        inst.maskstatus = data.maskstatus or false
    end
end

local function fn()
 local inst = CreateEntity()

	inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

	inst:AddTag("hat")

    MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("mkabuto")
    inst.AnimState:SetBuild("mkabuto")
    inst.AnimState:PlayAnimation("idle")

	inst.spelltype = "SCIENCE"

	MakeInventoryFloatable(inst, "med", 0.1)

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

    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(CastFn)
    inst.components.spellcaster.canusefrominventory = true
    inst.components.spellcaster.quickcast = true

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

	inst.maskstatus = false
	inst.OnSave = onSave
    inst.OnLoad = onLoad

	MakeHauntableLaunch(inst)

    return inst
end

return Prefab("mkabuto", fn, assets)
