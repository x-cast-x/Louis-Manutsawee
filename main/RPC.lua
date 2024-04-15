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
local ncountskill = 2

local function SkillRemove(inst)
    inst.components.skillreleaser:SkillRemove()
end

local function CanUseSkill(inst)
    local isdead = inst.components.health ~= nil and inst.components.health:IsDead() and (inst.sg:HasStateTag("dead") or inst:HasTag("playerghost"))
    local isasleep = inst.components.sleeper ~= nil and inst.components.sleeper:IsAsleep()
    local isfrozen = inst.components.freezable ~= nil and inst.components.freezable:IsFrozen()
    local isriding = inst.components.rider ~= nil and inst.components.rider:IsRiding()
    local isheavylifting = inst.components.inventory ~= nil and inst.components.inventory:IsHeavyLifting()
    local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    local weapon_has_tags = weapon ~= nil and weapon:HasOneOfTags({"projectile", "whip", "rangedweapon"})
    local weapon_not_has_tags = weapon ~= nil and not weapon:HasOneOfTags({"tool", "sharp", "weapon", "katanaskill"})

    if inst.mafterskillndm ~= nil then
        inst.mafterskillndm:Cancel()
        inst.mafterskillndm = nil
    end

    if (isdead or isasleep or isfrozen or isriding or isheavylifting) or (weapon == nil) or (weapon_has_tags or weapon_not_has_tags) then
        return false
    end

    return true
end

AddModRPCHandler("manutsawee", "LevelCheck", function(inst)
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

AddModRPCHandler("manutsawee", "Skill1", function(inst)
    if inst.components.timer:TimerExists("skill1_key_cd") or not CanUseSkill(inst) then
        return
    end

    local skillLevel = inst.components.kenjutsuka:GetKenjutsuLevel()
    local mindpower = inst.components.kenjutsuka:GetMindpower()
    local message = ""

    if skillLevel < nskill1 then
        message = STRINGS.SKILL.UNLOCK_SKILL..nskill1
    elseif mindpower < 3 then
        message = STRINGS.SKILL.MINDPOWER_NOT_ENOUGH..mindpower.."/3\n "
    else
        inst.components.timer:StartTimer("skill1_key_cd",1)

        local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        local hasIchimonji = inst:HasTag("ichimonji")
        local hasIsshin = inst:HasTag("isshin")
        local hasRyusen = inst:HasTag("ryusen")
        local hasFlip = inst:HasTag("flip")

        if hasIchimonji or hasIsshin or hasRyusen then
            message = STRINGS.SKILL.SKILL_LATER
        elseif hasFlip and weapon ~= nil and weapon:HasTag("katanaskill") then
            if skillLevel < nskill4 then
                message = STRINGS.SKILL.UNLOCK_SKILL..nskill4
            elseif mindpower >= 7 then
                if inst.components.timer:TimerExists("isshin") then
                    message = STRINGS.SKILL.TIER2_COOLDOWN
                else
                    inst:AddTag("isshin")
                    inst.components.combat:SetRange(3)
                    message = STRINGS.SKILL.SKILL4START..mindpower.."/7\n "
                end
            else
                message = STRINGS.SKILL.MINDPOWER_NOT_ENOUGH..mindpower.."/7\n "
            end
        elseif not hasIchimonji then
            if inst.components.timer:TimerExists("ichimonji") then
                message = STRINGS.SKILL.COOLDOWN
            else
                inst:AddTag("ichimonji")
                inst.components.combat:SetRange(3.5)
                message = STRINGS.SKILL.SKILL1START..mindpower.."/3\n "
            end
        end

        if message ~= "" then
            inst.components.talker:Say(message, 1, true)
        end

        SkillRemove(inst)
    end
end)

AddModRPCHandler("manutsawee", "Skill2", function(inst)
    if inst.components.timer:TimerExists("skill2_key_cd") or not CanUseSkill(inst) then
        return
    end

    local skillLevel = inst.components.kenjutsuka:GetKenjutsuLevel()
    local mindpower = inst.components.kenjutsuka:GetMindpower()
    local message = ""

    if skillLevel < nskill2 then
        message = STRINGS.SKILL.UNLOCK_SKILL..nskill2
    elseif mindpower < 4 then
        message = STRINGS.SKILL.MINDPOWER_NOT_ENOUGH..mindpower.."/4\n "
    else
        inst.components.timer:StartTimer("skill2_key_cd",1)

        local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        local hasFlip = inst:HasTag("flip")
        local hasRyusen = inst:HasTag("ryusen")
        local hasSusanoo = inst:HasTag("susanoo")
        local hasIchimonji = inst:HasTag("ichimonji")

        if hasFlip or hasRyusen or hasSusanoo then
            message = STRINGS.SKILL.SKILL_LATER
        elseif hasIchimonji and weapon ~= nil and weapon:HasTag("katanaskill") then
            if skillLevel < nskill6 then
                message = STRINGS.SKILL.UNLOCK_SKILL..nskill6
            elseif mindpower >= 8 then
                if inst.components.timer:TimerExists("ryusen") then
                    message = STRINGS.SKILL.TIER3_COOLDOWN
                else
                    inst:AddTag("ryusen")
                    inst.components.combat:SetRange(10)
                    message = STRINGS.SKILL.SKILL6START..mindpower.."/8\n "
                end
            else
                message = STRINGS.SKILL.MINDPOWER_NOT_ENOUGH..mindpower.."/8\n "
            end
        elseif inst:HasTag("thrust") and weapon ~= nil and weapon:HasTag("katanaskill") then
            if skillLevel < nskill7 then
                message = STRINGS.SKILL.UNLOCK_SKILL..nskill7
            elseif mindpower >= 10 then
                if inst.components.timer:TimerExists("ryusen") then
                    message = STRINGS.SKILL.TIER3_COOLDOWN
                else
                    inst:AddTag("susanoo")
                    inst.components.combat:SetRange(3)
                    message = STRINGS.SKILL.SKILL7START..mindpower.."/10\n "
                end
            else
                message = STRINGS.SKILL.MINDPOWER_NOT_ENOUGH..mindpower.."/10\n "
            end
        elseif not hasFlip then
            if inst.components.timer:TimerExists("flip") then
                message = STRINGS.SKILL.COOLDOWN
            else
                inst:AddTag("flip")
                inst.components.combat:SetRange(3.5)
                message = STRINGS.SKILL.SKILL2START..mindpower.."/4\n "
            end
        end

        if message ~= "" then
            inst.components.talker:Say(message, 1, true)
        end

        SkillRemove(inst)
    end
end)

AddModRPCHandler("manutsawee", "Skill3", function(inst)
    if inst.components.timer:TimerExists("skill3_key_cd") or not CanUseSkill(inst) then
        return
    end

    local skillLevel = inst.components.kenjutsuka:GetKenjutsuLevel()
    local mindpower = inst.components.kenjutsuka:GetMindpower()
    local message = ""

    if skillLevel < nskill3 then
        message = STRINGS.SKILL.UNLOCK_SKILL..nskill3
    elseif mindpower < 4 then
        message = STRINGS.SKILL.MINDPOWER_NOT_ENOUGH..mindpower.."/4\n "
    else
        inst.components.timer:StartTimer("skill3_key_cd",1)

        local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        local hasHeavenlyStrike = inst:HasTag("heavenlystrike")
        local hasThrust = inst:HasTag("thrust")
        local hasSusanoo = inst:HasTag("susanoo")
        local hasFlip = inst:HasTag("flip")

        if hasHeavenlyStrike or hasThrust or hasSusanoo then
            message = STRINGS.SKILL.SKILL_LATER
        elseif hasFlip and weapon ~= nil and weapon:HasTag("katanaskill") then
            if skillLevel < nskill5 then
                message = STRINGS.SKILL.UNLOCK_SKILL..nskill5
            elseif mindpower >= 5 then
                if inst.components.timer:TimerExists("isshin") then
                    message = STRINGS.SKILL.TIER2_COOLDOWN
                else
                    inst:AddTag("heavenlystrike")
                    inst.components.combat:SetRange(3)
                    message = STRINGS.SKILL.SKILL5START..mindpower.."/5\n "
                end
            else
                message = STRINGS.SKILL.MINDPOWER_NOT_ENOUGH..mindpower.."/5\n "
            end
        elseif not hasThrust then
            if inst.components.timer:TimerExists("thrust") then
                message = STRINGS.SKILL.COOLDOWN
            else
                inst:AddTag("thrust")
                inst.components.combat:SetRange(3)
                message = STRINGS.SKILL.SKILL3START..mindpower.."/4\n "
            end
        end

        if message ~= "" then
            inst.components.talker:Say(message, 1, true)
        end

        SkillRemove(inst)
    end
end)

AddModRPCHandler("manutsawee", "CounterAttack", function(inst)
    if not inst.components.timer:TimerExists("prepare_counter_attack") and CanUseSkill(inst) then
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
end)

AddModRPCHandler("manutsawee", "QuickSheath", function(inst)
    local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if weapon ~= nil and weapon.weaponstatus and weapon:HasTag("katanaskill") then
        if inst.components.kenjutsuka:GetKenjutsuLevel() >= ncountskill and not inst.components.timer:TimerExists("quick_sheath_cd") and CanUseSkill(inst) then
            inst.components.timer:StartTimer("quick_sheath_cd",.4)
            inst.sg:GoToState("quicksheath", weapon)
        elseif inst.components.kenjutsuka:GetKenjutsuLevel() < ncountskill then
            inst.components.talker:Say(STRINGS.SKILL.UNLOCK_SKILL.. ncountskill , 1, true)
        end
    end
end)

AddModRPCHandler("manutsawee", "SkillCancel", function(inst)
    if not inst.components.timer:TimerExists("skill_cancel_cd") and CanUseSkill(inst) then
        inst.components.timer:StartTimer("skill_cancel_cd",1)
        SkillRemove(inst)
        inst.components.talker:Say(STRINGS.SKILL.SKILL_CANCEL, 1, true)
    end
end)


AddModRPCHandler("manutsawee", "PutGlasses", function(inst, skinname)
    local not_dead = not (inst.components.health ~= nil and inst.components.health:IsDead() and inst.sg:HasStateTag("dead")) or not inst:HasTag("playerghost")
    local is_idle = inst.sg:HasStateTag("idle") or inst:HasTag("idle")
    local not_doing = not (inst.sg:HasStateTag("doing") or inst.components.inventory:IsHeavyLifting())
    local not_moving = not (inst.sg:HasStateTag("moving") or inst:HasTag("moving"))

    if not_dead and not_doing and not_moving and is_idle and not inst.components.timer:TimerExists("put_glasse_cd")  then
        inst.components.timer:StartTimer("put_glasse_cd",1)

        inst:DoTaskInTime(.1, function()
            inst:PushEvent("putglasses")
        end)

        inst:DoTaskInTime(.6, function()
            if not inst.glasses_status then
                inst.glasses_status = true
                inst.PutGlasses(inst, skinname)
            else
                if inst.AnimState:GetSymbolOverride("swap_face") ~= nil then
                    inst.AnimState:ClearOverrideSymbol("swap_face")
                end
                inst.glasses_status = false
            end
        end)
    end
end)

AddModRPCHandler("manutsawee", "ChangeHairsStyle", function(inst, skinname)
    local not_dead = not (inst.components.health ~= nil and inst.components.health:IsDead() and inst.sg:HasStateTag("dead")) or not inst:HasTag("playerghost")
    local is_idle = inst.sg:HasStateTag("idle") or inst:HasTag("idle")
    local not_doing = not (inst.sg:HasStateTag("doing") or inst.components.inventory:IsHeavyLifting())
    local not_moving = not (inst.sg:HasStateTag("moving") or inst:HasTag("moving"))

    if not_dead and not_doing then
        if inst.hair_long == 1 then
            inst.components.talker:Say(STRINGS.SKILL.HAIRTOOSHORT)
        elseif not_moving and is_idle and not inst.components.timer:TimerExists("change_hair_cd") then
            inst.components.timer:StartTimer("change_hair_cd", 1.4)

            inst:DoTaskInTime(.1, function()
                inst:PushEvent("changehair")
            end)

            inst:DoTaskInTime(1, function()
                if inst.hair_type < #inst.HAIR_TYPES then
                    inst.hair_type = inst.hair_type + 1
                else
                    inst.hair_type = 1
                end
                inst.OnChangeHair(inst, skinname)
            end)
        end
    end
end)

AddShardModRPCHandler("manutsawee", "SyncKatanaData", function(shardid, active, katana)
    if not TheWorld.ismastershard then
        return
    end

    if active then
        TheWorld:PushEvent("ms_trackkatana", {name = katana.prefab, katana = katana})
    else
        TheWorld:PushEvent("ms_forgetkatana", {name = katana.prefab})
    end
end)
