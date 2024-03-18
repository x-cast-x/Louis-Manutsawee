local assets = {
    Asset("ANIM", "anim/momoaxe.zip"),
    Asset("ANIM", "anim/swap_momoaxe.zip"),
}

local prefabs = {
    "alterguardian_spintrail_fx",
}

local function OnEquip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_momoaxe", "swap_momoaxe")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    owner.components.combat.min_attack_period = 0.64
end

local function OnUnequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    owner.components.combat.min_attack_period = TUNING.WILSON_ATTACK_PERIOD
end

local function OnPocket(inst, owner)
	owner.components.combat.min_attack_period = TUNING.WILSON_ATTACK_PERIOD
end

local function OnPutInInventory(inst, owner)
	if owner ~= nil and owner.components.inventory ~= nil and not owner:HasTag("naughtychild") then
        inst:DoTaskInTime(0.1, function()
            owner.components.inventory:DropItem(inst)
        end)
	end
end

-- local counter = 0
-- local function OnAttack(inst, owner, target)
--     if target ~= nil and target.components.combat ~= nil then
--         local counter = counter + 1
--         if counter == 9 then
--             local quake = SpawnPrefab("alterguardian_spintrail_fx")
--             quake.Transform:SetPosition(target:GetPosition():Get())
--             quake.Transform:SetScale(1.6, 1.6, 1.6)
--             target.components.combat:GetAttacked(owner, inst.components.weapon.damage * 1.25)
--             owner.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/groundpound")

--             counter = 0
--         end
--     end
-- end

local function OnFinished(inst)
	local inventory = inst.components.inventoryitem:GetContainer()
	local item = SpawnPrefab("momocube")
	item.Transform:SetPosition(inst.Transform:GetWorldPosition())

	if inventory ~= nil then
		inventory:GiveItem(item)
	end

	inst:Remove()
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("momoaxe")
    inst.AnimState:SetBuild("momoaxe")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("sharp")

    --tool (from tool component) added to pristine state for optimization
    inst:AddTag("tool")

    --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

    MakeInventoryFloatable(inst, "small", 0.1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.MOMO.MOMOAXE_DAMAGE)
    inst.components.weapon:SetRange(1.01, 1.01)
    -- inst.components.weapon:SetOnAttack(OnAttack)

    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.CHOP, 3)
    inst.components.tool:SetAction(ACTIONS.MINE, 3)

    -- inst:AddComponent("fueled")
    -- inst.components.fueled:StartConsuming()
    -- inst.components.fueled:InitializeFuelLevel(TUNING.MOMO.EREBUS_DURABILITY)
    -- inst.components.fueled:SetDepletedFn(OnDepleted)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.MOMO.MOMOAXE_USES)
    inst.components.finiteuses:SetUses(TUNING.MOMO.MOMOAXE_USES)
    inst.components.finiteuses:SetOnFinished(OnFinished)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.keepondeath = true
    inst.components.inventoryitem.keepondrown = true
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
    inst.components.equippable:SetOnPocket(OnPocket)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("momoaxe", fn, assets, prefabs)
