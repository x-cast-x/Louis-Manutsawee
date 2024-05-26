--------------------------------------------------------------------------
--[[ Skill Releaser Status class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

    assert(TheWorld.ismastersim, "Skill Releaser should not exist on client")

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

    local skills = {}

    local skill_fxs = {
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

    local function CooldownSkillFx(inst, fx)
        local fx = SpawnPrefab(fx)
        fx.Transform:SetScale(.9, .9, .9)
        fx.entity:AddFollower()
        fx.Follower:FollowSymbol(inst.GUID, "swap_body", 0, 0, 0)
    end

    --------------------------------------------------------------------------
    --[[ Private event handlers ]]
    --------------------------------------------------------------------------

    local function OnTimerDone(inst, data)
        local name = data.name
        if name ~= nil then
            for k, v in pairs(skill_fxs) do
                if name == k then
                    CooldownSkillFx(inst, v)
                    break
                end
            end
        end
    end

    --------------------------------------------------------------------------
    --[[ Initialization ]]
    --------------------------------------------------------------------------

    -- Register events

    self.inst:ListenForEvent("timerdone", OnTimerDone)

    --------------------------------------------------------------------------
    --[[ Post initialization ]]
    --------------------------------------------------------------------------



    --------------------------------------------------------------------------
    --[[ Public member functions ]]
    --------------------------------------------------------------------------

    function self:AddCooldownSkillFx(skill, fx)
        if checkstring(skill) and checkstring(fx) then
            skill_fxs[skill] = fx
        end
    end

    function self:AddSkill(skill_name, fn)
        skills[skill_name] = fn
    end

    function self:AddSkills(skills)
        if checkentity(skills) then
            for k, v in pairs(skills) do
                local name = string.lower(k)
                local fn = SkillUtil.Skill_CommonFn(v.tag, name, v.time, v.mindpower, v.fn)
                self:AddSkill(name, fn)
            end
        end
    end

    function self:SkillRemove()
        for _, tag in ipairs(M_SKILLS) do
            if self.inst:HasTag(tag) then
                self.inst:RemoveTag(tag)
            end
        end

        if self.inst.mafterskillndm ~= nil then
            self.inst.mafterskillndm:Cancel()
            self.inst.mafterskillndm = nil
        end

        self.inst.inspskill = nil
        self.inst.components.combat:SetRange(self.inst._hitrange)
        self.inst.components.combat:EnableAreaDamage(false)
        self.inst.AnimState:SetDeltaTimeMultiplier(1)
    end

    function self:CanUseSkill(target)
        local HasAnyTag = {"prey", "bird", "buzzard", "butterfly"}
        return target ~= nil and (target:HasOneOfTags(HasAnyTag) and not target:HasTag("hostile")) or nil
    end

    --------------------------------------------------------------------------
    --[[ Save/Load ]]
    --------------------------------------------------------------------------



    --------------------------------------------------------------------------
    --[[ OnRemoveEntity ]]
    --------------------------------------------------------------------------

    function self:OnRemoveEntity()
        for _, tag in ipairs(M_SKILLS) do
            if self.inst:HasTag(tag) then
                self.inst:RemoveTag(tag)
            end
        end

        self.inst:RemoveEventCallback("timerdone", OnTimerDone)
    end

    --------------------------------------------------------------------------
    --[[ Debug ]]
    --------------------------------------------------------------------------



    --------------------------------------------------------------------------
    --[[ End ]]
    --------------------------------------------------------------------------

end)
