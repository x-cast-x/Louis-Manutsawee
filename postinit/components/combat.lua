local SkillUtil = require("utils/skillutil")
local AddComponentPostInit = AddComponentPostInit
GLOBAL.setfenv(1, GLOBAL)

local blockcount = 0
local function BlockActive(inst)
    if inst.blockactive ~= nil then
        inst.blockactive:Cancel()
        inst.blockactive = nil
    end
end

AddComponentPostInit("combat", function(self, inst)

    local _GetAttacked = self.GetAttacked
    function self:GetAttacked(attacker, damage, weapon, stimuli, spdamage, ...)
        if not inst:HasTag("kenjutsuka") then
            return _GetAttacked(self, attacker, damage, weapon, stimuli, spdamage, ...)
        end

        if attacker ~= nil then
            inst:ForceFacePoint(attacker.Transform:GetWorldPosition())
        end

        if weapon ~= nil and (not inst.sg:HasStateTag("mdashing")) then
            if blockcount > 0 then
                blockcount = 0
                BlockActive(inst)
                inst:PushEvent("heavenlystrike")
                if attacker.components.combat ~= nil then
                    --inst.components.combat:DoAttack(attacker)
                    SkillUtil.AoeAttack(inst, 2,3)
                    SkillUtil.GroundPoundFx(inst, .6)
                    SkillUtil.SlashFx(inst, attacker, "shadowstrike_slash_fx", 1.6)
                end
            else
                inst:PushEvent("blockparry")
                blockcount = blockcount + 1
                BlockActive(inst)
                inst.blockactive = inst:DoTaskInTime(3, function()
                    blockcount = 0
                end)
            end
        end

        if inst.sg:HasStateTag("mdashing") or inst.inspskill then
            SkillUtil.AddFollowerFx(inst, "electricchargedfx")
        elseif inst.sg:HasStateTag("counteractive") then

            inst.sg:GoToState("counter_attack", attacker)

        else
            return _GetAttacked(self, attacker, damage, weapon, stimuli, spdamage, ...)
        end
    end

end)
