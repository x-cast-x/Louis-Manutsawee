local assets = {
    Asset("ANIM", "anim/mnaginata.zip"),
    Asset("ANIM", "anim/swap_mnaginata.zip"),
}

local function OnEquip(inst, owner)
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
	owner.AnimState:OverrideSymbol("swap_object", "swap_mnaginata", "swap_weapon")

	if owner:HasTag("kenjutsu") then
		inst:AddTag("yari")
		inst.components.weapon:SetDamage(TUNING.HARAKIRI_DAMAGE+(owner.kenjutsulevel*2))
	end
end

local function OnUnequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

	if owner:HasTag("kenjutsu") then
        inst:RemoveTag("yari")
    end

    inst.components.weapon:SetDamage(TUNING.HARAKIRI_DAMAGE)
end

local function onattack(inst, owner, target)
    if owner.components.rider:IsRiding() then
        return
    end

	local effect = SpawnPrefab("impact")
	effect.Transform:SetPosition(target:GetPosition():Get())
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddMiniMapEntity()

	inst.MiniMapEntity:SetIcon("mnaginata.tex")

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("mnaginata")
    inst.AnimState:SetBuild("mnaginata")
    inst.AnimState:PlayAnimation("idle")

	inst:AddTag("sharp")
	inst:AddTag("yarispear")

	MakeInventoryFloatable(inst, "large", 0.1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

    inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(TUNING.HARAKIRI_DAMAGE)
	inst.components.weapon:SetRange(1.6, 1.8)
	inst.components.weapon:SetOnAttack(onattack)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.MNAGINATA_USES)
    inst.components.finiteuses:SetUses(TUNING.MNAGINATA_USES)
    inst.components.finiteuses:SetOnFinished(inst.Remove)

	MakeHauntableLaunch(inst)

    return inst
end

return Prefab("mnaginata", fn, assets)
