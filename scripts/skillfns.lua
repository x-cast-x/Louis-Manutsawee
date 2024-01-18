local skilltime = .05

local function _SkillRemove(inst)
    inst.components.skillreleaser:SkillRemove()

    inst.mafterskillndm = nil
    inst.inspskill = nil
    inst.components.combat:SetRange(inst._range)
    inst.components.combat:EnableAreaDamage(false)
    inst.AnimState:SetDeltaTimeMultiplier(1)
    inst:DoTaskInTime(.3, function()
        inst.components.talker:Say("I don't wanna do this.")
    end)
end

local function CancelSkill(inst)
    inst.sg:GoToState("idle")
    _SkillRemove(inst)
end

local Ichimonji = function(inst, target, weapon)
    inst.components.skillreleaser:CanUseSkill(target)

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
        if inst.mindpower >= 5 then
            inst.mindpower = (inst.mindpower - 2)
            inst.doubleichimonjistart = true
        end
    end

    inst:DoTaskInTime(skilltime, function()
        inst.skill_target = target
        inst.sg:GoToState("ichimonji", inst.skill_target)
    end)

    if inst.doubleichimonjistart then
        inst:DoTaskInTime(1, function()
            if weapon ~= nil then
                inst.skill_target = target
                inst.sg:GoToState("ichimonji", inst.skill_target)
            end
        end)
    end

    inst.mindpower = (inst.mindpower-3)
    inst.components.timer:StartTimer("ichimonji", M_CONFIG.SKILL1_COOLDOWN)

    inst:RemoveTag("ichimonji")
end

local Flip = function(inst, target, weapon)
    inst.components.skillreleaser:CanUseSkill(target)
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
            if weapon ~= nil then
                inst.skill_target = target
                inst.sg:GoToState("habakiri", inst.skill_target)
                M_Util.GroundPoundFx(inst, .6)
            end
        end)
    else
        inst:DoTaskInTime(skilltime, function()
            inst.skill_target = target
            inst.sg:GoToState("flip", inst.skill_target)
            M_Util.GroundPoundFx(inst, .6)
        end)
    end

    inst.mindpower = (inst.mindpower - 4)
    inst.components.timer:StartTimer("flip", M_CONFIG.FLIP_COOLDOWN)

    inst:RemoveTag("flip")
end

local Thrust = function(inst, target, weapon)
    inst.components.skillreleaser:CanUseSkill(target)
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
local Isshin = function(inst, target, weapon)
        inst.components.skillreleaser:CanUseSkill(target)

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
        M_Util.GroundPoundFx(inst, 0.6)
        M_Util.SlashFx(inst, target, 3, "shadowstrike_slash_fx")
        inst.inspskill = true
        inst.skill_target = target
        inst.sg:GoToState("monemind", inst.skill_target)

        inst:DoTaskInTime(.6, function()
            M_Util.GroundPoundFx(inst, .8)
            M_Util.SlashFx(inst, target, 4, "wanda_attack_shadowweapon_old_fx")
            M_Util.AoeAttack(inst, 1, 6.5)
        end)

        inst:DoTaskInTime(.7, function()
            M_Util.SlashFx(inst, inst, 3, "wanda_attack_shadowweapon_normal_fx")
        end)

        inst:DoTaskInTime(.8, function()
            M_Util.GroundPoundFx(inst, .8)
            M_Util.SlashFx(inst, target, 3.5, "wanda_attack_shadowweapon_old_fx")
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
        inst.components.timer:StartTimer("isshin", M_CONFIG.SKILL2_COOLDOWN)

        inst:RemoveTag("isshin")
    end)
end

local HeavenlyStrike = function(inst, target)
    inst.components.skillreleaser:CanUseSkill(target)

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

        M_Util.AddFollowerFx(inst, "mossling_spin_fx")
        M_Util.AddFollowerFx(inst, "electricchargedfx")

        M_Util.GroundPoundFx(inst, .8)
        M_Util.SlashFx(inst, inst, 3, "shadowstrike_slash_fx")
        M_Util.AoeAttack(inst, 1, 6.5)

        inst:DoTaskInTime(.2, function()
            M_Util.AoeAttack(inst, 2.5, 6.5)
            M_Util.SlashFx(inst, inst, 3, "shadowstrike_slash2_fx")
            M_Util.GroundPoundFx(inst, .8)
        end)

        inst:DoTaskInTime(.3, function()
            M_Util.AoeAttack(inst, 4, 6.5)
            M_Util.SlashFx(inst, inst, 3, "shadowstrike_slash_fx")
            M_Util.GroundPoundFx(inst, .8)
        end)

        inst.mindpower = (inst.mindpower - 5)
        inst.components.timer:StartTimer("heavenlystrike", M_CONFIG.SKILL2_COOLDOWN - 30)

        inst:RemoveTag("heavenlystrike")
    end)
end

local Ryusen = function(inst, target)
    inst.components.skillreleaser:CanUseSkill(target)

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

        inst:RemoveTag("ryusen")
    end)
end

local Susanoo = function(inst, target, weapon)
    inst.components.skillreleaser:CanUseSkill(target)

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
            M_Util.SlashFx(inst, inst, "fence_rotator_fx", 4)
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

        inst.mindpower = (inst.mindpower - 10)
        inst.components.timer:StartTimer("skillT3cd", M_CONFIG.SKILL3_COOLDOWN)

        inst:RemoveTag("susanoo")
    end)
end

-- 苍龙破
local Soryuha = function(inst, target, weapon)

end

return {
    Ichimonji = Ichimonji,
    Flip = Flip,
    Thrust = Thrust,
    Isshin = Isshin,
    HeavenlyStrike = HeavenlyStrike,
    Ryusen = Ryusen,
    Susanoo = Susanoo,
    Soryuha = Soryuha,
}
