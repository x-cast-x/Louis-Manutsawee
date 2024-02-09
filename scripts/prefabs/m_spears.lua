local function OnEquip(inst, owner)
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
	owner.AnimState:OverrideSymbol("swap_object", "swap_" .. inst.prefab , "swap_" .. inst.prefab)

	if owner:HasTag("kenjutsu") then
		inst:AddTag("yari")
		inst.components.weapon:SetDamage(TUNING.YARI_DAMAGE + (owner.kenjutsulevel * 2))
	end
end

local function OnUnequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

	if owner:HasTag("kenjutsu") then
        inst:RemoveTag("yari")
    end

    inst.components.weapon:SetDamage(TUNING.YARI_DAMAGE)
end

local function OnAttack(inst, owner, target)
	if owner.components.rider:IsRiding() then
        return
    end

	local effect = SpawnPrefab("impact")
	effect.Transform:SetPosition(target:GetPosition():Get())
end

local function MakeSpear(name)
    local assets = {
        Asset("ANIM", "anim/" .. name .. ".zip"),
        Asset("ANIM", "anim/swap_" .. name .. ".zip"),
    }

    local function fn()
        local inst = CreateEntity()
    
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
        inst.entity:AddMiniMapEntity()
    
        inst.MiniMapEntity:SetIcon(name .. ".tex")
    
        MakeInventoryPhysics(inst)
    
        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation("idle")
    
        inst:AddTag("sharp")
        inst:AddTag("yarispear")
    
        local swap_data = {sym_build = "swap_" .. name, bank = name}
        MakeInventoryFloatable(inst, "med", nil, {1.0, 0.5, 1.0}, true, -13, swap_data)
    
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
        inst.components.weapon:SetDamage(TUNING.YARI_DAMAGE)
        inst.components.weapon:SetRange(1.6, 1.8)
        inst.components.weapon:SetOnAttack(OnAttack)
    
        inst:AddComponent("finiteuses")
        inst.components.finiteuses:SetMaxUses(TUNING.YARI_USES)
        inst.components.finiteuses:SetUses(TUNING.YARI_USES)
        inst.components.finiteuses:SetOnFinished(inst.Remove)
    
        MakeHauntableLaunch(inst)
    
        return inst
    end

    return Prefab(name, fn, assets)
end

return MakeSpear("yari"),
    MakeSpear("mnaginata")