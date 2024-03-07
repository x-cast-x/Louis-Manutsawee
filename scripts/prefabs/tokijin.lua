local assets = {
	Asset("ANIM", "anim/tokijin.zip"),
	Asset("ANIM", "anim/swap_tokijin.zip"),
	Asset("ANIM", "anim/sc_tokijin.zip"),
}

local prefabs = {
    "fused_shadeling_spawn_fx",
    "dreadstone_spawn_fx",
    "m_shadowhand_fx",
    "sanity_lower",
    "hitsparks_fx",
    "pocketwatch_weapon_fx",
}

local hitsparks_fx_colouroverride = {1, 0, 0}
local function OnAttack(inst, attacker, target)
    if target ~= nil and target:IsValid() then
        local spark = SpawnPrefab("hitsparks_fx")
        spark:Setup(attacker, target, nil, hitsparks_fx_colouroverride)
        spark.black:set(true)
        local damage = inst.components.weapon.damage * .8
        if inst.swirl ~= nil then
            damage = inst.components.weapon.damage * 4
        end
        if target.components.combat ~= nil then
            target.components.combat:GetAttacked(attacker, damage)
        end
    end
end

local function OnPutInInventory(inst, owner)
    if owner:HasTag("player") and not owner:HasTag("bladesmith") then
        owner.components.inventory:DropItem(inst)
        if owner.components.combat ~= nil then
            owner.components.combat:GetAttacked(inst, 50)
        end
        OnAttack(inst, owner, owner)
    end
end

local function TryStartFx(inst, owner)
	owner = owner
			or inst.components.equippable:IsEquipped() and inst.components.inventoryitem.owner
			or nil

	if owner == nil then
		return
	end

    if inst._vfx_fx_inst ~= nil and inst._vfx_fx_inst.entity:GetParent() ~= owner then
        inst._vfx_fx_inst:Remove()
        inst._vfx_fx_inst = nil
    end

    if inst._vfx_fx_inst == nil then
        inst._vfx_fx_inst = SpawnPrefab("pocketwatch_weapon_fx")
        inst._vfx_fx_inst.entity:AddFollower()
        inst._vfx_fx_inst.entity:SetParent(owner.entity)
        inst._vfx_fx_inst.Follower:FollowSymbol(owner.GUID, "swap_object", 15, 70, 0)
    end
end

local function StopFx(inst)
    if inst._vfx_fx_inst ~= nil then
        inst._vfx_fx_inst:Remove()
        inst._vfx_fx_inst = nil
    end
end

local function OnIsNightmareWild(inst, isnightmarewild)
	local owner = inst.components.inventoryitem.owner

	if owner == nil then
		return
	end

    if owner ~= nil and isnightmarewild and owner.components.areaaware:CurrentlyInTag("Nightmare") and not owner:HasTag("controlled") then
        inst:DoTaskInTime(10, function()
            if owner.SwitchControlled ~= nil then
                owner.components.talker:Say(GetString(owner, "ANNOUNCE_ISNIGHTMAREWILD"))
                owner.SwitchControlled(owner, true)
                TryStartFx(inst, owner)
            end
        end)
    else
        if owner.SwitchControlled ~= nil and owner:HasTag("controlled") then
            owner.SwitchControlled(owner, false)
            StopFx(inst)
        end
    end
end

local function OnEquip(inst, owner)
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
	owner.AnimState:OverrideSymbol("swap_object", "swap_tokijin" , "swap_tokijin")

    if TheWorld:HasTag("cave") then
        OnIsNightmareWild(inst, TheWorld.state.isnightmarewild)
    end

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

    inst:DoTaskInTime(10, function()
        if owner.SwitchControlled ~= nil and owner.components.kenjutsuka:GetKenjutsuLevel() < 10 then
            inst.components.equippable.dapperness = TUNING.CRAZINESS_MED
            owner.SwitchControlled(owner, true)
            TryStartFx(inst, owner)
        end
    end)
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

    if owner.SwitchControlled ~= nil then
        inst.components.equippable.dapperness = 0
        owner.SwitchControlled(owner, false)
        StopFx(inst)
    end
end

local function OnPocket(inst, owner)
    if owner ~= nil and not owner:HasTag("notshowscabbard") and owner:HasTag("player") then
        owner.AnimState:OverrideSymbol("swap_body_tall", "sc_tokijin", "tail")
    end
end

local function GetStatus(inst, viewer)
    if inst.swirl then
        return "RESENTMENT"
    end
end

local function OnHauntFn(inst, haunter)
    if math.random() <= TUNING.HAUNT_CHANCE_ALWAYS then
        Launch(inst, haunter, TUNING.LAUNCH_SPEED_SMALL)
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_TINY

        if inst.components.inventoryitem ~= nil and inst.components.inventoryitem.is_landed then
            inst.components.inventoryitem:SetLanded(false, true)
        end

        if inst.swirl == nil then
            inst.swirl = SpawnPrefab("shadow_chester_swirl_fx")
            inst.swirl.entity:SetParent(inst.entity)
        end

        return true
    end
    return false
end

local function OnPickupFn(inst, picker, src_pos)
    if inst.swirl ~= nil then
        inst.swirl.ReleaseSwirl(inst or picker)
    end

	if inst.components.sanityaura ~= nil then
		inst:RemoveComponent("sanityaura")
	end

    if inst.m_shadowhand_fx ~= nil then
        inst.m_shadowhand_fx:ListenForEvent("animover", inst.m_shadowhand_fx.Remove)
    end
end

local function OnDropped(inst)
    if inst.components.sanityaura == nil then
        inst:AddComponent("sanityaura")
        inst.components.sanityaura.aura = -TUNING.SANITYAURA_SMALL
        inst.components.sanityaura.max_distsq = TUNING.VOIDCLOTH_UMBRELLA_DOME_RADIUS * TUNING.VOIDCLOTH_UMBRELLA_DOME_RADIUS
    end

    local fused_shadeling_spawn_fx = SpawnPrefab("fused_shadeling_spawn_fx")
    fused_shadeling_spawn_fx.entity:AddFollower()
    fused_shadeling_spawn_fx.Follower:FollowSymbol(inst.GUID)

    local dreadstone_spawn_fx = SpawnPrefab("dreadstone_spawn_fx")
    dreadstone_spawn_fx.entity:AddFollower()
    dreadstone_spawn_fx.Follower:FollowSymbol(inst.GUID)

    if inst.m_shadowhand_fx == nil then
        inst.m_shadowhand_fx = SpawnPrefab("m_shadowhand_fx")
        inst.m_shadowhand_fx.entity:SetParent(inst.entity)
    end
end

-- m_shadowhand_fx
-- willow_shadow_fire_explode
local CANT_TAGS = {"FX", "NOCLICK", "INLIMBO"}
local function SpawnFxTask(inst)
    if not inst.components.inventoryitem:IsHeld() then
        local fused_shadeling_spawn_fx = SpawnPrefab("fused_shadeling_spawn_fx")
        fused_shadeling_spawn_fx.entity:AddFollower()
        fused_shadeling_spawn_fx.Follower:FollowSymbol(inst.GUID)

        local dreadstone_spawn_fx = SpawnPrefab("dreadstone_spawn_fx")
        dreadstone_spawn_fx.entity:AddFollower()
        dreadstone_spawn_fx.Follower:FollowSymbol(inst.GUID)

        local x, y, z = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, 4, nil, CANT_TAGS)
        for k, v in pairs(ents) do
            if v:HasTag("smallcreature") then
                local sanity_lower = SpawnPrefab("sanity_lower")
                local x, y, z = v.Transform:GetWorldPosition()
                sanity_lower.Transform:SetPosition(x,y,z)
                if v.components.health ~= nil then
                    v.components.health:Kill()
                end
            end
        end

        if inst.entity:IsAwake() then
            inst.spawn_fx_task = inst:DoTaskInTime(4+math.random()*10, SpawnFxTask)
        end
    end
end

local function OnEntityWake(inst)
    if inst.spawn_fx_task == nil then
        inst.spawn_fx_task = inst:DoTaskInTime(4+math.random()*10, SpawnFxTask)
    end
end

local function OnRemoveEntity(inst)
    if inst.spawn_fx_task ~= nil then
        inst.spawn_fx_task:Cancel()
        inst.spawn_fx_task = nil
    end
    if inst.swirl ~= nil then
        inst.swirl.ReleaseSwirl(inst)
    end
    if inst.m_shadowhand_fx ~= nil then
        inst.m_shadowhand_fx.Release(inst)
    end
    StopFx(inst)
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
    inst:AddTag("onikiba")

    --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

    local swap_data = {sym_build = "swap_tokijin", bank = "tokijin"}
    MakeInventoryFloatable(inst, "med", nil, {1.0, 0.5, 1.0}, true, -13, swap_data)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(0)

    inst:AddComponent("hauntable")
    inst.components.hauntable.cooldown = TUNING.HAUNT_COOLDOWN_SMALL
    inst.components.hauntable:SetOnHauntFn(OnHauntFn)

    inst:AddComponent("damagetypebonus")
    inst.components.damagetypebonus:AddBonus("shadow_aligned", inst, TUNING.WEAPONS_LUNARPLANT_VS_SHADOW_BONUS * 1.5)
    inst.components.damagetypebonus:AddBonus("lunar_aligned", inst, TUNING.WEAPONS_LUNARPLANT_VS_SHADOW_BONUS * 1.5)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.TOKIJIN_DAMAGE)
    inst.components.weapon:SetRange(1.6, 1.8)
    inst.components.weapon:SetOnAttack(OnAttack)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.canonlygoinpocket = true
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
    inst.components.inventoryitem:SetOnPickupFn(OnPickupFn)

    -- inst:AddComponent("finiteuses")
    -- inst.components.finiteuses:SetMaxUses(TUNING.KATANA.USES)
    -- inst.components.finiteuses:SetUses(TUNING.KATANA.USES)
    -- inst.components.finiteuses:SetOnFinished(OnFinished)

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
    inst.components.equippable:SetOnPocket(OnPocket)
    inst.components.equippable.is_magic_dapperness = true

    inst.OnEntityWake = OnEntityWake
    inst.OnRemoveEntity = OnRemoveEntity

    if TheWorld:HasTag("cave") then
        inst:WatchWorldState("isnightmarewild", OnIsNightmareWild)
        OnIsNightmareWild(inst, TheWorld.state.isnightmarewild)
    end

    return inst
end

return Prefab("tokijin", fn, assets, prefabs)
