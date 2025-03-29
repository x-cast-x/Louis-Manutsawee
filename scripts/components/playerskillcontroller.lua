--------------------------------------------------------------------------
--[[ Player Skill Controller Status class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

    assert(TheWorld.ismastersim, "Player Skill Controller should not exist on client")

    --------------------------------------------------------------------------
    --[[ Dependencies ]]
    --------------------------------------------------------------------------

    local Skill_Settings = require("utils/manutsawee_extensions").Skill_Settings

    --------------------------------------------------------------------------
    --[[ Member variables ]]
    --------------------------------------------------------------------------

    -- Public
    self.inst = inst

    -- Private
    local register_skills = {}
    local register_skill_cooldown_done_effect = {}

    --------------------------------------------------------------------------
    --[[ Private member functions ]]
    --------------------------------------------------------------------------

    --------------------------------------------------------------------------
    --[[ Private event handlers ]]
    --------------------------------------------------------------------------

    local function OnTimerDone(inst, data)
        local name = data.name
        if name ~= nil then
            for k, v in pairs(register_skill_cooldown_done_effect) do
                if name == k then
                    local fx = SpawnPrefab(v)
                    fx.Transform:SetScale(.9, .9, .9)
                    fx.entity:AddFollower()
                    fx.Follower:FollowSymbol(inst.GUID, "swap_body", 0, 0, 0)
                    break
                end
            end
        end
    end

    --------------------------------------------------------------------------
    --[[ Public member functions ]]
    --------------------------------------------------------------------------

    function self:RegisterSkillCooldownDoneEffect(skillname, fx)
        register_skill_cooldown_done_effect[skillname] = fx
    end

    function self:RegisterSkill(name, tag, time, mindpower, fn)
        register_skills[name] = function(inst)
            fn(inst)
            inst:RemoveTag(tag)
            inst.components.kenjutsuka:SetMindpower(inst.components.kenjutsuka:GetMindpower() - mindpower)
            inst.components.timer:StartTimer(name, time)
        end
    end

    function self:DeactivateSkill()
        for k, v in pairs(register_skills) do
            if inst:HasTag(k) then
                inst:RemoveTag(k)
            end
        end

        inst.inspskill = nil
        inst.components.combat:SetRange(TUNING.DEFAULT_ATTACK_RANGE)
        inst.components.combat:EnableAreaDamage(false)
        inst.AnimState:SetDeltaTimeMultiplier(1)
    end

    function self:ActivateSkill(name ,target)
        local HasAnyTag = {"prey", "bird", "buzzard", "butterfly"}
        if target ~= nil and (target:HasOneOfTags(HasAnyTag) and not target:HasTag("hostile")) then
            inst.sg:GoToState("idle")
            inst.components.playerskillcontroller:DeactivateSkill()
            inst.components.talker:Say(STRINGS.SKILL.REFUSE_RELEASE)
            return false
        end

        return register_skills[name] ~= nil and register_skills[name]
    end

    --------------------------------------------------------------------------
    --[[ Save/Load ]]
    --------------------------------------------------------------------------



    --------------------------------------------------------------------------
    --[[ OnRemoveEntity ]]
    --------------------------------------------------------------------------

    function self:OnRemoveEntity()
        for k, v in pairs(register_skills) do
            if inst:HasTag(k) then
                inst:RemoveTag(k)
            end
        end

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

    --------------------------------------------------------------------------
    --[[ Post initialization ]]
    --------------------------------------------------------------------------


    --------------------------------------------------------------------------
    --[[ End ]]
    --------------------------------------------------------------------------

end)
