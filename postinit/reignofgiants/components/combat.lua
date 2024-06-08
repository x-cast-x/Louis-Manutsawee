local Combat = require("components/combat")
local SkillUtil = require("utils/skillutil")
GLOBAL.setfenv(1, GLOBAL)

-- local _DoAttack = Combat.DoAttack
-- function Combat:DoAttack(targ, weapon, projectile, stimuli, instancemult, instrangeoverride, instpos, ...)
--     if weapon ~= nil and weapon:HasTag("tenseiga") then
--         return
--     end
--     return _DoAttack(self, targ, weapon, projectile, stimuli, instancemult, instrangeoverride, instpos, ...)
-- end

local blockcount = 0
local function BlockActive(inst)
    if inst.blockactive ~= nil then
        inst.blockactive:Cancel()
        inst.blockactive = nil
    end
end

local function OnAfterSkill(inst)
    if self.inst.mafterskillndm ~= nil then
        self.inst.mafterskillndm:Cancel()
        self.inst.mafterskillndm = nil
    end
end

local _GetAttacked = Combat.GetAttacked
function Combat:GetAttacked(attacker, damage, weapon, stimuli, spdamage, ...)
    if not self.inst:HasTag("kenjutsuka") then
        return _GetAttacked(self, attacker, damage, weapon, stimuli, spdamage)
    end

    if attacker ~= nil then
        self.inst:ForceFacePoint(attacker.Transform:GetWorldPosition())
    end

    if weapon ~= nil and (self.inst.mafterskillndm ~= nil and not self.inst.sg:HasStateTag("mdashing")) then
        self.inst.mafterskillndm = self.inst:DoTaskInTime(1.5, function(inst)
            inst.mafterskillndm = nil
        end)
        if blockcount > 0 then
            blockcount = 0
            BlockActive(self.inst)
            self.inst:PushEvent("heavenlystrike")
            if attacker.components.combat ~= nil then
                --inst.components.combat:DoAttack(attacker)
                SkillUtil.AoeAttack(self.inst, 2,3)
                SkillUtil.GroundPoundFx(self.inst, .6)
                SkillUtil.SlashFx(self.inst, attacker, "shadowstrike_slash_fx", 1.6)
                OnAfterSkill(self.inst)
            end
        else
            self.inst:PushEvent("blockparry")
            blockcount = blockcount + 1
            BlockActive(self.inst)
            self.inst.blockactive = self.inst:DoTaskInTime(3, function()
                blockcount = 0
            end)
        end
    end

    if self.inst.sg:HasStateTag("mdashing") or self.inst.inspskill then
        SkillUtil.AddFollowerFx(self.inst, "electricchargedfx")
    elseif self.inst.sg:HasStateTag("counteractive") then
        SkillUtil.GroundPoundFx(self.inst, .6)
        self.inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
        local sparks = SpawnPrefab("sparks")
        sparks.Transform:SetPosition(self.inst:GetPosition():Get())
        self.inst.sg:GoToState("counter_attack", attacker)
        self.inst.components.timer:StartTimer("counter_attack", M_CONFIG.COUNTER_ATK_COOLDOWN)
    else
        return _GetAttacked(self, attacker, damage, weapon, stimuli, spdamage)
    end
end

local _StartAttack = Combat.StartAttack
function Combat:StartAttack(...)
    _StartAttack(self, ...)
    if self.inst:HasTag("kenjutsuka") and self.inst:HasTag("kenjutsu") and self.target ~= nil then
        for _, v in pairs(M_SKILLS) do
            if self.inst:HasTag(v) then
                local fn = self.inst.components.skillreleaser:GetSkillFn(v)
                if type(fn) == "function" then
                    fn(self.inst)
                    break
                end
            end
        end
    end
end
