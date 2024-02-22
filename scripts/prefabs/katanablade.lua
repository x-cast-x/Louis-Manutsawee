local assets = {
    Asset("ANIM", "anim/katanablade.zip"),
    Asset("ANIM", "anim/swap_katanablade.zip"),
}

local function OnEquip(inst, owner)
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
	owner.AnimState:OverrideSymbol("swap_object", "swap_katanablade", "swap_katanablade")

	if owner:HasTag("kenjutsu") then
		inst.components.weapon:SetDamage(TUNING.YARI_DAMAGE + (owner.components.kenjutsuka:GetKenjutsuLevel()*2))
	end

	if owner:HasTag("kenjutsu") and not inst:HasTag("mkatana") then
        inst:AddTag("mkatana")
    end
end

local function OnUnequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

	if owner.components.kenjutsuka:GetKenjutsuLevel() ~= nil then
        inst:RemoveTag("mkatana")
	end

    inst.components.weapon:SetDamage(TUNING.YARI_DAMAGE)
end

local function onattack(inst, owner, target)
	if owner.components.rider:IsRiding() then
        return
    end

    if math.random(1,4) == 1 then
		local x = math.random(1, 1.2)
		local y = math.random(1, 1.2)
		local z = math.random(1, 1.2)
		local slash	= {"shadowstrike_slash_fx","shadowstrike_slash2_fx"}

		slash = SpawnPrefab(slash[math.random(1,2)])
		slash.Transform:SetPosition(target:GetPosition():Get())
		slash.Transform:SetScale(x, y, z)
	end

    if owner:HasTag("kenjutsu") and not inst:HasTag("mkatana") then
        inst:AddTag("mkatana")
    end

	inst.components.weapon.attackwear = target ~= nil and target:IsValid()
		and (target:HasTag("shadow") or target:HasTag("shadowminion") or target:HasTag("shadowchesspiece") or target:HasTag("stalker") or target:HasTag("stalkerminion"))
		and TUNING.GLASSCUTTER.SHADOW_WEAR
		or 1
end

local function Onfinish(inst)
	inst:Remove()
end

local function OnFinishCallback(inst, chopper)
    local pt = inst.Transform:GetWorldPosition()
	local collapse_fx = SpawnPrefab("crab_king_shine")
    collapse_fx.Transform:SetPosition(pt)

	local item = SpawnPrefab("katanablade")
	item.Transform:SetPosition(pt)
	item.SoundEmitter:PlaySound("dontstarve/wilson/equip_item_gold")

	inst:Remove()
end

local function OnWorkCallback(inst, worker, workleft)
    if not worker:HasTag("player") then
        inst.components.workable:SetWorkLeft(workleft)
        return
    end

	local fx = SpawnPrefab("sparks")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.SoundEmitter:PlaySound("dontstarve/impacts/impact_mech_med_sharp")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("katanablade")
    inst.AnimState:SetBuild("katanablade")
    inst.AnimState:PlayAnimation("idle")

	--inst:AddTag("nosteal")
	inst:AddTag("sharp")
	inst:AddTag("woodensword")
    inst:AddTag("katanaskill")

	inst:AddTag("weapon")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(TUNING.YARI_DAMAGE)
	inst.components.weapon:SetOnAttack(onattack)
	inst.components.weapon:SetRange(.8, 1.2)

    inst:AddComponent("inspectable")

	inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(0)

	inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetMaxUses(TUNING.BLADE_USES)
	inst.components.finiteuses:SetUses(TUNING.BLADE_USES)
	inst.components.finiteuses:SetOnFinished(Onfinish)

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem:SetSinks(true)
	--inst.components.inventoryitem.canonlygoinpocket = true

	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
	inst.components.equippable.walkspeedmult = 1.15

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetOnFinishCallback(OnFinishCallback)
	inst.components.workable:SetWorkLeft(10)
	inst.components.workable:SetOnWorkCallback(OnWorkCallback)
	inst.components.workable:SetWorkable(true)

	MakeHauntableLaunch(inst)

    return inst
end

return Prefab("katanablade", fn, assets)
