local function OnAttackCommonFn(inst, owner, target)
    if owner.components.rider and owner.components.rider:IsRiding() then
        return
    end

    if not inst.weaponstatus and inst:HasTag("iai") then
        inst.UnsheathMode(inst)
        if target.components.combat ~= nil then
            target.components.combat:GetAttacked(owner, inst.components.weapon.damage * .8)
        end
    end

    if owner:HasTag("kenjutsu") and not inst:HasTag("mkatana") then
        inst:AddTag("mkatana")
    end

    if math.random(1,4) == 1 then
        local x = math.random(1, 1.2)
        local y = math.random(1, 1.2)
        local z = math.random(1, 1.2)
        local slash = {"shadowstrike_slash_fx","shadowstrike_slash2_fx"}

        slash = SpawnPrefab(slash[math.random(1,2)])
        slash.Transform:SetPosition(target:GetPosition():Get())
        slash.Transform:SetScale(x, y, z)
    end

    inst.components.weapon.attackwear = inst.IsShadow(target) and TUNING.GLASSCUTTER.SHADOW_WEAR or 1
end

local function GroundPoundFx(inst, scale)
    local x, y, z = inst.Transform:GetWorldPosition()
    local fx = SpawnPrefab("groundpoundring_fx")
    fx.Transform:SetScale(scale, scale, scale)
    fx.Transform:SetPosition(x, y, z)
end

local function SlashFx(inst, target, prefab, scale)
    local fx = SpawnPrefab(prefab)
    fx.Transform:SetScale(scale, scale, scale)
    fx.Transform:SetPosition(target:GetPosition():Get())
    inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
    inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe")
end

local function AoeAttack(inst, damage, range)
    local CANT_TAGS = { "INLIMBO", "invisible", "NOCLICK",  }
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, range, nil, CANT_TAGS)
    local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

    for _ ,v in pairs(ents) do
        if (v and v:HasTag("bird")) then
            v.sg:GoToState("stunned")
        end

        if v ~= nil and not v:IsInLimbo() and v:IsValid() and v.components.health ~= nil and v.components.combat ~= nil and not v.components.health:IsDead() then
            if not (v:HasTag("player") or v:HasTag("structure") or v:HasTag("companion") or v:HasTag("abigial") or v:HasTag("wall")) then
                if weapon ~= nil then
                    v.components.combat:GetAttacked(inst, weapon.components.weapon.damage*damage)
                end
                if v.components.freezable ~= nil then
                    v.components.freezable:SpawnShatterFX()
                end
            end
        elseif v ~= nil and v:HasTag("tree") or v:HasTag("stump") and not v:HasTag("structure") then
            if v.components.workable ~= nil then
                v.components.workable:WorkedBy(inst, 10)
            end
        end
    end
end

local function AddFollowerFx(inst, prefab, scale)
    local fx = SpawnPrefab(prefab)
    fx.entity:AddFollower()
    fx.Follower:FollowSymbol(inst.GUID, "swap_body", 0, 0, 0)
    if scale ~= nil then
        fx.Transform:SetScale(scale, scale, scale)
    end
end

local function Skill_CommonFn(inst, tag, name, time, mindpower, fn)
    return function()
        if inst.components.skillreleaser:CanUseSkill(inst.components.combat.target) then
            inst.sg:GoToState("idle")
            inst.components.skillreleaser:SkillRemove()
            inst:DoTaskInTime(.3, function()
                inst.components.talker:Say(STRINGS.SKILL.REFUSE_RELEASE)
            end)
            return
        end

        if inst.mafterskillndm ~= nil then
            inst.mafterskillndm:Cancel()
            inst.mafterskillndm = nil
        end

        fn(inst)

        inst.components.kenjutsuka:SetMindpower(inst.components.kenjutsuka:GetMindpower() - mindpower)
        inst.components.timer:StartTimer(name, time)

        inst:RemoveTag(tag)
    end
end

return {
    OnAttackCommonFn = OnAttackCommonFn,
    SlashFx = SlashFx,
    GroundPoundFx = GroundPoundFx,
    AoeAttack = AoeAttack,
    AddFollowerFx = AddFollowerFx,
    Skill_CommonFn = Skill_CommonFn,
}
