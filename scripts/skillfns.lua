local skilltime = .05

local skill_data = {
    Ichimonji = {
        tag = "ichimonji",
        time = M_CONFIG.SKILL1_COOLDOWN,
        mindpower = 3,
        fn = function(inst, target, weapon)
            inst.inspskill = true

            if weapon.wpstatus then
                skilltime = .3
                if inst.components.kenjutsuka:GetMindpower() >= 5 then
                    inst.components.kenjutsuka:SetMindpower(inst.components.kenjutsuka:GetMindpower() - 2)
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
        end,
    },
    Flip = {
        tag = "flip",
        time = M_CONFIG.FLIP_COOLDOWN,
        mindpower = 4,
        fn = function(inst, target, weapon)
            skilltime = .1
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
        end
    },
    Thrust = {
        tag = "thrust",
        time = M_CONFIG.SKILL3_COOLDOWN,
        mindpower = 4,
        fn = function(inst, target, weapon)
            skilltime = .1
            if weapon.wpstatus then
                skilltime = .05
                inst:DoTaskInTime(skilltime, function()
                    if inst.mafterskillndm ~= nil then
                        inst.mafterskillndm:Cancel()
                        inst.mafterskillndm = nil
                    end
        
                    if weapon ~= nil then
                        inst.skill_target = target
                        inst.sg:GoToState("thrust", inst.skill_target)
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
                            inst.components.talker:Say(STRINGS.SKILL.SKILL3ATTACK, 2, true)
                            local fx = SpawnPrefab("groundpoundring_fx")
                            fx.Transform:SetScale(.8, .8, .8)
                            fx.Transform:SetPosition(inst:GetPosition():Get())
                        end)
                    end
                end)
            else
                inst:DoTaskInTime(skilltime, function()
                    inst.skill_target = target
                    inst.sg:GoToState("thrust", inst.skill_target)
                    M_Util.GroundPoundFx(inst, .6)
                end)
            end
        end
    },
    Isshin = {
        tag = "isshin",
        time = M_CONFIG.SKILL2_COOLDOWN,
        mindpower = 7,
        fn = function(inst, target, weapon)
            inst:DoTaskInTime(.1, function()
                inst.components.talker:Say(STRINGS.SKILL.SKILL4ATTACK, 2, true)
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
                    M_Util.SlashFx(inst, inst, "wanda_attack_shadowweapon_normal_fx", 4)
                end)
        
                inst:DoTaskInTime(1.1, function()
                    M_Util.GroundPoundFx(inst, .8)
                    SpawnSlashFx4(inst, inst, 4)
                    M_Util.AoeAttack(inst, 1, 6.5)
                end)
        
                inst:DoTaskInTime(1.2, function()
                    M_Util.SlashFx(inst, inst, "wanda_attack_shadowweapon_normal_fx", 3)
                    M_Util.AoeAttack(inst, 1, 6.5)
                end)
        
                inst:DoTaskInTime(1.4, function()
                    M_Util.GroundPoundFx(inst, .8)
                    M_Util.SlashFx(inst, inst, "wanda_attack_shadowweapon_old_fx", 3.5)
                    M_Util.AoeAttack(inst, 1, 6.5)
                end)
        
                inst:DoTaskInTime(1.5, function()
                    M_Util.GroundPoundFx(inst, .6)
                    M_Util.SlashFx(inst, inst, "wanda_attack_shadowweapon_normal_fx", 4)
                end)
        
                inst:DoTaskInTime(1.6, function()
                    M_Util.GroundPoundFx(inst, .8)
                    M_Util.SlashFx(inst, inst, "wanda_attack_shadowweapon_old_fx", 4)
                end)
        
                inst:DoTaskInTime(1.8, function()
                    M_Util.SlashFx(inst, inst, "wanda_attack_shadowweapon_normal_fx", 3)
                    M_Util.AoeAttack(inst, 1, 6.5)
                end)
        
                inst:DoTaskInTime(1.9, function()
                    M_Util.GroundPoundFx(inst, .8)
                    M_Util.SlashFx(inst, inst, "wanda_attack_shadowweapon_old_fx", 3.5)
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
            end)
        end
    },
    HeavenlyStrike = {
        tag = "heavenlystrike",
        time = M_CONFIG.SKILL2_COOLDOWN - 30,
        mindpower = 5,
        fn = function(inst, target, weapon)
            inst:DoTaskInTime(.1, function()
                inst.components.talker:Say(STRINGS.SKILL.SKILL5ATTACK, 2, true)
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
            end) 
        end
    },
    Ryusen = {
        tag = "ryusen",
        time = M_CONFIG.SKILL3_COOLDOWN - 60,
        mindpower = 8,
        fn = function(inst, target, weapon)
            inst:DoTaskInTime(.1, function()
                inst.components.talker:Say(STRINGS.SKILL.SKILL6ATTACK, 2, true)
                inst.skill_target = target
                inst.sg:GoToState("ryusen", inst.skill_target)

                inst:DoTaskInTime(.2, function()
                    M_Util.SlashFx(inst, inst.skill_target, "wanda_attack_shadowweapon_old_fx", 2)
                end)

                inst:DoTaskInTime(.4, function()
                    M_Util.SlashFx(inst, inst.skill_target, "wanda_attack_shadowweapon_normal_fx", 2)
                end)
        
                inst:DoTaskInTime(.6, function()
                    M_Util.SlashFx(inst, inst.skill_target, "wanda_attack_shadowweapon_old_fx", 2.5)
                end)

                inst:DoTaskInTime(.8, function()
                    M_Util.SlashFx(inst, inst.skill_target, "wanda_attack_shadowweapon_normal_fx", 2.5)
                    M_Util.GroundPoundFx(inst.skill_target, .7)
                end)

                inst:DoTaskInTime(1, function()
                    M_Util.GroundPoundFx(inst, .6)
                end)

                inst:DoTaskInTime(1.5, function()
                    M_Util.SlashFx(inst, inst.skill_target, "shadowstrike_slash_fx", 3)
                    M_Util.GroundPoundFx(inst.skill_target, .7)
                end)
            end)
        end
    },

    Susanoo = {
        tag = "susanoo",
        time = M_CONFIG.SKILL3_COOLDOWN,
        mindpower = 10,
        fn = function(inst, target, weapon)
            inst:DoTaskInTime(.1, function()
                inst.components.talker:Say(STRINGS.SKILL.SKILL7ATTACK, 2, true)
                M_Util.GroundPoundFx(inst, .6)

                M_Util.SlashFx(inst, target, "shadowstrike_slash_fx", 3)
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
            end)
        end
    },

    -- 苍龙破
    Soryuha = {
        tag = "soryuha",
        time = M_CONFIG.SKILL3_COOLDOWN,
        mindpower = 20,
        fn = function(inst, target, weapon)
            
        end
    }
}

return skill_data
