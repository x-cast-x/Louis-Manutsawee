local blockcount = 0
local SkillUtil = require("utils/skillutil")

local function DoCombatPostInit(inst)
    local self = inst.components.combat
    local _GetAttacked = self.GetAttacked

    function self:GetAttacked(attacker, damage, weapon, stimuli, spdamage)
        if weapon ~= nil and weapon:HasTag("tenseiga") then
            return
        end

        if attacker == nil or damage == nil or (inst.components.sleeper ~= nil and inst.components.sleeper:IsAsleep()) or (inst.components.freezable and inst.components.freezable:IsFrozen()) then
            return _GetAttacked(self, attacker, damage, weapon, stimuli, spdamage)
        end
        if attacker ~= nil then
            inst:ForceFacePoint(attacker.Transform:GetWorldPosition())
        end

        if weapon ~= nil and (inst.mafterskillndm ~= nil and not inst.sg:HasStateTag("mdashing")) then
            inst.mafterskillndm = inst:DoTaskInTime(1.5, function()
                inst.mafterskillndm = nil
            end)
            if blockcount > 0 then
                blockcount = 0
                if inst.blockactive ~= nil then
                    inst.blockactive:Cancel()
                    inst.blockactive = nil
                end
                inst:PushEvent("heavenlystrike")
                if attacker.components.combat ~= nil then
                    --inst.components.combat:DoAttack(attacker)
                    SkillUtil.AoeAttack(inst, 2,3)
                    SkillUtil.GroundPoundFx(inst, .6)
                    SkillUtil.SlashFx(inst, attacker, "shadowstrike_slash_fx", 1.6)
                    if inst.mafterskillndm ~= nil then
                        inst.mafterskillndm:Cancel()
                        inst.mafterskillndm = nil
                    end
                end
                return
            end
            inst:PushEvent("blockparry")
            blockcount = blockcount + 1
            if inst.blockactive ~= nil then
                inst.blockactive:Cancel()
                inst.blockactive = nil
            end
            inst.blockactive = inst:DoTaskInTime(3, function()
                blockcount = 0
            end)
            return
        end

        if inst.sg:HasStateTag("mdashing") or inst.inspskill ~= nil then
            SkillUtil.AddFollowerFx(inst, "electricchargedfx")
        elseif inst.sg:HasStateTag("counteractive") then
            SkillUtil.GroundPoundFx(inst, .6)
            inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
            local sparks = SpawnPrefab("sparks")
            sparks.Transform:SetPosition(inst:GetPosition():Get())
            inst.sg:GoToState("counter_attack", attacker)
            inst.components.timer:StartTimer("counter_attack", M_CONFIG.COUNTER_ATK_COOLDOWN)
        else
            return _GetAttacked(self, attacker, damage, weapon, stimuli, spdamage)
        end
    end

    local _StartAttack = self.StartAttack
    function self:StartAttack(...)
        _StartAttack(self, ...)
        if inst:HasTag("kenjutsu") and self.target ~= nil then
            for _, v in pairs(M_SKILLS) do
                if inst:HasTag(v) then
                    local fn = inst.components.skillreleaser.skills[v]
                    fn(inst)
                    break
                end
            end
        end
    end
end

local function CooldownSkillFx(inst, fx)
    if fx == nil then
        fx = "ghostlyelixir_retaliation_dripfx"
    end
    local fx = SpawnPrefab(fx)
    fx.Transform:SetScale(.9, .9, .9)
    fx.entity:AddFollower()
    fx.Follower:FollowSymbol(inst.GUID, "swap_body", 0, 0, 0)
end

local fxs = {
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

local function OnTimerDone(inst, data)
    local name = data.name
    if name ~= nil then
        for k, v in pairs(fxs) do
            if name == k then
                CooldownSkillFx(inst, v)
                break
            end
        end
	end
end

local SkillReleaser = Class(function(self, inst)
    self.inst = inst

    self.skills = {}

    self.inst:ListenForEvent("timerdone", OnTimerDone)
end)

function SkillReleaser:OnRemoveEntity()
    for _, tag in ipairs(M_SKILLS) do
        if self.inst:HasTag(tag) then
            self.inst:RemoveTag(tag)
        end
    end

    self.inst:RemoveEventCallback("timerdone", OnTimerDone)
end

function SkillReleaser:AddCooldownSkillFx(skill, fx)
    if type(skill) == "string" and type(fx) == "string" then
        fxs[skill] = fx
    end
end

function SkillReleaser:AddSkill(skill_name, fn)
    self.skills[skill_name] = fn
end

function SkillReleaser:AddSkills(skills)
    if type(skills) == "table" then
        for k, v in pairs(skills) do
            local name = string.lower(k)
            local fn = SkillUtil.Skill_CommonFn(self.inst, v.tag, name, v.time, v.mindpower, v.fn)
            self:AddSkill(name, fn)
        end
    end
end

function SkillReleaser:OnPostInit()
    DoCombatPostInit(self.inst)
end

function SkillReleaser:SkillRemove()
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
    self.inst.components.combat:SetRange(self.inst._range)
    self.inst.components.combat:EnableAreaDamage(false)
    self.inst.AnimState:SetDeltaTimeMultiplier(1)
end

function SkillReleaser:CanUseSkill(target, rpc)
    if rpc then
        local inst = self.inst

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
    else
        if target == nil then
            return false
        end
        local is_vaild_target = target:HasOneOfTags({"prey", "bird", "buzzard", "butterfly"})
        local canskill = (is_vaild_target and not target:HasTag("hostile") and true) or nil
        return canskill
    end
end

-- function SkillReleaser:GetDebugString()
-- end

return SkillReleaser
