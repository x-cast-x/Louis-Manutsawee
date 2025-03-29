local function ActivateSkill(inst, skillName, requiredLevel, requiredMindpower, cooldownTimerName, cooldownMessage, combatRange, startMessage, skillTag, levelVariableName)
    local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if inst.components.kenjutsuka:GetKenjutsuLevel() < requiredLevel then
        inst.components.talker:Say(STRINGS.SKILL.UNLOCK_SKILL..requiredLevel, 1, true)
        SkillRemove(inst)
        return
    elseif inst.components.kenjutsuka:GetMindpower() >= requiredMindpower then
        if CheckSkillCooldown(inst, cooldownTimerName, cooldownMessage) then
            return
        end
        SkillRemove(inst)
        inst:AddTag(skillTag)
        inst.components.combat:SetRange(combatRange)
        inst.components.talker:Say(startMessage..inst.components.kenjutsuka:GetMindpower().."/"..requiredMindpower.."\n ", 1, true)
        return
    else
        WarnMindpowerNotEnough(inst, requiredMindpower)
        return
    end
end

local function ActivateSkill(inst, skillName, requiredLevel, requiredMindpower, cooldownTimerName, combatRange, startMessage, skillTag, levelVariableName)
    local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if inst.components.kenjutsuka:GetKenjutsuLevel() < requiredLevel then
        inst.components.talker:Say(STRINGS.SKILL.UNLOCK_SKILL..requiredLevel, 1, true)
        SkillRemove(inst)
        return
    elseif inst.components.kenjutsuka:GetMindpower() >= requiredMindpower then
        if CheckSkillCooldown(inst, cooldownTimerName, STRINGS.SKILL.TIER3_COOLDOWN) then -- 假设 Skill 6/7 共用 TIER3_COOLDOWN
            return
        end
        SkillRemove(inst) -- 移除之前的技能状态
        inst:AddTag(skillTag)
        inst.components.combat:SetRange(combatRange)
        inst.components.talker:Say(startMessage..inst.components.kenjutsuka:GetMindpower().."/"..requiredMindpower.."\n ", 1, true)
        return
    else
        WarnMindpowerNotEnough(inst, requiredMindpower)
        return
    end
end

local function ActivateSkill(inst, skillName, requiredLevel, requiredMindpower, cooldownTimerName, cooldownMessage, combatRange, startMessage, skillTag, levelVariableName)
    local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if inst.components.kenjutsuka:GetKenjutsuLevel() < requiredLevel then
        inst.components.talker:Say(STRINGS.SKILL.UNLOCK_SKILL..requiredLevel, 1, true)
        SkillRemove(inst)
        return
    elseif inst.components.kenjutsuka:GetMindpower() >= requiredMindpower then
        if CheckSkillCooldown(inst, cooldownTimerName, cooldownMessage) then
            return
        end
        SkillRemove(inst)
        inst:AddTag(skillTag)
        inst.components.combat:SetRange(combatRange)
        inst.components.talker:Say(startMessage..inst.components.kenjutsuka:GetMindpower().."/"..requiredMindpower.."\n ", 1, true)
        return
    else
        WarnMindpowerNotEnough(inst, requiredMindpower)
        return
    end
end
