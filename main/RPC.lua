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

AddModRPCHandler("LouisManutsawee", "LevelCheck", function(inst)
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

AddModRPCHandler("LouisManutsawee", "Skill1", function(inst)
    if inst.components.timer:TimerExists("skill1_key_cd") or not CanUseSkill(inst) then
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
end)

AddModRPCHandler("LouisManutsawee", "Skill2", function(inst)
    if inst.components.timer:TimerExists("skill2_key_cd") or not CanUseSkill(inst) then
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
end)

AddModRPCHandler("LouisManutsawee", "Skill3", function(inst)
    if inst.components.timer:TimerExists("skill3_key_cd") or not CanUseSkill(inst) then
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
end)

local MUST_TAG = {"mortalblade", "onikiba"}
AddModRPCHandler("LouisManutsawee", "Skill4", function(inst)
    if not inst.components.timer:TimerExists("skill4_key_cd") or not CanUseSkill(inst) then
        inst.components.timer:StartTimer("skill4_key_cd",1)

        local kenjutsulevel = inst.components.kenjutsuka:GetKenjutsuLevel()
        local mindpower = inst.components.kenjutsuka:GetMindpower()

        local immortalslash = inst:HasTag("immortalslash")
        local soryuha = inst:HasTag("soryuha")

        if not (kenjutsulevel <= nskill8) then

            local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

            if weapon ~= nil and weapon:HasOneOfTags(MUST_TAG) then
                local is_mortalblade = weapon:HasTag("mortalblade")
                local is_tokijin = weapon:HasTag("onikiba")

                if mindpower >= 20 then
                    if immortalslash or soryuha then
                        SkillRemove(inst)
                        inst.components.talker:Say(STRINGS.SKILL.SKILL_LATER, 1, true)
                    elseif not is_mortalblade and not immortalslash then
                        if not inst.components.timer:TimerExists("immortalslash") then
                            inst.components.talker:Say(STRINGS.SKILL.COOLDOWN, 1, true)
                            SkillRemove(inst)
                        else
                            SkillRemove(inst)
                            inst:AddTag("immortalslash")
                            inst.components.combat:SetRange(3)
                            inst.components.talker:Say(STRINGS.SKILL.SKILL8START.. mindpower .."/4\n ", 1, true)
                        end
                    -- elseif not is_tokijin and not soryuha then
                    --     if not inst.components.timer:TimerExists("soryuha") then
                    --         inst.components.talker:Say(STRINGS.SKILL.COOLDOWN, 1, true)
                    --         SkillRemove(inst)
                    --     else
                    --         SkillRemove(inst)
                    --         inst:AddTag("soryuha")
                    --         inst.components.combat:SetRange(3)
                    --         inst.components.talker:Say(STRINGS.SKILL.SKILL9START.. mindpower .."/4\n ", 1, true)
                    --     end
                    end
                else
                    inst.components.talker:Say(STRINGS.SKILL.MINDPOWER_NOT_ENOUGH.. mindpower .."/4\n ", 1, true)
                    SkillRemove(inst)
                end
            else
                inst.components.talker:Say(STRINGS.SKILL.UNLOCK_SKILL..nskill8, 1, true)
                SkillRemove(inst)
            end
        else
            inst.components.talker:Say(STRINGS.SKILL.UNLOCK_SKILL..nskill8, 1, true)
        end
    end
end)

AddModRPCHandler("LouisManutsawee", "CounterAttack", function(inst)
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

AddModRPCHandler("LouisManutsawee", "QuickSheath", function(inst)
    if not (inst.components.kenjutsuka:GetKenjutsuLevel() < ncountskill) then
        if not inst.components.timer:TimerExists("quick_sheath_cd") or not CanUseSkill(inst) then
            local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if weapon ~= nil and weapon:HasTag("katanaskill") then
                inst.components.timer:StartTimer("quick_sheath_cd",.4)
                inst.sg:GoToState("quicksheath")
            end
        end
    else
        inst.components.talker:Say(STRINGS.SKILL.UNLOCK_SKILL.. ncountskill , 1, true)
    end
end)

AddModRPCHandler("LouisManutsawee", "SkillCancel", function(inst)
    if not inst.components.timer:TimerExists("skill_cancel_cd") and CanUseSkill(inst) then
        inst.components.timer:StartTimer("skill_cancel_cd",1)
        SkillRemove(inst)
        inst.components.talker:Say(STRINGS.SKILL.SKILL_CANCEL, 1, true)
    end
end)

AddModRPCHandler("LouisManutsawee", "PutGlasses", function(inst, skinname)
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

AddModRPCHandler("LouisManutsawee", "ChangeHairsStyle", function(inst, skinname)
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

AddShardModRPCHandler("LouisManutsawee", "SyncKatanaData", function(shardid, active, name)
    if active then
        print("Get RPC: Run SyncKatanaData active: " .. tostring(active) ..  " name: " .. tostring(name))
        TheWorld:PushEvent("ms_trackkatana", {name = name})
    else
        print("Get RPC: Run SyncKatanaData active: " .. tostring(active) ..  " name: " ..  tostring(name))
        TheWorld:PushEvent("ms_forgetkatana", {name = name})
    end
end)
