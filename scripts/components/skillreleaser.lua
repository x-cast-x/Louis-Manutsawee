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
        if self.inst:HasTag("kenjutsu") and combat.target ~= nil then
            local target = combat.target
            local weapon = combat:GetWeapon()

            if weapon ~= nil and weapon.components.weapon ~= nil then
                for _, v in pairs(M_SKILLS) do
                    if inst:HasTag(v) then
                        local fn = self.skills[v]
                        fn(inst, target, weapon)
                        break
                    end
                end
            end
        end
    end
end

local function CooldownSkillFx(inst, fxnum)
    local fxlist = {
        "ghostlyelixir_retaliation_dripfx",
        "ghostlyelixir_shield_dripfx",
        "ghostlyelixir_speed_dripfx",
        "battlesong_instant_panic_fx",
        "monkey_deform_pre_fx",
        "fx_book_birds",
    }
    local fx = SpawnPrefab(fxlist[fxnum])
    fx.Transform:SetScale(.9, .9, .9)
    fx.entity:AddFollower()
    fx.Follower:FollowSymbol(inst.GUID, "swap_body", 0, 0, 0)
end

local function OnTimerDone(inst, data)
	if data.name ~= nil then
        local name = data.name
        local fxnum

        local fx_data = {
            ["skill1cd"] = 1,
            ["skill2cd"] = 2,
            ["skill3cd"] = 3,
            ["skillcountercd"] = 4,
            ["skillT2cd"] = 5,
            ["skillT3cd"] = 6,
        }

        for i, v in ipairs(fx_data) do
            if name == i then
                fxnum = v
                CooldownSkillFx(inst, fxnum)
                return
                break
            end
        end
	end
end

local SkillReleaser = Class(function(self, inst)
    self.inst = inst

    self.canskill = nil
    self.canuseskill = nil
    self.skills = {}

    self.inst:ListenForEvent("timerdone", OnTimerDone)
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

function SkillReleaser:CanUseSkill(target, inrpc)
    if inrpc then
        local inst = self.inst
        self.canuseskill = false

        local isdead = inst.components.health ~= nil and inst.components.health:IsDead() and (inst.sg:HasStateTag("dead") or inst:HasTag("playerghost"))
        local isasleep = inst.components.sleeper ~= nil and inst.components.sleeper:IsAsleep()
        local isfrozen = inst.components.freezable ~= nil and inst.components.freezable:IsFrozen()
        local isriding = inst.components.rider ~= nil and inst.components.rider:IsRiding()
        local isheavylifting = inst.components.inventory ~= nil and inst.components.inventory:IsHeavyLifting()

        if inst.mafterskillndm ~= nil then
            inst.mafterskillndm:Cancel()
            inst.mafterskillndm = nil
        end
    
        if isdead or isasleep or isfrozen or isriding or isheavylifting then
            return
        end
    
        local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        local weapon_has_tags = weapon:HasOneOfTags({"projectile", "whip", "rangedweapon"})
        local weapon_not_has_tags = not weapon:HasOneOfTags({"tool", "sharp", "weapon", "katanaskill"})
    
        if weapon ~= nil then
            if weapon_has_tags or weapon_not_has_tags then
                return
            end
        else
            return
        end
    
        self.canuseskill = true
    else
        local is_vaild_target = target:HasOneOfTags({"prey", "bird", "buzzard", "butterfly"})
        self.canskill = (is_vaild_target and not target:HasTag("hostile") and true) or nil 
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
