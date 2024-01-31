local MakeKatana = require "prefabs/katana_def"

local shockeffect = nil
local function OnIsRaining(inst, israining)
    if israining then
        shockeffect = true
    else
        shockeffect = false
    end
end

local onattack_common = M_Util.OnAttackCommonFn

local function hitokiri_onattack(inst, owner, target)
    if target ~= nil and target:IsValid() then
        onattack_common(inst, owner, target)

        if owner.components.health ~= nil and owner.components.health:GetPercent() < 1 and not (target:HasTag("wall") or target:HasTag("engineering")) then
            owner.components.health:DoDelta(TUNING.BATBAT_DRAIN, false, "true_hitokiri")
        end
    end
end

local function shirasaya_onattack(inst, owner, target)
    if target ~= nil and target:IsValid() then
        onattack_common(inst, owner, target)

        local hitsparks_fx = SpawnPrefab("brilliance_projectile_blast_fx")
        hitsparks_fx.Transform:SetPosition(target:GetPosition():Get())

        if inst.IsShadow(target) then
            if target.components.combat ~= nil then
                target.components.combat:GetAttacked(owner, inst.components.weapon.damage * .5)
            end
        end
    end
end

local function raikiri_onattack(inst, owner, target)
    if target ~= nil and target:IsValid() then
        onattack_common(inst, owner, target)

        local electricchargedfx = SpawnPrefab("electricchargedfx")
        electricchargedfx:SetTarget(target)

        if shockeffect then
            local electrichitsparks = SpawnPrefab("electrichitsparks")
            if electrichitsparks ~= nil and target ~= nil and target:IsValid() and owner ~= nil and owner:IsValid() then
                electrichitsparks:AlignToTarget(target, owner, true)
                if target.components.combat ~= nil then
                    target.components.combat:GetAttacked(owner, inst.components.weapon.damage*.8)
                end
            end
        end
    end
end

local function koshirae_onattack(inst, owner, target)
    if target ~= nil and target:IsValid() then
        onattack_common(inst, owner, target)

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
end

local function raikiri_master_postinit(inst)
    inst:AddComponent("damagetypebonus")
    inst.components.damagetypebonus:AddBonus("shadow_aligned", inst, TUNING.WEAPONS_LUNARPLANT_VS_SHADOW_BONUS)
    inst.components.damagetypebonus:AddBonus("lunar_aligned", inst, TUNING.WEAPONS_LUNARPLANT_VS_SHADOW_BONUS * 1.5)

    inst:WatchWorldState("israining", OnIsRaining)
    OnIsRaining(inst, TheWorld.state.israining)
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

local katana = {}
for k,v in pairs(katana_data) do
    local data = {
        name = "true_" .. k,
        onattack = v.onattack,
        common_postinit = v.common_postinit,
        master_postinit = v.master_postinit,
        damage = TUNING.KATANA.TRUE_DAMAGE
    }
    table.insert(katana, MakeKatana(data))
end

return unpack(katana)
