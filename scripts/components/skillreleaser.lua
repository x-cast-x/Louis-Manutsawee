local blockcount = 0

local function DoCombatPostInit(self, inst)
    local combat = inst.components.combat
    local _GetAttacked = combat.GetAttacked

    function combat:GetAttacked(attacker, damage, weapon, stimuli, spdamage)
        if attacker == nil or damage == nil or (inst.components.sleeper ~= nil and inst.components.sleeper:IsAsleep()) or (inst.components.freezable and inst.components.freezable:IsFrozen()) then
            return _GetAttacked(combat, attacker, damage, weapon, stimuli, spdamage)
        end
        if attacker ~= nil then
            inst:ForceFacePoint(attacker.Transform:GetWorldPosition())
        end

        local pweapon = combat:GetWeapon()
        if pweapon ~= nil and (inst.mafterskillndm ~= nil and not inst.sg:HasStateTag("mdashing")) then
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
                    M_Util.AoeAttack(inst, 2,3)
                    M_Util.GroundPoundFx(inst, .6)
                    M_Util.SlashFx(inst, attacker, "shadowstrike_slash_fx", 1.6)
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
            local electricfx = SpawnPrefab("electricchargedfx")
            electricfx.Transform:SetScale(.7, .7, .7)
            electricfx.entity:AddFollower()
            electricfx.Follower:FollowSymbol(inst.GUID, "swap_body", 0, 0, 0)
        elseif inst.sg:HasStateTag("counteractive") then
            M_Util.GroundPoundFx(inst, .6)
            inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
            local sparks = SpawnPrefab("sparks")
            sparks.Transform:SetPosition(inst:GetPosition():Get())
            inst.skill_target = attacker
            inst.sg:GoToState("mcounterattack", inst.skill_target)
            inst.components.timer:StartTimer("skillcountercd", M_CONFIG.COUNTER_ATK_COOLDOWN)
        else
            return _GetAttacked(combat, attacker, damage, weapon, stimuli, spdamage)
        end
    end

    local _StartAttack = combat.StartAttack
    function combat:StartAttack(...)
        _StartAttack(combat, ...)
        if combat.target ~= nil then
            local target = combat.target
            local weapon = combat:GetWeapon()

            if weapon ~= nil and weapon.components.weapon ~= nil then
                for _, v in pairs(M_SKILLS) do
                    if inst:HasTag(v) then
                        self.skills[v](inst, target, weapon)
                        break
                    end
                end
            end
        end
    end
end

local SkillReleaser = Class(function(self, inst)
    self.inst = inst

    self.mindpower = 0
    self.max_mindpower = M_CONFIG.MIND_MAX
    self.canuseskill = nil
    self.skills = {}
end)

function SkillReleaser:AddSkill(skill_name, fn)
    self.skills[skill_name] = fn
end

function SkillReleaser:OnPostInit()
    DoCombatPostInit(self, self.inst)
end

function SkillReleaser:SkillRemove()
    for _, tag in ipairs(M_SKILLS) do
        if self.inst:HasTag(tag) then
            self.inst:RemoveTag(tag)
            break
        end
    end
end

function SkillReleaser:CanUseSkill(target)
    if (target:HasTag("prey") or target:HasTag("bird") or target:HasTag("buzzard") or target:HasTag("butterfly")) and not target:HasTag("hostile") then
        self.inst.mcanskill = true
    else
        self.inst.mcanskill = nil
    end
end

function SkillReleaser:CancelSkill(inst)
    inst.sg:GoToState("idle")
    self:SkillRemove()
end

function SkillReleaser:OnSave(inst)

end

function SkillReleaser:OnLoad(inst, data)

end

return SkillReleaser
