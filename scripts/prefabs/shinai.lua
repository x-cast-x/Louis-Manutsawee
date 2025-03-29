local assets = {
    Asset("ANIM", "anim/shinai.zip"),
    Asset("ANIM", "anim/swap_shinai.zip"),
}

local DMG = 25
local function OnEquip(inst, owner)
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    owner.AnimState:OverrideSymbol("swap_object", "swap_shinai", "swap_shinai")

    if owner.components.kenjutsuka:GetLevel() ~= nil then --Owner
        inst.components.spellcaster.canusefrominventory = true

        if owner.components.kenjutsuka:GetLevel() >= 1 and not inst:HasTag("mkatana") then
            inst:AddTag("mkatana")
        end
    end
end

local function OnUnequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    if owner.components.kenjutsuka:GetLevel() ~= nil then --Owner
        inst.components.spellcaster.canusefrominventory = false
        inst:RemoveTag("mkatana")
    end
end

local trainingcount = 0
local function CastFn(inst, target, pos, owner)
    local kenjutsuka = owner.components.kenjutsuka
    local kenjutsuexp = kenjutsuka:GetExp()
    local kenjutsumaxexp = kenjutsuka.kenjutsumaxexp
    local kenjutsulevel = kenjutsuka:GetLevel()
    if kenjutsulevel ~= nil then
        if kenjutsulevel < 10 and kenjutsuexp < kenjutsumaxexp - (kenjutsumaxexp/2) then
            kenjutsuexp = owner.kenjutsuexp + 1
            trainingcount = trainingcount +1
            owner.components.hunger:DoDelta(-1)
            if trainingcount == 5 then
                kenjutsuexp = kenjutsuexp + 1
                owner.SoundEmitter:PlaySound("turnoftides/common/together/boat/jump")
                trainingcount = 0
            end
        else
            owner.components.talker:Say("Enough for training.")
        end
    end
end

local function OnAttack(inst, owner, target)
    if owner.components.rider ~= nil and owner.components.rider:IsRiding() then
        return
    end
    local kenjutsuka = owner.components.kenjutsuka
    local kenjutsuexp = kenjutsuka:GetExp()
    local kenjutsulevel = kenjutsuka:GetLevel()

    if kenjutsulevel >= 1 and not inst:HasTag("mkatana") then
        inst:AddTag("mkatana")
    end
    if math.random(1, 5) == 1 then
        if kenjutsulevel < 10 then
            kenjutsuexp = kenjutsuexp + math.random(1, 3)
        end
        owner.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
        local effect = SpawnPrefab("impact")
        effect.Transform:SetPosition(target:GetPosition():Get())
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("shinai")
    inst.AnimState:SetBuild("shinai")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("katanaskill")
    inst:AddTag("woodensword")

    inst.spelltype = "SCIENCE"
    inst:AddTag("quickcast")

    MakeInventoryFloatable(inst, "small", 0.1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    inst:AddComponent("inspectable")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(DMG)
    inst.components.weapon:SetOnAttack(OnAttack)
    inst.components.weapon:SetRange(.6, 1)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(300)
    inst.components.finiteuses:SetUses(300)
    inst.components.finiteuses:SetOnFinished(inst.Remove)

    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(CastFn)
    inst.components.spellcaster.quickcast = true
    inst.components.spellcaster.canusefrominventory = false

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("shinai", fn, assets)
