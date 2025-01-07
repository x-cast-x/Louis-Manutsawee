--------------------------------------------------------------------------
--[[ Player Skill Manager Status class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

    assert(TheWorld.ismastersim, "Player Skill Manager should not exist on client")

    --------------------------------------------------------------------------
    --[[ Dependencies ]]
    --------------------------------------------------------------------------

    local SkillUtil = require("utils/skillutil")

    --------------------------------------------------------------------------
    --[[ Member variables ]]
    --------------------------------------------------------------------------

    -- Public
    self.inst = inst

    -- Private

    local register_skills = {}

    local register_skill_cooldown_effect = {
        ["ichimonji"] = "ghostlyelixir_retaliation_dripfx",
        ["flip"] = "ghostlyelixir_shield_dripfx",
        ["thrust"] = "ghostlyelixir_speed_dripfx",
        ["counter_attack"] = "battlesong_instant_panic_fx",
        ["isshin"] = "monkey_deform_pre_fx",
        ["heavenlystrike"] = "fx_book_birds",
        ["ryusen"] = "fx_book_birds",
        ["susanoo"] = "fx_book_birds",
        ["soryuha"] = "thunderbird_fx_idle",
    }

    --------------------------------------------------------------------------
    --[[ Private member functions ]]
    --------------------------------------------------------------------------

    --------------------------------------------------------------------------
    --[[ Private event handlers ]]
    --------------------------------------------------------------------------

    local function OnTimerDone(inst, data)
        local name = data.name
        if name ~= nil then
            for k, v in pairs(register_skill_cooldown_effect) do
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

    function self:RegisterSkillCooldownEffect(skill, fx)
        register_skill_cooldown_effect[skill] = fx
    end

    function self:RegisterSkill(name, tag, time, mindpower, fn)
        register_skills[name] = function()
            fn(inst)
            inst:RemoveTag(tag)
            inst.components.kenjutsuka:SetMindpower(inst.components.kenjutsuka:GetMindpower() - mindpower)
            inst.components.timer:StartTimer(name, time)
        end
    end

    function self:RegisterSkills(t)
        for k, v in pairs(t) do
            self:RegisterSkill(string.lower(k), v.tag, v.time, v.mindpower, v.fn)
        end
    end

    function self:RemoveAllSkills()
        for _, tag in ipairs(M_SKILLS) do
            if inst:HasTag(tag) then
                inst:RemoveTag(tag)
            end
        end

        inst.inspskill = nil
        inst.components.combat:SetRange(TUNING.DEFAULT_ATTACK_RANGE)
        inst.components.combat:EnableAreaDamage(false)
        inst.AnimState:SetDeltaTimeMultiplier(1)
    end

    function self:CanActivateSkill(target)
        local HasAnyTag = {"prey", "bird", "buzzard", "butterfly"}
        return target ~= nil and (target:HasOneOfTags(HasAnyTag) and not target:HasTag("hostile")) or nil
    end

    function self:ActivateSkill(name ,target)
        if self:CanActivateSkill(target) then
            inst.sg:GoToState("idle")
            inst.components.playerskillmanager:RemoveAllSkills()
            inst.components.talker:Say(STRINGS.SKILL.REFUSE_RELEASE)
            return nil
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
        for _, tag in ipairs(M_SKILLS) do
            if inst:HasTag(tag) then
                inst:RemoveTag(tag)
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

    inst:ListenForEvent("mounted", self.RemoveAllSkills)
    inst:ListenForEvent("timerdone", OnTimerDone)

    --------------------------------------------------------------------------
    --[[ Post initialization ]]
    --------------------------------------------------------------------------

    self:AddSkills(SkillUtil.Skill_Data)

    --------------------------------------------------------------------------
    --[[ End ]]
    --------------------------------------------------------------------------

end)
