local assets = {
    Asset("ANIM", "anim/harakiri.zip"),
    Asset("ANIM", "anim/swap_harakiri.zip"),
}

local function OnEquip(inst, owner)
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    owner.AnimState:OverrideSymbol("swap_object", "swap_harakiri", "swap_harakiri")
end

local function OnUnequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function CastFn(inst, target)
    local owner = inst.components.inventoryitem.owner
    local health = owner.components.health
    local inventory = owner.components.inventory
    local body = inventory:GetEquippedItem(EQUIPSLOTS.BODY)
    local head = inventory:GetEquippedItem(EQUIPSLOTS.HEAD)

    if body ~= nil then
        inventory:DropItem(body)
    end

    if head ~= nil then
        inventory:DropItem(head)
    end

    if health ~= nil then
        if health:IsInvincible() then
            health:SetInvincible(false)
        end
        health:Kill()
    end

    local impactfx = SpawnPrefab("impact")
    impactfx.entity:AddFollower()
    impactfx.Follower:FollowSymbol(owner.GUID, owner.components.combat.hiteffectsymbol, 0, 0, 0)
    impactfx:FacePoint(owner.Transform:GetWorldPosition())
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("harakiri")
    inst.AnimState:SetBuild("harakiri")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("sharp")
    inst:AddTag("quickcast")

    inst.spelltype = "SUICIDE"

    MakeInventoryFloatable(inst, nil, 0.1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    inst:AddComponent("inspectable")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.HARAKIRI_DAMAGE)

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(CastFn)
    inst.components.spellcaster.veryquickcast = true
    inst.components.spellcaster.canusefrominventory = true

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.HARAKIRI_USES)
    inst.components.finiteuses:SetUses(TUNING.HARAKIRI_USES)
    inst.components.finiteuses:SetOnFinished(inst.Remove)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("harakiri", fn, assets)
