local AddModRPCHandler = AddModRPCHandler
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
    inst.components.skillreleaser:CanUseSkill(nil, true)
end

local function LevelCheckFn(inst)
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
end

local function Skill1Fn(inst)
    if inst.components.timer:TimerExists("sskill1cd") then
        return
    end

    CanUseSkill(inst)

    if not inst.components.skillreleaser.canuseskill then
        return
    end

    if inst.components.kenjutsuka:GetKenjutsuLevel() < nskill1 then
        inst.components.talker:Say("[UNLOCK] 󰀍: "..nskill1, 1, true)
        return
    end

	inst.components.timer:StartTimer("sskill1cd",1)

	if inst.components.kenjutsuka:GetMindpower() >= 3 then
        if inst:HasTag("ichimonji") or inst:HasTag("misshin") or inst:HasTag("ryusen") then
            SkillRemove(inst) inst.components.talker:Say("Later...", 1, true)
            return
        elseif inst:HasTag("mflipskill") and equip ~= nil and equip:HasTag("katanaskill") then
            if inst.components.kenjutsuka:GetKenjutsuLevel() < nskill4 then
                inst.components.talker:Say("[UNLOCK] 󰀍: "..nskill4, 1, true)
                SkillRemove(inst)
            elseif inst.components.kenjutsuka:GetMindpower() >= 7 then
                if inst.components.timer:TimerExists("skillT2cd") then
                    inst.components.talker:Say("Tier2: Cooldown", 1, true)
                    SkillRemove(inst)
                    return
                end
                SkillRemove(inst)
                inst:AddTag("misshin")
                inst.components.combat:SetRange(3)
                inst.components.talker:Say(STRINGS.SKILL.SKILL4START..inst.components.kenjutsuka:GetMindpower().."/7\n ", 1, true)
                return
            else
                inst.components.talker:Say("Not now!\n󰀈: "..inst.components.kenjutsuka:GetMindpower().."/7\n ", 1, true)
                SkillRemove(inst)
                return
            end
        elseif not inst:HasTag("ichimonji") then
            if inst.components.timer:TimerExists("skill1cd") then
                inst.components.talker:Say("Cooldown", 1, true)
                SkillRemove(inst)
                return
            end
            SkillRemove(inst)
            inst:AddTag("ichimonji")
            inst.components.combat:SetRange(3.5)
            inst.components.talker:Say(STRINGS.SKILL.SKILL1START..inst.components.kenjutsuka:GetMindpower().."/3\n ", 1, true)
        end
	else
        inst.components.talker:Say("Not now!\n󰀈: "..inst.components.kenjutsuka:GetMindpower().."/3\n ", 1, true)
        SkillRemove(inst)
    end
end

local function Skill2Fn(inst)
    if inst.components.timer:TimerExists("sskill2cd") then
        return
    end

    CanUseSkill(inst)

    if not inst.components.skillreleaser.canuseskill then
        return
    end

    if inst.components.kenjutsuka:GetKenjutsuLevel() < nskill2 then 
        inst.components.talker:Say("[UNLOCK] 󰀍: "..nskill2, 1, true)
        return
    end

	inst.components.timer:StartTimer("sskill2cd",1)

	if inst.components.kenjutsuka:GetMindpower() >= 4 then
        local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if inst:HasTag("flip") or inst:HasTag("ryusen") or inst:HasTag("susanoo") then
            SkillRemove(inst) 
            inst.components.talker:Say("Later...", 1, true)
            return
        elseif inst:HasTag("ichimonji") and equip ~= nil and equip:HasTag("katanaskill") then
            if inst.components.kenjutsuka:GetKenjutsuLevel() < nskill6 then
                inst.components.talker:Say("[UNLOCK] 󰀍: "..nskill6, 1, true)
                SkillRemove(inst)
            elseif inst.components.kenjutsuka:GetMindpower() >= 8 then
                if inst.components.timer:TimerExists("skillT3cd") then
                    inst.components.talker:Say("Tier3: Cooldown", 1, true)
                    SkillRemove(inst)
                    return
                end
                SkillRemove(inst)
                inst:AddTag("ryusen")
                inst.components.combat:SetRange(10)
                inst.components.talker:Say(STRINGS.SKILL.SKILL6START..inst.components.kenjutsuka:GetMindpower().."/8\n ", 1, true)
                return
            else
                inst.components.talker:Say("Not now!\n󰀈: "..inst.components.kenjutsuka:GetMindpower().."/8\n ", 1, true)
                SkillRemove(inst)
                return
            end
        elseif inst:HasTag("thrust") and equip ~= nil and equip:HasTag("katanaskill") then
            if inst.components.kenjutsuka:GetKenjutsuLevel() < nskill7 then
                inst.components.talker:Say("[UNLOCK] 󰀍: "..nskill7, 1, true)
                SkillRemove(inst)
            elseif inst.components.kenjutsuka:GetMindpower() >= 10 then
                if inst.components.timer:TimerExists("skillT3cd") then
                    inst.components.talker:Say("Tier3: Cooldown", 1, true)
                    SkillRemove(inst)
                    return
                end
                SkillRemove(inst)
                inst:AddTag("susanoo")
                inst.components.combat:SetRange(3)
                inst.components.talker:Say(STRINGS.SKILL.SKILL7START..inst.components.kenjutsuka:GetMindpower().."/10\n ", 1, true)
                return
            else
                inst.components.talker:Say("Not now!\n󰀈: "..inst.components.kenjutsuka:GetMindpower().."/10\n ", 1, true)
                SkillRemove(inst)
                return
            end
        elseif not inst:HasTag("flip") then
            if inst.components.timer:TimerExists("skill2cd") then
                inst.components.talker:Say("Cooldown", 1, true)
                SkillRemove(inst)
                return
            end
            SkillRemove(inst)
            inst:AddTag("flip")
            inst.components.combat:SetRange(3.5)
            inst.components.talker:Say(STRINGS.SKILL.SKILL2START..inst.components.kenjutsuka:GetMindpower().."/4\n ", 1, true)
        end
    else
        inst.components.talker:Say("Not now!\n󰀈: "..inst.components.kenjutsuka:GetMindpower().."/4\n ", 1, true)
        SkillRemove(inst)
    end
end

local function Skill3Fn(inst) ----------  T
    if inst.components.timer:TimerExists("sskill3cd") then
        return
    end

    CanUseSkill(inst)

    if not inst.components.skillreleaser.canuseskill then
        return
    end

    if inst.components.kenjutsuka:GetKenjutsuLevel() < nskill3 then
        inst.components.talker:Say("[UNLOCK] 󰀍: "..nskill3, 1, true)
        return
    end

	inst.components.timer:StartTimer("sskill3cd",1)

    if inst.components.kenjutsuka:GetMindpower() >= 4 then
        local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if inst:HasTag("heavenlystrike") or inst:HasTag("thrust") or inst:HasTag("susanoo") then
			SkillRemove(inst)
				inst.components.talker:Say("Later...", 1, true)
			return
    	elseif inst:HasTag("flip") and equip ~= nil and equip:HasTag("katanaskill") then
			if inst.components.kenjutsuka:GetKenjutsuLevel() < nskill5 then
                inst.components.talker:Say("[UNLOCK] 󰀍: "..nskill5, 1, true)
                SkillRemove(inst)
        	elseif inst.components.kenjutsuka:GetMindpower() >= 5 then
                if inst.components.timer:TimerExists("skillT2cd") then
                    inst.components.talker:Say("Tier2: Cooldown", 1, true)
                    SkillRemove(inst)
                    return
                end

                SkillRemove(inst)
                inst:AddTag("heavenlystrike")
                inst.components.combat:SetRange(3)
                inst.components.talker:Say(STRINGS.SKILL.SKILL5START..inst.components.kenjutsuka:GetMindpower().."/5\n ", 1, true)
                return
			else
                inst.components.talker:Say("Not now!\n󰀈: "..inst.components.kenjutsuka:GetMindpower().."/5\n ", 1, true)
                SkillRemove(inst)
                return
            end
		elseif not inst:HasTag("thrust") then
            if inst.components.timer:TimerExists("skill3cd") then
                inst.components.talker:Say("Cooldown", 1, true) 
                SkillRemove(inst)
                return
            end
			SkillRemove(inst)
            inst:AddTag("thrust")
            inst.components.combat:SetRange(3)
            inst.components.talker:Say(STRINGS.SKILL.SKILL3START..inst.components.kenjutsuka:GetMindpower().."/4\n ", 1, true)
		end
    else
        inst.components.talker:Say("Not now!\n󰀈: "..inst.components.kenjutsuka:GetMindpower().."/4\n ", 1, true)
        SkillRemove(inst)
    end
end

local function CounterAttackFn(inst)
    if inst.components.timer:TimerExists("prepare_counter_attack") then
        inst.components.talker:Say("Cooldown", 1, true)
        SkillRemove(inst)
        return
    end

    CanUseSkill(inst)

    if not inst.components.skillreleaser.canuseskill then
        return
    end

    if inst.components.kenjutsuka:GetKenjutsuLevel() < ncountskill then
        inst.components.talker:Say("[UNLOCK] 󰀍: "..ncountskill, 1, true)
        return
    end

    if not inst.components.timer:TimerExists("prepare_counter_attack") then
        inst.components.timer:StartTimer("prepare_counter_attack", .63)
        SkillRemove(inst)
        inst.sg:GoToState("counterstart")
    end
end

local function SkillCancelFn(inst)
    if inst.components.timer:TimerExists("skill_cancel_cd") then
        return
    end

    CanUseSkill(inst)

    if not inst.components.skillreleaser.canuseskill then
        return
    end

    inst.components.timer:StartTimer("skill_cancel_cd",1)
    SkillRemove(inst)
    inst.components.talker:Say("Maybe next time.", 1, true)
end

local function QuickSheathFn(inst)
    if inst.components.skillreleaser.kenjutsulevel < ncountskill then
        inst.components.talker:Say("[UNLOCK] 󰀍: ".. ncountskill , 1, true)
        return
    end

    if inst.components.timer:TimerExists("quick_sheath_cd") then
        return
    end

    CanUseSkill(inst)

    if not inst.components.skillreleaser.canuseskill then
        return
    end

    local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if weapon ~= nil and weapon.wpstatus ~= nil and weapon:HasTag("katanaskill") then
		inst.components.timer:StartTimer("quick_sheath_cd",.4)
		inst.sg:GoToState("quicksheath", weapon)
	end
end

local function GlassesFn(inst, skinname)
    if inst.components.health ~= nil and inst.components.health:IsDead() and inst.sg:HasStateTag("dead") or inst:HasTag("playerghost") then
        return
    end

	if not (inst.sg:HasStateTag("doing") or inst.components.inventory:IsHeavyLifting()) then
		if (inst.sg:HasStateTag("idle") or inst:HasTag("idle")) and not (inst.sg:HasStateTag("moving") or inst:HasTag("moving")) and not inst.components.timer:TimerExists("put_glasse_cd") then
			inst.components.timer:StartTimer("put_glasse_cd",1)

            inst:DoTaskInTime(.1, function()
                inst:PushEvent("putglasses")
            end)

            inst:DoTaskInTime(.6, function()
                if not inst.glasses_status then
                    inst.glasses_status = true
                    inst.PutGlasses(inst, skinname)
                else
                    inst.AnimState:ClearOverrideSymbol("face")
                    inst.glasses_status = false
                end
			end)
		end
	end
end

local function HairsFn(inst, skinname)
    if inst.components.health ~= nil and inst.components.health:IsDead() and inst.sg:HasStateTag("dead") or inst:HasTag("playerghost") then
        return
    end

    if not (inst.sg:HasStateTag("doing") or inst.components.inventory:IsHeavyLifting()) then
        if inst.hair_bit == 1 then 
            inst.components.talker:Say("My hair isn't long enough for this.")
            return
        end

        if (inst.sg:HasStateTag("idle") or inst:HasTag("idle")) and not (inst.sg:HasStateTag("moving") or inst:HasTag("moving")) and not inst.components.timer:TimerExists("change_hair_cd") then
            inst.components.timer:StartTimer("change_hair_cd",1.4)

            inst:DoTaskInTime(.1, function()
                inst:PushEvent("changehair")
            end)

			inst:DoTaskInTime(1, function()
                inst.hair_type = (inst.hair_type % #inst.HAIR_TYPES) + 1
                inst.OnChangeHair(inst, skinname)
            end)
		end
	end
end

AddModRPCHandler("manutsawee", "levelcheck", LevelCheckFn)
AddModRPCHandler("manutsawee", "skill1", Skill1Fn)
AddModRPCHandler("manutsawee", "skill2", Skill2Fn)
AddModRPCHandler("manutsawee", "skill3", Skill3Fn)
AddModRPCHandler("manutsawee", "counterattack", CounterAttackFn)
AddModRPCHandler("manutsawee", "quicksheath", QuickSheathFn)
AddModRPCHandler("manutsawee", "skillcancel", SkillCancelFn)
AddModRPCHandler("manutsawee", "glasses", GlassesFn)
AddModRPCHandler("manutsawee", "hairs", HairsFn)
