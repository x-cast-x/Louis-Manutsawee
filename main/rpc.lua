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
	inst:RemoveTag("michimonji")
	inst:RemoveTag("mflipskill")
	inst:RemoveTag("mthrustskill")
	inst:RemoveTag("misshin")
	inst:RemoveTag("heavenlystrike")
	inst:RemoveTag("ryusen")
	inst:RemoveTag("susanoo")

	inst.mafterskillndm = nil
	inst.inspskill = nil
	inst.components.combat:SetRange(inst._range)
	inst.components.combat:EnableAreaDamage(false)
	inst.AnimState:SetDeltaTimeMultiplier(1)
end

local function CanUseSkill(inst, weapon)
    inst.canuseskill = false
    if inst.mafterskillndm ~= nil then
        inst.mafterskillndm:Cancel()
        inst.mafterskillndm = nil
    end

    if inst.components.health ~= nil and inst.components.health:IsDead() and (inst.sg:HasStateTag("dead") or inst:HasTag("playerghost")) or (inst.components.sleeper and inst.components.sleeper:IsAsleep()) or (inst.components.freezable and inst.components.freezable:IsFrozen()) then
        return
    end

    if (inst.components.rider:IsRiding() or inst.components.inventory:IsHeavyLifting()) then
        return
    end

    if weapon ~= nil then
        if ( weapon:HasTag("projectile") or weapon:HasTag("whip") or weapon:HasTag("rangedweapon") or not (weapon:HasTag("tool") or  weapon:HasTag("sharp") or  weapon:HasTag("weapon") or  weapon:HasTag("katanaskill")) ) then
            return
        end
    else
        return
    end

    inst.canuseskill = true
end

local function LevelCheckFn(inst)
	if not inst.components.timer:TimerExists("checkCD") then
        inst.components.timer:StartTimer("checkCD",.8)
		if inst.kenjutsulevel < 10 then
			inst.components.talker:Say("󰀍: "..inst.kenjutsulevel.." :"..inst.kenjutsuexp.."/"..inst.kenjutsumaxexp.."\n󰀈: "..inst.mindpower.."/"..inst.max_mindpower.."\n", 2, true)
		else
			inst.components.talker:Say("\n󰀈: "..inst.mindpower.."/"..inst.max_mindpower.."\n", 2, true)
		end
	end
end

local function Skill1Fn(inst)
    if inst.components.timer:TimerExists("sskill1cd") then
        return
    end

    local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    CanUseSkill(inst, equip)

    if not inst.canuseskill then
        return
    end

    if inst.kenjutsulevel < nskill1 then
        inst.components.talker:Say("[UNLOCK] 󰀍: "..nskill1, 1, true)
        return
    end

	inst.components.timer:StartTimer("sskill1cd",1)

	if inst.mindpower >= 3 then
        if inst:HasTag("michimonji") or inst:HasTag("misshin") or inst:HasTag("ryusen") then
            SkillRemove(inst) inst.components.talker:Say("Later...", 1, true)
            return
        elseif inst:HasTag("mflipskill") and equip ~= nil and equip:HasTag("katanaskill") then
            if inst.kenjutsulevel < nskill4 then
                inst.components.talker:Say("[UNLOCK] 󰀍: "..nskill4, 1, true)
                SkillRemove(inst)
            elseif inst.mindpower >= 7 then
                if inst.components.timer:TimerExists("skillT2cd") then
                    inst.components.talker:Say("Tier2: Cooldown", 1, true)
                    SkillRemove(inst)
                    return
                end
                SkillRemove(inst)
                inst:AddTag("misshin")
                inst.components.combat:SetRange(3)
                inst.components.talker:Say(STRINGS.MANUTSAWEESKILLSPEECH.SKILL4START..inst.mindpower.."/7\n ", 1, true)
                return
            else
                inst.components.talker:Say("Not now!\n󰀈: "..inst.mindpower.."/7\n ", 1, true)
                SkillRemove(inst)
                return
            end
        elseif not inst:HasTag("michimonji") then
            if inst.components.timer:TimerExists("skill1cd") then
                inst.components.talker:Say("Cooldown", 1, true)
                SkillRemove(inst)
                return
            end
            SkillRemove(inst)
            inst:AddTag("michimonji")
            inst.components.combat:SetRange(3.5)
            inst.components.talker:Say(STRINGS.MANUTSAWEESKILLSPEECH.SKILL1START..inst.mindpower.."/3\n ", 1, true)
        end
	else
        inst.components.talker:Say("Not now!\n󰀈: "..inst.mindpower.."/3\n ", 1, true)
        SkillRemove(inst)
    end
end

local function Skill2Fn(inst)
    if inst.components.timer:TimerExists("sskill2cd") then
        return
    end

    local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    CanUseSkill(inst, equip)

    if not inst.canuseskill then
        return
    end

    if inst.kenjutsulevel < nskill2 then inst.components.talker:Say("[UNLOCK] 󰀍: "..nskill2, 1, true)
        return
    end

	inst.components.timer:StartTimer("sskill2cd",1)

	if inst.mindpower >= 4 then
        if inst:HasTag("mflipskill") or inst:HasTag("ryusen") or inst:HasTag("susanoo") then
            SkillRemove(inst) inst.components.talker:Say("Later...", 1, true)
            return
        elseif inst:HasTag("michimonji") and equip ~= nil and equip:HasTag("katanaskill") then
            if inst.kenjutsulevel < nskill6 then
                inst.components.talker:Say("[UNLOCK] 󰀍: "..nskill6, 1, true)
                SkillRemove(inst)
            elseif inst.mindpower >= 8 then
                if inst.components.timer:TimerExists("skillT3cd") then
                    inst.components.talker:Say("Tier3: Cooldown", 1, true)
                    SkillRemove(inst)
                    return
                end
                SkillRemove(inst)
                inst:AddTag("ryusen")
                inst.components.combat:SetRange(10)
                inst.components.talker:Say(STRINGS.MANUTSAWEESKILLSPEECH.SKILL6START..inst.mindpower.."/8\n ", 1, true)
                return
            else
                inst.components.talker:Say("Not now!\n󰀈: "..inst.mindpower.."/8\n ", 1, true)
                SkillRemove(inst)
                return
            end
        elseif inst:HasTag("mthrustskill") and equip and equip:HasTag("katanaskill") then
            if inst.kenjutsulevel < nskill7 then
                inst.components.talker:Say("[UNLOCK] 󰀍: "..nskill7, 1, true)
                SkillRemove(inst)
            elseif inst.mindpower >= 10 then
                if inst.components.timer:TimerExists("skillT3cd") then
                    inst.components.talker:Say("Tier3: Cooldown", 1, true)
                    SkillRemove(inst)
                    return
                end
                SkillRemove(inst)
                inst:AddTag("susanoo")
                inst.components.combat:SetRange(3)
                inst.components.talker:Say(STRINGS.MANUTSAWEESKILLSPEECH.SKILL7START..inst.mindpower.."/10\n ", 1, true)
                return
            else
                inst.components.talker:Say("Not now!\n󰀈: "..inst.mindpower.."/10\n ", 1, true)
                SkillRemove(inst)
                return
            end
        elseif not inst:HasTag("mflipskill") then
            if inst.components.timer:TimerExists("skill2cd") then
                inst.components.talker:Say("Cooldown", 1, true)
                SkillRemove(inst)
                return
            end
            SkillRemove(inst)
            inst:AddTag("mflipskill")
            inst.components.combat:SetRange(3.5)
            inst.components.talker:Say(STRINGS.MANUTSAWEESKILLSPEECH.SKILL2START..inst.mindpower.."/4\n ", 1, true)
        end
    else
        inst.components.talker:Say("Not now!\n󰀈: "..inst.mindpower.."/4\n ", 1, true)
        SkillRemove(inst)
    end
end

local function Skill3Fn(inst) ----------  T
    if inst.components.timer:TimerExists("sskill3cd") then
        return
    end

    local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    CanUseSkill(inst, equip)
    if not inst.canuseskill then
        return
    end

    if inst.kenjutsulevel < nskill3 then
        inst.components.talker:Say("[UNLOCK] 󰀍: "..nskill3, 1, true)
        return
    end

	inst.components.timer:StartTimer("sskill3cd",1)

    if inst.mindpower >= 4 then
        if inst:HasTag("heavenlystrike") or inst:HasTag("mthrustskill") or inst:HasTag("susanoo") then
			SkillRemove(inst)
				inst.components.talker:Say("Later...", 1, true)
			return
    	elseif inst:HasTag("mflipskill") and equip and equip:HasTag("katanaskill") then
			if inst.kenjutsulevel < nskill5 then
                inst.components.talker:Say("[UNLOCK] 󰀍: "..nskill5, 1, true)
                SkillRemove(inst)
        	elseif inst.mindpower >= 5 then
                if inst.components.timer:TimerExists("skillT2cd") then
                    inst.components.talker:Say("Tier2: Cooldown", 1, true)
                    SkillRemove(inst)
                    return
                end

                SkillRemove(inst)
                inst:AddTag("heavenlystrike")
                inst.components.combat:SetRange(3)
                inst.components.talker:Say(STRINGS.MANUTSAWEESKILLSPEECH.SKILL5START..inst.mindpower.."/5\n ", 1, true)
                return
			else
                inst.components.talker:Say("Not now!\n󰀈: "..inst.mindpower.."/5\n ", 1, true)
                SkillRemove(inst)
                return
            end
		elseif not inst:HasTag("mthrustskill") then
            if inst.components.timer:TimerExists("skill3cd") then
                inst.components.talker:Say("Cooldown", 1, true) SkillRemove(inst)
                return
            end
			SkillRemove(inst)
            inst:AddTag("mthrustskill")
            inst.components.combat:SetRange(3)
            inst.components.talker:Say(STRINGS.MANUTSAWEESKILLSPEECH.SKILL3START..inst.mindpower.."/4\n ", 1, true)
		end
    else
        inst.components.talker:Say("Not now!\n󰀈: "..inst.mindpower.."/4\n ", 1, true)
        SkillRemove(inst)
    end
end

local function SkillCounterAttackFn(inst)
    if inst.components.timer:TimerExists("skillcountercd") then
        inst.components.talker:Say("Cooldown", 1, true)
        SkillRemove(inst)
        return
    end

    local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    CanUseSkill(inst, equip)

    if not inst.canuseskill then
        return
    end

    if inst.kenjutsulevel < ncountskill then
        inst.components.talker:Say("[UNLOCK] 󰀍: "..ncountskill, 1, true)
        return
    end

    if not inst.components.timer:TimerExists("counterCD") then
        inst.components.timer:StartTimer("counterCD",.63)
        SkillRemove(inst)
        inst.sg:GoToState("counterstart")
    end
end

local function SkillCancelFn(inst)
    if inst.components.timer:TimerExists("cancelskillcd") then
        return
    end

    local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    CanUseSkill(inst, equip)

    if not inst.canuseskill then
        return
    end

    inst.components.timer:StartTimer("cancelskillcd",1)
    SkillRemove(inst)
    inst.components.talker:Say("Maybe next time.", 1, true)
end

local function QuickSheathFn(inst)
    if inst.kenjutsulevel < ncountskill then
        inst.components.talker:Say("[UNLOCK] 󰀍: "..ncountskill, 1, true)
        return
    end

    if inst.components.timer:TimerExists("mQSCd") then
        return
    end

    local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    CanUseSkill(inst, equip)

    if not inst.canuseskill then
        return
    end

	if equip ~= nil and equip.wpstatus ~= nil and equip:HasTag("katanaskill") then
		inst.components.timer:StartTimer("mQSCd",.4)
		inst.sg:GoToState("mquicksheath")
	end
end

local function GlassesFn(inst, skinname)
    if inst.components.health ~= nil and inst.components.health:IsDead() and inst.sg:HasStateTag("dead") or inst:HasTag("playerghost") then
        return
    end

	if not (inst.sg:HasStateTag("doing") or inst.components.inventory:IsHeavyLifting()) then
		if (inst.sg == nil or inst.sg:HasStateTag("idle") or inst:HasTag("idle")) and not (inst.sg:HasStateTag("moving") or inst:HasTag("moving")) and not inst.components.timer:TimerExists("GlassesCD") then
			inst.components.timer:StartTimer("GlassesCD",1)

            inst:DoTaskInTime(.1, function()
                inst:PushEvent("putglasses")
            end)

            inst:DoTaskInTime(.6, function()
                if not inst.glassesstatus then
                    inst.glassesstatus = true
                    inst.PutGlasses(inst, skinname)
                else
                    inst.AnimState:ClearOverrideSymbol("face")
                    inst.glassesstatus = false
                end
			end)
		end
	end
end

local HAIR_TYPES = { "", "_yoto", "_ronin", "_pony", "_twin", "_htwin","_ball"}
local function HairsFn(inst, skinname)
    if inst.components.health ~= nil and inst.components.health:IsDead() and inst.sg:HasStateTag("dead") or inst:HasTag("playerghost") then
        return
    end

    if not (inst.sg:HasStateTag("doing") or inst.components.inventory:IsHeavyLifting()) then
        if inst.hairlong == 1 then inst.components.talker:Say("My hair isn't long enough for this.")
            return
        end

        if (inst.sg == nil or inst.sg:HasStateTag("idle") or inst:HasTag("idle")) and not (inst.sg:HasStateTag("moving") or inst:HasTag("moving")) and not inst.components.timer:TimerExists("HairCD") then
            inst.components.timer:StartTimer("HairCD",1.4)

            inst:DoTaskInTime(.1, function()
                inst:PushEvent("changehair")
            end)

			inst:DoTaskInTime(1, function()
                if inst.hairtype < #HAIR_TYPES then
                    inst.hairtype = inst.hairtype + 1
                    inst.OnChangeHair(inst, skinname)
                else
                    inst.hairtype = 1
                    inst.OnChangeHair(inst, skinname)
                end
			end)
		end
	end
end

AddModRPCHandler("manutsawee", "levelcheck", LevelCheckFn)
AddModRPCHandler("manutsawee", "skill1", Skill1Fn)
AddModRPCHandler("manutsawee", "skill2", Skill2Fn)
AddModRPCHandler("manutsawee", "skill3", Skill3Fn)
AddModRPCHandler("manutsawee", "skillcounterattack", SkillCounterAttackFn)
AddModRPCHandler("manutsawee", "quicksheath", QuickSheathFn)
AddModRPCHandler("manutsawee", "skillcancel", SkillCancelFn)
AddModRPCHandler("manutsawee", "glasses", GlassesFn)
AddModRPCHandler("manutsawee", "Hairs", HairsFn)
