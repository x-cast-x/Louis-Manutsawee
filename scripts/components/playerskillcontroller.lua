--[[ Player Skill Controller Status class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

    assert(TheWorld.ismastersim, "Player Skill Controller should not exist on client")

    --------------------------------------------------------------------------
    --[[ Dependencies ]]
    --------------------------------------------------------------------------

    --------------------------------------------------------------------------
    --[[ Member variables ]]
    --------------------------------------------------------------------------

    -- Public
    self.inst = inst

    -- Private
    local is_active_skill = false

    local registered_skills = {}
    local register_skill_cooldown_done_effect = {}

    local MustTag = {"tool", "sharp", "weapon", "katana"}
    local CantTag = {"projectile", "whip", "rangedweapon"}
    local HasAnyTag = {"prey", "bird", "buzzard", "butterfly", "hostile"}

    --------------------------------------------------------------------------
    --[[ Private member functions ]]
    --------------------------------------------------------------------------

    local CanActivateSkill = function(inst, weapon)
        if not weapon
        or (not inst.components.kenjutsuka)
        or (not inst.components.playerskillcontroller)
        or inst.components.sleeper:IsAsleep()
        or inst.components.freezable:IsFrozen()
        or inst.components.rider:IsRiding()
        or inst.components.inventory:IsHeavyLifting()
        or inst:HasTag("playerghost")
        or weapon:HasOneOfTags(CantTag) and (not weapon:HasOneOfTags(MustTag)) then
            return false
        end

        return true
    end

    local function CheckSkillKeyCooldown(inst, cooldown)
        if inst.components.timer:TimerExists("skill_key_cd") then
            inst.components.talker:Say(cooldown, 1, true)
            return false
        end
        return true
    end

    local function CheckRequireLevel(inst, requiredlevel, currentlevel)
        if currentlevel < requiredlevel then
            inst.components.talker:Say(STRINGS.SKILL.UNLOCK_SKILL .. requiredlevel, 1, true)
            return false
        end
        return true
    end

    local function CheckRequireMindpower(inst, requiredmindpower, currentmindpower)
        if currentmindpower < requiredmindpower then
            inst.components.talker:Say(STRINGS.SKILL.MINDPOWER_NOT_ENOUGH.. currentmindpower .. "/" .. requiredmindpower .. "\n ", 1, true)
            return false
        end
        return true
    end

    local function ActivateSkill(inst, weapen, tag, requiredlevel, currentlevel, requiredmindpower, currentmindpower, cooldown, combatrange, startmessage)
        if CheckSkillKeyCooldown(inst, cooldown) and CheckRequireLevel(inst, requiredlevel, currentlevel) and CheckRequireMindpower(inst, requiredmindpower, currentmindpower) then
            inst:AddTag(tag)
            inst.components.combat:SetRange(combatrange)
            inst.components.talker:Say(startmessage.. currentmindpower .. "/" ..requiredmindpower .. "\n ", 1, true)
            is_active_skill = true
        end
        return false
    end

    local function IsAllowTarget(inst, target)
        if target ~= nil and (target:HasOneOfTags(HasAnyTag)) then
            inst.sg:GoToState("idle")
            inst.components.playerskillcontroller:DeactivateSkill()
            inst.components.talker:Say(STRINGS.SKILL.REFUSE_RELEASE)
            return false
        end
        return true
    end

    local function IsPlayerHasSkillTag(inst, t)
        for k, v in pairs(t) do
            if inst:HasTag(k) then
                return t[k]
            end
            break
        end
    end

    --------------------------------------------------------------------------
    --[[ Private event handlers ]]
    --------------------------------------------------------------------------

    local function OnTimerDone(inst, data)
        local name = data.name
        if name ~= nil then
            if table.containskey(register_skill_cooldown_done_effect, name) then
                local fx = SpawnPrefab(register_skill_cooldown_done_effect[name])
                fx.Transform:SetScale(.9, .9, .9)
                fx.entity:AddFollower()
                fx.Follower:FollowSymbol(inst.GUID, "swap_body", 0, 0, 0)
            end
        end
    end

    local function OnUnEquip(inst, data)
        if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) == nil then
            inst.components.playerskillcontroller:DeactivateSkill()
        end
    end

    --------------------------------------------------------------------------
    --[[ Public member functions ]]
    --------------------------------------------------------------------------

    function self:RegisterSkillCooldownDoneEffect(skillname, fx)
        register_skill_cooldown_done_effect[skillname] = fx
    end

    function self:RegisterSkill(name, tag, time, mindpower, fn)
        assert(type(fn) == "function")

        registered_skills[name] = function(inst)
            fn(inst)
            inst:RemoveTag(tag)
            inst.components.kenjutsuka:SetMindpower(inst.components.kenjutsuka:GetMindpower() - mindpower)
            inst.components.timer:StartTimer(name, time)
        end
    end

    function self:DeactivateSkill()
        for k, v in pairs(registered_skills) do
            if inst:HasTag(k) then
                inst:RemoveTag(k)
            end
        end

        inst.inspskill = nil
        inst.components.combat:SetRange(TUNING.DEFAULT_ATTACK_RANGE)
        inst.components.combat:EnableAreaDamage(false)
        inst.AnimState:SetDeltaTimeMultiplier(1)
    end

    function self:ReleaseSkill(target)
        if inst:HasTag("kenjutsuka") then
            if IsAllowTarget(inst, target) then
                local fn = IsPlayerHasSkillTag(inst, registered_skills)
                if fn ~= nil then
                    fn(inst)
                end
            end
        end
    end

    function self:ActivateSkill(fn, data)
        local weapon = inst.components.inventory ~= nil and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

        if CanActivateSkill(inst, weapon) then
            inst.components.playerskillcontroller:DeactivateSkill()
            inst.components.timer:StartTimer("skill_key_cd", 1)

            if not is_active_skill then
                local currentlevel = inst.components.kenjutsuka:GetLevel()
                local currentmindpower = inst.components.kenjutsuka:GetMindpower()
                local is_katana = weapon:HasTag("katana")
                is_active_skill = ActivateSkill(inst, weapon, data.tag, data.requiredlevel, currentlevel, data.requiredmindpower, currentmindpower, data.cooldown, data.combatrange, data.startmessage)
            else
                inst.components.talker:Say(STRINGS.SKILL.SKILL_LATER, 1, true)
                is_active_skill = false
            end
        end
    end

    --------------------------------------------------------------------------
    --[[ Save/Load ]]
    --------------------------------------------------------------------------



    --------------------------------------------------------------------------
    --[[ OnRemoveEntity ]]
    --------------------------------------------------------------------------

    function self:OnRemoveEntity()
        self:DeactivateSkill()

        inst:RemoveEventCallback("mounted", self.DeactivateSkill)
        inst:RemoveEventCallback("timerdone", OnTimerDone)
    end

    --------------------------------------------------------------------------
    --[[ Debug ]]
    --------------------------------------------------------------------------

    --------------------------------------------------------------------------
    --[[ Initialization ]]
    --------------------------------------------------------------------------

    -- Register events

    inst:ListenForEvent("mounted", self.DeactivateSkill)
    inst:ListenForEvent("timerdone", OnTimerDone)
    inst:ListenForEvent("death", self.DeactivateSkill)
    inst:ListenForEvent("ms_playerreroll", self.DeactivateSkill)
    inst:ListenForEvent("unequip", OnUnEquip)

    --------------------------------------------------------------------------
    --[[ Post initialization ]]
    --------------------------------------------------------------------------

    --------------------------------------------------------------------------
    --[[ End ]]
    --------------------------------------------------------------------------

end)
