local MakeKatana = require "prefabs/katana_def"

local shockeffect = nil
local function OnIsRaining(inst, israining)
    if israining then
        shockeffect = true
    else
        shockeffect = false
    end
end

local function SpawnFxTask(inst)
    if inst.components.inventoryitem ~= nil and not inst.components.inventoryitem:IsHeld() then
        inst:FollwerFx("electricchargedfx")
        inst:FollwerFx("thunderbird_fx_charge_loop")
        if not inst:IsAsleep() then
            inst.spawn_fx_task = inst:DoTaskInTime(4+math.random()*10, SpawnFxTask)
        end
    end
end

local absorblightning = nil
local function OnEntityWake(inst)
    if inst.spawn_fx_task == nil and absorblightning then
        inst.spawn_fx_task = inst:DoTaskInTime(4+math.random()*10, SpawnFxTask)
    end
end

local function OnLightningStrike(inst)
    inst:SpawnPrefabInPos("electricchargedfx")
    inst:SpawnPrefabInPos("thunderbird_fx_charge_loop")

    if absorblightning then
        return
    end

    shockeffect = true
    absorblightning = true

    inst:SpawnPrefabInPos("thunderbird_fx_idle")

    OnEntityWake(inst)
end

local function hitokiri_onattack(inst, owner, target)
    if target ~= nil and target:IsValid() then
        if owner.components.health ~= nil and owner.components.health:GetPercent() < 1 and not (target:HasTag("wall") or target:HasTag("engineering")) then
            owner.components.health:DoDelta(TUNING.BATBAT_DRAIN, false, "true_hitokiri")
        end
    end
end

local function shirasaya_onattack(inst, owner, target)
    if target ~= nil and target:IsValid() then
        inst:SpawnPrefabInPos("brilliance_projectile_blast_fx")

        if inst.IsShadow(target) or inst.IsLunar(target) then
            if target.components.combat ~= nil then
                target.components.combat:GetAttacked(owner, inst.components.weapon.damage * .5)
            end
        end
    end
end

local function raikiri_onattack(inst, owner, target)
    if target ~= nil and target:IsValid() then
        local electricchargedfx = SpawnPrefab("electricchargedfx")
        electricchargedfx:SetTarget(target)

        if shockeffect then
            local electrichitsparks = SpawnPrefab("electrichitsparks")
            if electrichitsparks ~= nil and target ~= nil and target:IsValid() and owner ~= nil and owner:IsValid() then
                electrichitsparks:AlignToTarget(target, owner, true)
                if target.components.combat ~= nil then
                    local damage = absorblightning and 1.5 or .8
                    target.components.combat:GetAttacked(owner, inst.components.weapon.damage * damage)
                end
            end
        end
    end
end

local function koshirae_onattack(inst, owner, target)
    if target ~= nil and target:IsValid() then
        if target:HasTag("epic") and target.components.combat ~= nil then
            target.components.combat:GetAttacked(owner, inst.components.weapon.damage*.5)
        end
    end
end

local function hitokiri_common_postinit(inst)
    inst:AddTag("shadow_item")
    inst:AddTag("shadow")
end

local function hitokiri_master_postinit(inst)
    inst.components.equippable.is_magic_dapperness = true

    inst:AddComponent("damagetypebonus")
    inst.components.damagetypebonus:AddBonus("shadow_aligned", inst, TUNING.WEAPONS_LUNARPLANT_VS_SHADOW_BONUS)
    inst.components.damagetypebonus:AddBonus("lunar_aligned", inst, TUNING.WEAPONS_LUNARPLANT_VS_SHADOW_BONUS * 1.5)
end

local function shirasaya_common_postinit(inst)

end

local function shirasaya_master_postinit(inst)
    inst:AddComponent("damagetypebonus")
    inst.components.damagetypebonus:AddBonus("shadow_aligned", inst, TUNING.WEAPONS_LUNARPLANT_VS_SHADOW_BONUS*2)
    inst.components.damagetypebonus:AddBonus("lunar_aligned", inst, TUNING.WEAPONS_LUNARPLANT_VS_SHADOW_BONUS*1.5)
end

local function raikiri_common_postinit(inst)
    inst:AddTag("lightningcutter")
    inst:AddTag("lightningrod")
end

local function raikiri_master_postinit(inst)
    inst:AddComponent("damagetypebonus")
    inst.components.damagetypebonus:AddBonus("shadow_aligned", inst, TUNING.WEAPONS_LUNARPLANT_VS_SHADOW_BONUS)
    inst.components.damagetypebonus:AddBonus("lunar_aligned", inst, TUNING.WEAPONS_LUNARPLANT_VS_SHADOW_BONUS * 1.5)

    inst:WatchWorldState("israining", OnIsRaining)
    OnIsRaining(inst, TheWorld.state.israining)

    inst:ListenForEvent("lightningstrike", OnLightningStrike)

    inst.OnLightningStrike = OnLightningStrike
    inst.OnEntityWake = OnEntityWake
end

local function koshirae_common_postinit(inst)

end

local function koshirae_master_postinit(inst)
    inst:AddComponent("damagetypebonus")
    inst.components.damagetypebonus:AddBonus("shadow_aligned", inst, TUNING.WEAPONS_LUNARPLANT_VS_SHADOW_BONUS)
    inst.components.damagetypebonus:AddBonus("lunar_aligned", inst, TUNING.WEAPONS_LUNARPLANT_VS_SHADOW_BONUS * 1.5)
    inst.components.damagetypebonus:AddBonus("epic", inst, TUNING.WEAPONS_LUNARPLANT_VS_SHADOW_BONUS)
end

local katana_data = {
    hitokiri = {
        onattack = hitokiri_onattack,
        common_postinit = hitokiri_common_postinit,
        master_postinit = hitokiri_master_postinit,
    },
    shirasaya = {
        onattack = shirasaya_onattack,
        common_postinit = shirasaya_common_postinit,
        master_postinit = shirasaya_master_postinit,
    },
    raikiri = {
        onattack = raikiri_onattack,
        common_postinit = raikiri_common_postinit,
        master_postinit = raikiri_master_postinit,
    },
    koshirae = {
        onattack = koshirae_onattack,
        common_postinit = koshirae_common_postinit,
        master_postinit = koshirae_master_postinit,
    },
}

local rets = {}
for k,v in pairs(katana_data) do
    local data = {
        name = "true_" .. k,
        build = k,
        onattack = v.onattack,
        common_postinit = v.common_postinit,
        master_postinit = v.master_postinit,
        damage = TUNING.KATANA.TRUE_DAMAGE
    }
    table.insert(rets, MakeKatana(data))
end

return unpack(rets)
