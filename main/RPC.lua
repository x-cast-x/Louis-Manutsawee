local AddModRPCHandler = AddModRPCHandler
local AddShardModRPCHandler = AddShardModRPCHandler
local STRINGS = GLOBAL.STRINGS
GLOBAL.setfenv(1, GLOBAL)

local nskill1 = 1
local nskill2 = 3
local nskill3 = 4
local nskill4 = 6
local nskill5 = 5
local nskill6 = 7
local nskill7 = 8
local nskill8 = 10
local ncountskill = 2

local LouisManutsawee, Momo = "LouisManutsawee", "Momo"

local function SkillRemove(inst)
    inst.components.playerskillmanager:RemoveAllSkills()
end

local MUST_TAG = {"tool", "sharp", "weapon", "katanaskill"}
local CANT_TAG = {"projectile", "whip", "rangedweapon"}
local function CanUseSkill(inst)
    local inventory = inst.components.inventory
    local weapon = inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    local IsAsleep = inst.components.sleeper ~= nil and not inst.components.sleeper:IsAsleep()
    local IsFrozen = inst.components.freezable:IsFrozen()
    local IsRiding = inst.components.rider:IsRiding()
    local IsHeavyLifting = inventory:IsHeavyLifting()

    -- print("Has Weapon" .. tostring(weapon ~= nil) ..
    -- "\nIsAsleep: " .. tostring(IsAsleep)..
    -- "\nIsFrozen: " .. tostring(IsFrozen) ..
    -- "\nIsRiding: " .. tostring(IsRiding) ..
    -- "\nIsHeavyLifting: " .. tostring(IsHeavyLifting) ..
    -- "\nnot die: " .. tostring(inst:HasTag("playerghost")))

    if not weapon or IsAsleep or IsFrozen or IsRiding or IsHeavyLifting or inst:HasTag("playerghost") or weapon:HasOneOfTags(CANT_TAG) and not weapon:HasOneOfTags(MUST_TAG) then
        return false
    end

    return true
end

AddModRPCHandler(LouisManutsawee, "LevelCheck", function(inst)
    local kenjutsuka = inst.components.kenjutsuka
    local kenjutsuexp = kenjutsuka.kenjutsuexp
    local kenjutsumaxexp = kenjutsuka.kenjutsumaxexp
    local kenjutsulevel = kenjutsuka.kenjutsulevel
    local mindpower = kenjutsuka:GetMindpower()
    local max_mindpower = kenjutsuka.max_mindpower

    if not inst.components.timer:TimerExists("levelcheck_cd") then
        inst.components.timer:StartTimer("levelcheck_cd",.8)
        if kenjutsulevel < 10 then
            inst.components.talker:Say("󰀍: ".. kenjutsulevel .." :" .. kenjutsuexp .. "/" .. kenjutsumaxexp .. "\n󰀈: " .. mindpower .."/" .. max_mindpower .. "\n", 2, true)
        else
            inst.components.talker:Say("\n󰀈: ".. mindpower .. "/" .. max_mindpower.."\n", 2, true)
        end
    end
end)

AddModRPCHandler(LouisManutsawee, "Skill1", function(inst)
    if CanUseSkill(inst) then
        if inst.components.timer:TimerExists("skill1_key_cd")then
            return
        end


        if inst.components.kenjutsuka:GetKenjutsuLevel() < nskill1 then
            inst.components.talker:Say(STRINGS.SKILL.UNLOCK_SKILL..nskill1, 1, true)
            return
        end

        inst.components.timer:StartTimer("skill1_key_cd", 1)

        local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

        if inst.components.kenjutsuka:GetMindpower() >= 3 then
            if inst:HasTag("ichimonji") or inst:HasTag("isshin") or inst:HasTag("ryusen") then
                SkillRemove(inst) inst.components.talker:Say(STRINGS.SKILL.SKILL_LATER, 1, true)
                return
            elseif inst:HasTag("flip") and weapon ~= nil and weapon:HasTag("katanaskill") then
                if inst.components.kenjutsuka:GetKenjutsuLevel() < nskill4 then
                    inst.components.talker:Say(STRINGS.SKILL.UNLOCK_SKILL..nskill4, 1, true)
                    SkillRemove(inst)
                elseif inst.components.kenjutsuka:GetMindpower() >= 7 then
                    if inst.components.timer:TimerExists("isshin") then
                        inst.components.talker:Say(STRINGS.SKILL.TIER2_COOLDOWN, 1, true)
                        SkillRemove(inst)
                        return
                    end
                    SkillRemove(inst)
                    inst:AddTag("isshin")
                    inst.components.combat:SetRange(3)
                    inst.components.talker:Say(STRINGS.SKILL.SKILL4START..inst.components.kenjutsuka:GetMindpower().."/7\n ", 1, true)
                    return
                else
                    inst.components.talker:Say(STRINGS.SKILL.MINDPOWER_NOT_ENOUGH..inst.components.kenjutsuka:GetMindpower().."/7\n ", 1, true)
                    SkillRemove(inst)
                    return
                end
            elseif not inst:HasTag("ichimonji") then
                if inst.components.timer:TimerExists("ichimonji") then
                    inst.components.talker:Say(STRINGS.SKILL.COOLDOWN, 1, true)
                    SkillRemove(inst)
                    return
                end
                SkillRemove(inst)
                inst:AddTag("ichimonji")
                inst.components.combat:SetRange(3.5)
                inst.components.talker:Say(STRINGS.SKILL.SKILL1START..inst.components.kenjutsuka:GetMindpower().."/3\n ", 1, true)
            end
        else
            inst.components.talker:Say(STRINGS.SKILL.MINDPOWER_NOT_ENOUGH..inst.components.kenjutsuka:GetMindpower().."/3\n ", 1, true)
            SkillRemove(inst)
        end
    end
end)

AddModRPCHandler(LouisManutsawee, "Skill2", function(inst)
    if CanUseSkill(inst) then
        if inst.components.timer:TimerExists("skill2_key_cd") then
            return
        end

        if inst.components.kenjutsuka:GetKenjutsuLevel() < nskill2 then
            inst.components.talker:Say(STRINGS.SKILL.UNLOCK_SKILL..nskill2, 1, true)
            return
        end

        inst.components.timer:StartTimer("skill2_key_cd",1)

        if inst.components.kenjutsuka:GetMindpower() >= 4 then
            local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if inst:HasTag("flip") or inst:HasTag("ryusen") or inst:HasTag("susanoo") then
                SkillRemove(inst)
                inst.components.talker:Say(STRINGS.SKILL.SKILL_LATER, 1, true)
                return
            elseif inst:HasTag("ichimonji") and weapon ~= nil and weapon:HasTag("katanaskill") then
                if inst.components.kenjutsuka:GetKenjutsuLevel() < nskill6 then
                    inst.components.talker:Say(STRINGS.SKILL.UNLOCK_SKILL..nskill6, 1, true)
                    SkillRemove(inst)
                elseif inst.components.kenjutsuka:GetMindpower() >= 8 then
                    if inst.components.timer:TimerExists("ryusen") then
                        inst.components.talker:Say(STRINGS.SKILL.TIER3_COOLDOWN, 1, true)
                        SkillRemove(inst)
                        return
                    end
                    SkillRemove(inst)
                    inst:AddTag("ryusen")
                    inst.components.combat:SetRange(10)
                    inst.components.talker:Say(STRINGS.SKILL.SKILL6START..inst.components.kenjutsuka:GetMindpower().."/8\n ", 1, true)
                    return
                else
                    inst.components.talker:Say(STRINGS.SKILL.MINDPOWER_NOT_ENOUGH..inst.components.kenjutsuka:GetMindpower().."/8\n ", 1, true)
                    SkillRemove(inst)
                    return
                end
            elseif inst:HasTag("thrust") and weapon ~= nil and weapon:HasTag("katanaskill") then
                if inst.components.kenjutsuka:GetKenjutsuLevel() < nskill7 then
                    inst.components.talker:Say(STRINGS.SKILL.UNLOCK_SKILL..nskill7, 1, true)
                    SkillRemove(inst)
                elseif inst.components.kenjutsuka:GetMindpower() >= 10 then
                    if inst.components.timer:TimerExists("ryusen") then
                        inst.components.talker:Say(STRINGS.SKILL.TIER3_COOLDOWN, 1, true)
                        SkillRemove(inst)
                        return
                    end
                    SkillRemove(inst)
                    inst:AddTag("susanoo")
                    inst.components.combat:SetRange(3)
                    inst.components.talker:Say(STRINGS.SKILL.SKILL7START..inst.components.kenjutsuka:GetMindpower().."/10\n ", 1, true)
                    return
                else
                    inst.components.talker:Say(STRINGS.SKILL.MINDPOWER_NOT_ENOUGH..inst.components.kenjutsuka:GetMindpower().."/10\n ", 1, true)
                    SkillRemove(inst)
                    return
                end
            elseif not inst:HasTag("flip") then
                if inst.components.timer:TimerExists("flip") then
                    inst.components.talker:Say(STRINGS.SKILL.COOLDOWN, 1, true)
                    SkillRemove(inst)
                    return
                end
                SkillRemove(inst)
                inst:AddTag("flip")
                inst.components.combat:SetRange(3.5)
                inst.components.talker:Say(STRINGS.SKILL.SKILL2START..inst.components.kenjutsuka:GetMindpower().."/4\n ", 1, true)
            end
        else
            inst.components.talker:Say(STRINGS.SKILL.MINDPOWER_NOT_ENOUGH..inst.components.kenjutsuka:GetMindpower().."/4\n ", 1, true)
            SkillRemove(inst)
        end
    end
end)

AddModRPCHandler(LouisManutsawee, "Skill3", function(inst)
    if CanUseSkill(inst) then

        if inst.components.timer:TimerExists("skill3_key_cd") then
            return
        end


        if inst.components.kenjutsuka:GetKenjutsuLevel() < nskill3 then
            inst.components.talker:Say(STRINGS.SKILL.UNLOCK_SKILL..nskill3, 1, true)
            return
        end

        inst.components.timer:StartTimer("skill3_key_cd",1)

        if inst.components.kenjutsuka:GetMindpower() >= 4 then
            local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if inst:HasTag("heavenlystrike") or inst:HasTag("thrust") or inst:HasTag("susanoo") then
                SkillRemove(inst)
                inst.components.talker:Say(STRINGS.SKILL.SKILL_LATER, 1, true)
                return
            elseif inst:HasTag("flip") and weapon ~= nil and weapon:HasTag("katanaskill") then
                if inst.components.kenjutsuka:GetKenjutsuLevel() < nskill5 then
                    inst.components.talker:Say(STRINGS.SKILL.UNLOCK_SKILL..nskill5, 1, true)
                    SkillRemove(inst)
                elseif inst.components.kenjutsuka:GetMindpower() >= 5 then
                    if inst.components.timer:TimerExists("isshin") then
                        inst.components.talker:Say(STRINGS.SKILL.TIER2_COOLDOWN, 1, true)
                        SkillRemove(inst)
                        return
                    end

                    SkillRemove(inst)
                    inst:AddTag("heavenlystrike")
                    inst.components.combat:SetRange(3)
                    inst.components.talker:Say(STRINGS.SKILL.SKILL5START..inst.components.kenjutsuka:GetMindpower().."/5\n ", 1, true)
                    return
                else
                    inst.components.talker:Say(STRINGS.SKILL.MINDPOWER_NOT_ENOUGH..inst.components.kenjutsuka:GetMindpower().."/5\n ", 1, true)
                    SkillRemove(inst)
                    return
                end
            elseif not inst:HasTag("thrust") then
                if inst.components.timer:TimerExists("thrust") then
                    inst.components.talker:Say(STRINGS.SKILL.COOLDOWN, 1, true)
                    SkillRemove(inst)
                    return
                end
                SkillRemove(inst)
                inst:AddTag("thrust")
                inst.components.combat:SetRange(3)
                inst.components.talker:Say(STRINGS.SKILL.SKILL3START..inst.components.kenjutsuka:GetMindpower().."/4\n ", 1, true)
            end
        else
            inst.components.talker:Say(STRINGS.SKILL.MINDPOWER_NOT_ENOUGH..inst.components.kenjutsuka:GetMindpower().."/4\n ", 1, true)
            SkillRemove(inst)
        end
    end
end)

AddModRPCHandler(LouisManutsawee, "Skill4", function(inst)
    if CanUseSkill(inst) then
        if not inst.components.timer:TimerExists("skill4_key_cd")then
            inst.components.timer:StartTimer("skill4_key_cd",1)

            local kenjutsulevel = inst.components.kenjutsuka:GetKenjutsuLevel()
            local mindpower = inst.components.kenjutsuka:GetMindpower()

            local immortalslash = inst:HasTag("immortalslash")
            local soryuha = inst:HasTag("soryuha")

            if kenjutsulevel >= nskill8 then

                local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

                if weapon ~= nil then
                    local is_mortalblade = weapon:HasTag("mortalblade")
                    local is_tokijin = weapon:HasTag("onikiba")

                    if mindpower >= 20 then
                        if immortalslash or soryuha then
                            SkillRemove(inst)
                            inst.components.talker:Say(STRINGS.SKILL.SKILL_LATER, 1, true)
                        -- elseif not is_mortalblade and not immortalslash then
                        --     if not inst.components.timer:TimerExists("immortalslash") then
                        --         inst.components.talker:Say(STRINGS.SKILL.COOLDOWN, 1, true)
                        --         SkillRemove(inst)
                        --     else
                        --         SkillRemove(inst)
                        --         inst:AddTag("immortalslash")
                        --         inst.components.combat:SetRange(3)
                        --         inst.components.talker:Say(STRINGS.SKILL.SKILL8START.. mindpower .."/4\n ", 1, true)
                        --     end
                        elseif is_tokijin and not soryuha then
                            if not inst.components.timer:TimerExists("soryuha") then
                                SkillRemove(inst)
                                inst:AddTag("soryuha")
                                inst.components.combat:SetRange(3)
                                inst.components.talker:Say(STRINGS.SKILL.SKILL9START.. mindpower .."/4\n ", 1, true)
                            else
                                inst.components.talker:Say(STRINGS.SKILL.COOLDOWN, 1, true)
                                SkillRemove(inst)
                            end
                        end
                    else
                        inst.components.talker:Say(STRINGS.SKILL.MINDPOWER_NOT_ENOUGH.. mindpower .."/4\n ", 1, true)
                        SkillRemove(inst)
                    end
                else
                    inst.components.talker:Say(STRINGS.SKILL.REJECTED, 1, true)
                    SkillRemove(inst)
                end
            else
                inst.components.talker:Say(STRINGS.SKILL.UNLOCK_SKILL..nskill8, 1, true)
            end
        end
    end
end)

AddModRPCHandler(LouisManutsawee, "CounterAttack", function(inst)
    if CanUseSkill(inst) then
        if not inst.components.timer:TimerExists("prepare_counter_attack") then
            local kenjutsuLevel = inst.components.kenjutsuka:GetKenjutsuLevel()
            if kenjutsuLevel >= ncountskill then
                inst.components.timer:StartTimer("prepare_counter_attack", .63)
                SkillRemove(inst)
                inst.sg:GoToState("counter_start")
            else
                inst.components.talker:Say(STRINGS.SKILL.UNLOCK_SKILL..ncountskill, 1, true)
            end
        else
            inst.components.talker:Say(STRINGS.SKILL.COOLDOWN, 1, true)
            SkillRemove(inst)
        end
    end
end)

AddModRPCHandler(LouisManutsawee, "QuickSheath", function(inst)
    if CanUseSkill(inst) then
        if not (inst.components.kenjutsuka:GetKenjutsuLevel() < ncountskill) then
            if not inst.components.timer:TimerExists("quick_sheath_cd") then
                local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                if weapon ~= nil and weapon:HasTag("katanaskill") then
                    inst.components.timer:StartTimer("quick_sheath_cd",.4)
                    inst.sg:GoToState("quicksheath")
                end
            end
        else
            inst.components.talker:Say(STRINGS.SKILL.UNLOCK_SKILL.. ncountskill , 1, true)
        end
    end
end)

AddModRPCHandler(LouisManutsawee, "SkillCancel", function(inst)
    if CanUseSkill(inst) then
        if not inst.components.timer:TimerExists("skill_cancel_cd") then
            inst.components.timer:StartTimer("skill_cancel_cd",1)
            SkillRemove(inst)
            inst.components.talker:Say(STRINGS.SKILL.SKILL_CANCEL, 1, true)
        end
    end
end)

AddShardModRPCHandler(LouisManutsawee, "SyncKatanaSpawnerData", function(shardid, active, name)
    if active then
        TheWorld:PushEvent("ms_trackkatana", {name = name})
    else
        TheWorld:PushEvent("ms_forgetkatana", {name = name})
    end
end)

AddShardModRPCHandler(Momo, "SyncDatingManagerData", function()

end)
