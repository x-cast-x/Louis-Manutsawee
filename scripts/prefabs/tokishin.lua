local assets = {
	Asset("ANIM", "anim/tokishin.zip"),
	Asset("ANIM", "anim/swap_tokishin.zip"),
	-- Asset("ANIM", "anim/sc_tokishin.zip"),
}

local hitsparks_fx_colouroverride = {1, 0, 0}
local function OnAttack(inst, attacker, target)
    if target ~= nil and target:IsValid() then
        local spark = SpawnPrefab("hitsparks_fx")
        spark:Setup(attacker, target, nil, hitsparks_fx_colouroverride)
        spark.black:set(true)
    end
end

local function OnPutInInventory(inst, owner)
    if (not owner.components.kenjutsuka:GetKenjutsuLevel() < 6) and owner.SwitchControlled ~= nil then
        owner.components.inventory:DropItem(inst)
    end
end

local function OnEquip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "swap_tokishin" , "swap_tokishin")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    if (not owner.components.kenjutsuka:GetKenjutsuLevel() < 6) and owner.SwitchControlled ~= nil then
        -- inst.components.weapon:SetDamage(TUNING.TOKISHIN_DAMAGE + (owner.components.kenjutsuka:GetKenjutsuLevel() * 2))
        inst.components.equippable.dapperness = TUNING.CRAZINESS_MED
        owner.SwitchControlled(owner, true)
    end
end

local function OnUnequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    inst.components.equippable.dapperness = 0

    if owner.SwitchControlled ~= nil then        
        inst.components.weapon:SetDamage(TUNING.TOKISHIN_DAMAGE)
        owner.SwitchControlled(owner, false)
    end
end

local function OnLoad(inst)
    local owner = inst.components.inventoryitem:GetGrandOwner()
    if owner ~= nil and (not owner.components.kenjutsuka:GetKenjutsuLevel() < 6) and owner.SwitchControlled ~= nil then
        -- inst.components.weapon:SetDamage(TUNING.TOKISHIN_DAMAGE + (owner.components.kenjutsuka:GetKenjutsuLevel() * 2))
    end
end

local function OnPocket(inst, owner)
    -- if owner.SwitchControlled ~= nil and not owner:HasTag("notshowscabbard") and owner:HasTag("player") then
    --     owner.SwitchControlled(owner, true)
    -- end
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

    local swap_data = {sym_build = "swap_tokishin", bank = "tokishin"}
    MakeInventoryFloatable(inst, "med", nil, {1.0, 0.5, 1.0}, true, -13, swap_data)

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

    inst.OnLoad = OnLoad

    return inst
end

return Prefab("tokishin", fn, assets)
