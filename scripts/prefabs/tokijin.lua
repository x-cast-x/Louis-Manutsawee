local assets = {
	Asset("ANIM", "anim/tokijin.zip"),
	Asset("ANIM", "anim/swap_tokijin.zip"),
	Asset("ANIM", "anim/sc_tokijin.zip"),
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
    if owner:HasTag("player") and not owner:HasTag("manutsaweecraft") then
        owner.components.inventory:DropItem(inst)
        if owner.components.combat ~= nil then
            owner.components.combat:GetAttacked(inst, 50)
        end
        OnAttack(inst, owner, owner)
    end
end

local function OnEquip(inst, owner)
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
	owner.AnimState:OverrideSymbol("swap_object", "swap_tokijin" , "swap_tokijin")

	if not owner:HasTag("notshowscabbard")  then
        owner.AnimState:ClearOverrideSymbol("swap_body_tall")
    end

	if inst:HasTag("mkatana")then
        inst:RemoveTag("mkatana")
    end

    if inst:HasTag("iai") then
        inst:RemoveTag("iai")
    end

	if owner:HasTag("kenjutsu") and not inst:HasTag("mkatana") then
        inst:AddTag("mkatana")
    end

    inst.components.weapon:SetDamage(TUNING.TOKIJIN_DAMAGE + (owner.components.kenjutsuka:GetKenjutsuLevel() * 2))

    if owner.SwitchControlled ~= nil and owner.components.kenjutsuka:GetKenjutsuLevel() < 10 then
        inst.components.equippable.dapperness = TUNING.CRAZINESS_MED
        owner.SwitchControlled(owner, true)
    end
end

local function OnUnequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    inst.components.weapon:SetDamage(TUNING.TOKIJIN_DAMAGE)

	if inst:HasTag("mkatana") then
        inst:RemoveTag("mkatana")
    end

    if not inst:HasTag("iai") then
        inst:AddTag("iai")
    end

	if not owner:HasTag("notshowscabbard") then
        owner.AnimState:OverrideSymbol("swap_body_tall", "sc_tokijin", "tail")
    end

    if owner.SwitchControlled ~= nil and owner.components.kenjutsuka:GetKenjutsuLevel() < 10 then
        inst.components.equippable.dapperness = 0
        owner.SwitchControlled(owner, false)
    end
end

local function OnPocket(inst, owner)
    if owner ~= nil and not owner:HasTag("notshowscabbard") and owner:HasTag("player") then
        owner.AnimState:OverrideSymbol("swap_body_tall", "sc_tokijin", "tail")
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("tokijin")
    inst.AnimState:SetBuild("tokijin")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("nosteal")
    inst:AddTag("sharp")
    inst:AddTag("waterproofer")
    inst:AddTag("katanaskill")

    --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

    local swap_data = {sym_build = "swap_tokijin", bank = "tokijin"}
    MakeInventoryFloatable(inst, "med", nil, {1.0, 0.5, 1.0}, true, -13, swap_data)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(0)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.TOKIJIN_DAMAGE)
    inst.components.weapon:SetRange(1.6, 1.8)
    inst.components.weapon:SetOnAttack(OnAttack)

    inst:AddComponent("inventoryitem")
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

return Prefab("tokijin", fn, assets)
