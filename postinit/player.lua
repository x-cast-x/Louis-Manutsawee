local AddPlayerPostInit = AddPlayerPostInit
GLOBAL.setfenv(1, GLOBAL)

-- local skill_data = require "postinit/skill_data"

local blockcount = 0
local skilltime = .05

local skilltags = {
    "michimonji",
    "mflipskill",
    "mthrustskill",
    "misshin",
    "heavenlystrike",
    "ryusen",
    "susanoo",
    "soryuha",
}

local function SkillRemove(inst)
    for _, tag in pairs(skilltags) do
        if inst:HasTag(tag) then
            inst:RemoveTag(tag)
        end
    end

    inst.mafterskillndm = nil
    inst.inspskill = nil
    inst.components.combat:SetRange(inst._range)
    inst.components.combat:EnableAreaDamage(false)
    inst.AnimState:SetDeltaTimeMultiplier(1)
    inst:DoTaskInTime(.3, function()
        inst.components.talker:Say("I don't wanna do this.")
    end)
end

-- M_Util.SlashFx(inst, inst, 3, "shadowstrike_slash_fx")
local function SpawnSlashFx1(inst, target)
    local effects = SpawnPrefab("shadowstrike_slash_fx")
    effects.Transform:SetScale(3, 3, 3)
    effects.Transform:SetPosition(target:GetPosition():Get())
    inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
    inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe")
end

-- SlashFx(inst, inst, 3, "shadowstrike_slash2_fx")
local function SpawnSlashFx2(inst, target)
    local effects2 = SpawnPrefab("shadowstrike_slash2_fx")
    effects2.Transform:SetScale(3, 3, 3)
    effects2.Transform:SetPosition(target:GetPosition():Get())
    inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
    inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
end

-- SlashFx(inst, inst, 1.6, "shadowstrike_slash_fx")
local function SpawnSlashFx3(inst, target)
    local effects = SpawnPrefab("shadowstrike_slash_fx")
    effects.Transform:SetScale(1.6, 1.6, 1.6)
    effects.Transform:SetPosition(target:GetPosition():Get())
    inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
    inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe")
end

-- M_Util.SlashFx(inst, inst, scale, "wanda_attack_shadowweapon_old_fx")
local function SpawnSlashFx4(inst, target, scale)
    local effects = SpawnPrefab("wanda_attack_shadowweapon_old_fx")
    effects.Transform:SetScale(scale, scale, scale)
    effects.Transform:SetPosition(target:GetPosition():Get())
    inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
    inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe")
end

-- SlashFx(inst, inst, scale, "wanda_attack_shadowweapon_normal_fx")
local function SpawnSlashFx5(inst, target, scale)
    local effects = SpawnPrefab("wanda_attack_shadowweapon_normal_fx")
    effects.Transform:SetScale(scale, scale, scale)
    effects.Transform:SetPosition(target:GetPosition():Get())
    inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
    inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe")
end

-- SlashFx(inst, inst, scale, "fence_rotator_fx")
local function SpawnSlashFx6(inst, target, scale)
    local effects = SpawnPrefab("fence_rotator_fx")
    effects.Transform:SetScale(scale, scale, scale)
    effects.Transform:SetPosition(target:GetPosition():Get())
    inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
    inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe")
end

-- M_Util.GroundPoundFx(inst, 0.6)
local function GroundPoundFx(inst, .6)
    local x, y, z = inst.Transform:GetWorldPosition()
    local fx = SpawnPrefab("groundpoundring_fx")
    fx.Transform:SetScale(.6, .6, .6)
    fx.Transform:SetPosition(x, y, z)
end

local function M_Util.GroundPoundFx(inst, .8)
    local x, y, z = inst.Transform:GetWorldPosition()
    local fx = SpawnPrefab("groundpoundring_fx")
    fx.Transform:SetScale(.8, .8, .8)
    fx.Transform:SetPosition(x, y, z)
end

local function SpawnGroundPoundFx3(inst, target)
    local effects = SpawnPrefab("groundpoundring_fx")
    effects.Transform:SetScale(.7, .7, .7)
    effects.Transform:SetPosition(target:GetPosition():Get())
end

local function AoeAttack(inst, target, mtpdmg, atkrange)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, atkrange, nil)
    local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

    for k,v in pairs(ents) do
        if (v and v:HasTag("bird")) then
            v.sg:GoToState("stunned")
        end

        if v and v:IsValid() and v.components.health ~= nil and v.components.combat ~= nil and not v.components.health:IsDead() then
            if not (v:HasTag("player") or v:HasTag("INLIMBO") or v:HasTag("structure") or v:HasTag("companion") or v:HasTag("abigial") or v:HasTag("wall")) then
                if weapon ~= nil then
                    v.components.combat:GetAttacked(inst, weapon.components.weapon.damage*mtpdmg)
                end
                if v.components.freezable ~= nil then
                    v.components.freezable:SpawnShatterFX()
                end
            end
        elseif v and
            v:HasTag("tree") or
                v:HasTag("stump") and not v:HasTag("structure") then
            if v.components.workable ~= nil then
                v.components.workable:WorkedBy(inst, 10)
            end
        end
    end
end

local function CanUseSkill(inst, target)
    if (target:HasTag("prey") or target:HasTag("bird") or target:HasTag("buzzard") or target:HasTag("butterfly")) and not target:HasTag("hostile") then
        inst.mcanskill = true
    else
        inst.mcanskill = nil
    end
end

local function CancelSkill(inst)
    inst.sg:GoToState("idle")
    SkillRemove(inst)
end

local Michimonji_Skill = function(inst, target, weapon)
    CanUseSkill(inst, target)

    if inst.mcanskill then
        CancelSkill(inst)
        return
    end

    if inst.mafterskillndm ~= nil then
        inst.mafterskillndm:Cancel()
        inst.mafterskillndm = nil
    end

    inst.inspskill = true

    if weapon.wpstatus then
        skilltime = .3
        if inst.mindpower >=5 then
            inst.mindpower = (inst.mindpower-2)
            inst.doubleichimonjistart = true
        end
    end

    inst:DoTaskInTime(skilltime, function()
        inst.skill_target = target
        inst.sg:GoToState("michimonji",inst.skill_target)
    end)

    if inst.doubleichimonjistart then
        inst:DoTaskInTime(1, function()
            if inst.mafterskillndm ~= nil then
                inst.mafterskillndm:Cancel()
                inst.mafterskillndm = nil
            end

            if weapon ~= nil then
                inst.skill_target = target
                inst.sg:GoToState("michimonji", inst.skill_target)
            end
        end)
    end

    inst.mindpower = (inst.mindpower-3)
    inst.components.timer:StartTimer("skill1cd", M_CONFIG.SKILL1_COOLDOWN)

    inst:RemoveTag("michimonji")
end

local Flip_Skill = function(inst, target, weapon)
    CanUseSkill(inst, target)
    skilltime = .1

    if inst.mcanskill then
        CancelSkill(inst)
        return
    end

    if inst.mafterskillndm ~= nil then
        inst.mafterskillndm:Cancel()
        inst.mafterskillndm = nil
    end

    if weapon.wpstatus then
        skilltime = .05
        inst:DoTaskInTime(skilltime, function()
            if inst.mafterskillndm ~= nil then
                inst.mafterskillndm:Cancel()
                inst.mafterskillndm = nil
            end

            if weapon ~= nil then
                inst.skill_target = target
                inst.sg:GoToState("mhabakiri", inst.skill_target)
                M_Util.GroundPoundFx(inst, .6)
            end
        end)
    else
        inst:DoTaskInTime(skilltime, function()
            inst.skill_target = target
            inst.sg:GoToState("mflipskill", inst.skill_target)
            M_Util.GroundPoundFx(inst, .6)
        end)
    end

    inst.mindpower = (inst.mindpower-4)
    inst.components.timer:StartTimer("skill2cd", M_CONFIG.SKILL2_COOLDOWN)

    inst:RemoveTag("mflipskill")
end

local Thrust_Skill = function(inst, target, weapon)
    CanUseSkill(inst, target)
    skilltime = .1

    if inst.mcanskill then
        CancelSkill(inst)
        return
    end

    if inst.mafterskillndm ~= nil then
        inst.mafterskillndm:Cancel()
        inst.mafterskillndm = nil
    end

    if weapon.wpstatus then
        skilltime = .05
        inst:DoTaskInTime(skilltime, function()
            if inst.mafterskillndm ~= nil then
                inst.mafterskillndm:Cancel()
                inst.mafterskillndm = nil
            end

            if weapon ~= nil then
                inst.skill_target = target
                inst.sg:GoToState("mthrustskill", inst.skill_target)
                M_Util.GroundPoundFx(inst, .6)

                inst:DoTaskInTime(.7, function()
                    inst:PushEvent("heavenlystrike")
                    if weapon.components.spellcaster ~= nil then
                        weapon.components.spellcaster:CastSpell(inst)
                        local fx = SpawnPrefab("sparks")
                        fx.Transform:SetPosition(inst:GetPosition():Get())
                    end
                end)

                inst:DoTaskInTime(.9, function()
                    M_Util.SlashFx(inst, inst, 3, "shadowstrike_slash_fx")
                    M_Util.AoeAttack(inst, 1,6.5)
                    inst.components.combat:SetRange(inst._range)
                    inst.components.talker:Say(STRINGS.MANUTSAWEESKILLSPEECH.SKILL3ATTACK, 2, true)
                    local fx = SpawnPrefab("groundpoundring_fx")
                    fx.Transform:SetScale(.8, .8, .8)
                    fx.Transform:SetPosition(inst:GetPosition():Get())
                end)
            end
        end)
    else
        inst:DoTaskInTime(skilltime, function()
            inst.skill_target = target
            inst.sg:GoToState("mthrustskill", inst.skill_target)
            M_Util.GroundPoundFx(inst, .6)
        end)
    end

    inst.mindpower = (inst.mindpower-4)
    inst.components.timer:StartTimer("skill3cd", M_CONFIG.SKILL3_COOLDOWN)

    inst:RemoveTag("mthrustskill")
end

-- Isshin 一心
local Isshin_Skill = function(inst, target, weapon)
        CanUseSkill(inst, target)

        if inst.mcanskill then
            CancelSkill(inst)
            return
        end

        if inst.mafterskillndm ~= nil then
            inst.mafterskillndm:Cancel()
            inst.mafterskillndm = nil
        end

        inst:DoTaskInTime(.1, function()
        inst.components.talker:Say(STRINGS.MANUTSAWEESKILLSPEECH.SKILL4ATTACK, 2, true)
        M_Util.GroundPoundFx(inst, .6)
        SpawnSlashFx1(inst, target)
        inst.inspskill = true
        inst.skill_target = target
        inst.sg:GoToState("monemind", inst.skill_target)

        inst:DoTaskInTime(.6, function()
            M_Util.GroundPoundFx(inst, .8)
            SpawnSlashFx4(inst, inst, 4)
            M_Util.AoeAttack(inst, 1, 6.5)
        end)

        inst:DoTaskInTime(.7, function()
            SpawnSlashFx5(inst, inst, 3)
        end)

        inst:DoTaskInTime(.8, function()
            M_Util.GroundPoundFx(inst, .8)
            SpawnSlashFx4(inst, inst, 3.5)
            M_Util.AoeAttack(inst, 1, 6.5)
        end)

        inst:DoTaskInTime(1, function()
            M_Util.GroundPoundFx(inst, .6)
            SpawnSlashFx5(inst, inst, 4)
        end)

        inst:DoTaskInTime(1.1, function()
            M_Util.GroundPoundFx(inst, .8)
            SpawnSlashFx4(inst, inst, 4)
            M_Util.AoeAttack(inst, 1, 6.5)
        end)

        inst:DoTaskInTime(1.2, function()
            SpawnSlashFx5(inst, inst, 3)
            M_Util.AoeAttack(inst, 1, 6.5)
        end)

        inst:DoTaskInTime(1.4, function()
            M_Util.GroundPoundFx(inst, .8)
            SpawnSlashFx4(inst, inst, 3.5)
            M_Util.AoeAttack(inst, 1, 6.5)
        end)

        inst:DoTaskInTime(1.5, function()
            M_Util.GroundPoundFx(inst, .6)
            SpawnSlashFx5(inst, inst, 4)
        end)

        inst:DoTaskInTime(1.6, function()
            M_Util.GroundPoundFx(inst, .8)
            SpawnSlashFx4(inst, inst, 4)
        end)

        inst:DoTaskInTime(1.8, function()
            SpawnSlashFx5(inst, inst, 3)
            M_Util.AoeAttack(inst, 1, 6.5)
        end)

        inst:DoTaskInTime(1.9, function()
            M_Util.GroundPoundFx(inst, .8)
            SpawnSlashFx4(inst, inst, 3.5)
            M_Util.AoeAttack(inst, 1,6)
            inst.components.playercontroller:Enable(true)
            inst.inspskill = nil
            inst:PushEvent("heavenlystrike")
            if weapon ~= nil and weapon.components.spellcaster ~= nil then
                weapon.components.spellcaster:CastSpell(inst)
                local fx = SpawnPrefab("sparks")
                fx.Transform:SetPosition(inst:GetPosition():Get())
            end
        end)

        inst:DoTaskInTime(2.1, function()
            M_Util.GroundPoundFx(inst, .6)
            M_Util.AoeAttack(inst, 1, 4)
            inst.components.combat:SetRange(inst._range)
        end)

        inst.mindpower = (inst.mindpower-7)
        inst.components.timer:StartTimer("skillT2cd", M_CONFIG.SKILL2_COOLDOWN)

        inst:RemoveTag("misshin")
    end)
end

local HeavenlyStrike_Skill = function(inst, target)
    CanUseSkill(inst, target)

    if inst.mcanskill then
        CancelSkill(inst)
        return
    end

    if inst.mafterskillndm ~= nil then
        inst.mafterskillndm:Cancel()
        inst.mafterskillndm = nil
    end

    inst:DoTaskInTime(.1, function()
        inst.components.talker:Say(STRINGS.MANUTSAWEESKILLSPEECH.SKILL5ATTACK, 2, true)
    end)

    inst.sg:AddStateTag("skilling")

    inst:DoTaskInTime(.3, function()
        inst:PushEvent("heavenlystrike")

        inst.mindpower = (inst.mindpower-5)
        inst.components.timer:StartTimer("skillT2cd", M_CONFIG.SKILL2_COOLDOWN - 30)

        local mossling_spin_fx = SpawnPrefab("mossling_spin_fx")
        mossling_spin_fx.entity:AddFollower()
        mossling_spin_fx.Follower:FollowSymbol(inst.GUID, "swap_body", 0, 0, 0)

        local electricchargedfx = SpawnPrefab("electricchargedfx")
        electricchargedfx.entity:AddFollower()
        electricchargedfx.Follower:FollowSymbol(inst.GUID, "swap_body", 0, 0, 0)

        inst:RemoveTag("heavenlystrike")

        local fx = SpawnPrefab("groundpoundring_fx")
        fx.Transform:SetScale(.8, .8, .8)
        fx.Transform:SetPosition(inst:GetPosition():Get())

        M_Util.SlashFx(inst, inst, 3, "shadowstrike_slash_fx")
        M_Util.AoeAttack(inst, 1,6.5)

        inst:DoTaskInTime(.2, function()
            M_Util.AoeAttack(inst, 2.5, 6.5)
            SpawnSlashFx2(inst, inst)
            local fx = SpawnPrefab("groundpoundring_fx")
            fx.Transform:SetScale(.8, .8, .8)
            fx.Transform:SetPosition(inst:GetPosition():Get())
        end)

        inst:DoTaskInTime(.3, function()
            M_Util.AoeAttack(inst, 4, 6.5)
            M_Util.SlashFx(inst, inst, 3, "shadowstrike_slash_fx")
            local fx = SpawnPrefab("groundpoundring_fx")
            fx.Transform:SetScale(.8, .8, .8)
            fx.Transform:SetPosition(inst:GetPosition():Get())
        end)
    end)
end

local Ryusen_Skill = function(inst, target)
    CanUseSkill(inst, target)

    if inst.mcanskill then
        CancelSkill(inst)
        return
    end

    if inst.mafterskillndm ~= nil then
        inst.mafterskillndm:Cancel()
        inst.mafterskillndm = nil
    end

    inst:DoTaskInTime(.1, function()
        inst.components.talker:Say(STRINGS.MANUTSAWEESKILLSPEECH.SKILL6ATTACK, 2, true)
        inst.skill_target = target
        inst.sg:GoToState("ryusen", inst.skill_target)

        inst.mindpower = (inst.mindpower - 8)
        inst.components.timer:StartTimer("skillT3cd", M_CONFIG.SKILL3_COOLDOWN - 60)
        inst:RemoveTag("ryusen")

        inst:DoTaskInTime(.2, function()
            SpawnSlashFx4(inst, inst.skill_target, 2)
        end)

        inst:DoTaskInTime(.4, function()
            SpawnSlashFx5(inst, inst.skill_target, 2)
        end)

        inst:DoTaskInTime(.6, function()
            SpawnSlashFx4(inst, inst.skill_target, 2.5)
        end)

        inst:DoTaskInTime(.8, function()
            SpawnSlashFx5(inst, inst.skill_target, 2.5)
            SpawnGroundPoundFx3(inst, inst.skill_target)
        end)

        inst:DoTaskInTime(1, function()
            M_Util.GroundPoundFx(inst, .6)
        end)

        inst:DoTaskInTime(1.5, function()
            SpawnSlashFx1(inst, inst.skill_target)
            SpawnGroundPoundFx3(inst, inst.skill_target)
        end)
    end)
end

local Susanoo_Skill = function(inst, target, weapon)
    CanUseSkill(inst, target)

    if inst.mcanskill then
        CancelSkill(inst)
        return
    end

    if inst.mafterskillndm ~= nil then
        inst.mafterskillndm:Cancel()
        inst.mafterskillndm = nil
    end

    inst:DoTaskInTime(.1, function()
        inst.components.talker:Say(STRINGS.MANUTSAWEESKILLSPEECH.SKILL7ATTACK, 2, true)
        M_Util.GroundPoundFx(inst, .6)

        SpawnSlashFx1(inst, target)
        inst.inspskill = true
        inst.skill_target = target
        inst.sg:GoToState("monemind", inst.skill_target)

        inst:DoTaskInTime(.6, function()
            M_Util.GroundPoundFx(inst, .8)
            M_Util.SlashFx(inst, inst, "fence_rotator_fx",4)
            M_Util.AoeAttack(inst, 1,6.5)
        end)

        inst:DoTaskInTime(.7, function()
            M_Util.SlashFx(inst, inst, "fence_rotator_fx", 3)
        end)

        inst:DoTaskInTime(.8, function()
            M_Util.GroundPoundFx(inst, .8)
            M_Util.SlashFx(inst, inst, "fence_rotator_fx", 3.5)
            M_Util.AoeAttack(inst, 2, 6.5)
        end)

        inst:DoTaskInTime(.9, function()
            M_Util.SlashFx(inst, inst, "fence_rotator_fx", 2.5)
        end)

        inst:DoTaskInTime(1, function()
            M_Util.GroundPoundFx(inst, .6)
            M_Util.SlashFx(inst, inst, "fence_rotator_fx", 4)
        end)

        inst:DoTaskInTime(1.1, function()
            M_Util.GroundPoundFx(inst, .8)
            M_Util.SlashFx(inst, inst, "fence_rotator_fx", 4)
            M_Util.AoeAttack(inst, 1, 6.5)
        end)

        inst:DoTaskInTime(1.2, function()
            M_Util.SlashFx(inst, inst, "fence_rotator_fx", 3)
            M_Util.AoeAttack(inst, 2, 6.5)
        end)

        inst:DoTaskInTime(1.3, function()
            M_Util.SlashFx(inst, inst, "fence_rotator_fx", 2.5)
        end)

        inst:DoTaskInTime(1.4, function()
            M_Util.GroundPoundFx(inst, .8)
            M_Util.SlashFx(inst, inst, "fence_rotator_fx", 3.5)
            M_Util.AoeAttack(inst, 1, 6.5)
        end)

        inst:DoTaskInTime(1.5, function()
            M_Util.GroundPoundFx(inst, .6)
            M_Util.SlashFx(inst, inst, "fence_rotator_fx", 4)
        end)

        inst:DoTaskInTime(1.6, function()
            M_Util.GroundPoundFx(inst, .8)
            M_Util.SlashFx(inst, inst, "fence_rotator_fx", 4)
        end)

        inst:DoTaskInTime(1.7, function()
            M_Util.SlashFx(inst, inst, "fence_rotator_fx", 2.5)
        end)

        inst:DoTaskInTime(1.8, function()
            M_Util.SlashFx(inst, inst, "fence_rotator_fx", 3)
            M_Util.AoeAttack(inst, 2, 6.5)
        end)

        inst:DoTaskInTime(1.9, function()
            M_Util.GroundPoundFx(inst, .8)
            M_Util.SlashFx(inst, inst, "fence_rotator_fx", 3.5)
            M_Util.AoeAttack(inst, 1, 6)
            inst.components.playercontroller:Enable(true)
            inst.inspskill = nil
            inst:PushEvent("heavenlystrike")
            if weapon ~= nil and weapon.components.spellcaster ~= nil then
                weapon.components.spellcaster:CastSpell(inst)
            end
        end)

        inst:DoTaskInTime(2.1, function()
            M_Util.SlashFx(inst, inst, 3, "shadowstrike_slash_fx")
            M_Util.AoeAttack(inst, 2,4)
            inst.components.combat:SetRange(inst._range)
        end)

        inst.mindpower = (inst.mindpower-10)
        inst.components.timer:StartTimer("skillT3cd", M_CONFIG.SKILL3_COOLDOWN)

        inst:RemoveTag("susanoo")
    end)
end

local function postinit_fn(inst)
    if not (inst.prefab == "manutsawee") then
        return
    end

    if not TheWorld.ismastersim then
        return inst
    end

    local _GetAttacked = inst.components.combat.GetAttacked

    function inst.components.combat:GetAttacked(attacker, damage, weapon, stimuli, spdamage)
        if attacker == nil or damage == nil or (inst.components.sleeper ~= nil and inst.components.sleeper:IsAsleep()) or (inst.components.freezable and inst.components.freezable:IsFrozen()) then
            return _GetAttacked(self, attacker, damage, weapon, stimuli, spdamage)
        end
        if attacker ~= nil then
            inst:ForceFacePoint(attacker.Transform:GetWorldPosition())
        end

        local pweapon = self:GetWeapon()
        if pweapon ~= nil and (inst.mafterskillndm ~= nil and not inst.sg:HasStateTag("mdashing")) then
            inst.mafterskillndm = inst:DoTaskInTime(1.5, function()
                inst.mafterskillndm = nil
            end)
            if blockcount > 0 then
                blockcount = 0
                if inst.blockactive ~= nil then
                    inst.blockactive:Cancel()
                    inst.blockactive = nil
                end
                inst:PushEvent("heavenlystrike")
                if attacker.components.combat ~= nil then
                    --inst.components.combat:DoAttack(attacker)
                    M_Util.AoeAttack(inst, 2,3)
                    M_Util.GroundPoundFx(inst, .6)
                    SpawnSlashFx3(inst, attacker)
                    if inst.mafterskillndm ~= nil then
                        inst.mafterskillndm:Cancel()
                        inst.mafterskillndm = nil
                    end
                end
                return
            end
            inst:PushEvent("blockparry")
            blockcount = blockcount + 1
                if inst.blockactive ~= nil then
                    inst.blockactive:Cancel()
                    inst.blockactive = nil
                end
            inst.blockactive = inst:DoTaskInTime(3, function()
                blockcount = 0
            end)
            return
        end

        if inst.sg:HasStateTag("mdashing") or inst.inspskill ~= nil then
            local electricfx = SpawnPrefab("electricchargedfx")
            electricfx.Transform:SetScale(.7, .7, .7)
            electricfx.entity:AddFollower()
            electricfx.Follower:FollowSymbol(inst.GUID, "swap_body", 0, 0, 0)
        elseif inst.sg:HasStateTag("counteractive") then
            M_Util.GroundPoundFx(inst, .6)
            inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
            local sparks = SpawnPrefab("sparks")
            sparks.Transform:SetPosition(inst:GetPosition():Get())
            inst.skill_target = attacker
            inst.sg:GoToState("mcounterattack", inst.skill_target)
            inst.components.timer:StartTimer("skillcountercd", M_CONFIG.COUNTER_ATK_COOLDOWN)
        else
            _GetAttacked(self, attacker, damage, weapon, stimuli, spdamage)
        end
    end

    local Old_StartAttack = inst.components.combat.StartAttack
    inst.components.combat.StartAttack = function(self, ...)
        Old_StartAttack(self, ...)
        if self.target ~= nil then
            local target = self.target
            local weapon = self:GetWeapon()

            if weapon ~= nil and weapon.components.weapon ~= nil then
                if inst:HasTag("michimonji") then
                    Michimonji_Skill(inst, target, weapon)
                elseif inst:HasTag("mflipskill") then
                    Flip_Skill(inst, target, weapon)
                elseif inst:HasTag("mthrustskill") then
                    Thrust_Skill(inst, target, weapon)
                elseif inst:HasTag("misshin") then
                    Isshin_Skill(inst, target, weapon)
                elseif inst:HasTag("heavenlystrike") then
                    HeavenlyStrike_Skill(inst, target)
                elseif inst:HasTag("ryusen") then
                    Ryusen_Skill(inst, target)
                elseif inst:HasTag("susanoo") then
                    Susanoo_Skill(inst, target, weapon)
                elseif inst:HasTag("soryuha") then

                end
            end
        end
    end
end

AddPlayerPostInit(postinit_fn)
