local MANUTSAWEE_DAMAGE = 1
local MANUTSAWEE_CRIDMG = 0.1
local hitcount = 0
local criticalrate = 5

local function OnAttackOther(inst, data)
    if inst.components.rider:IsRiding() then
        return
    end

    local target = data.target
    local weapon = data.weapon
    local kenjutsuka = inst.components.kenjutsuka
    local kenjutsuexp = kenjutsuka:GetKenjutsuExp()
    local kenjutsumaxexp = kenjutsuka.kenjutsumaxexp
    local kenjutsulevel = kenjutsuka:GetKenjutsuLevel()
    local mindpower = kenjutsuka:GetMindpower()
    local tx, ty, tz = target.Transform:GetWorldPosition()
    local cant_tags = not (target:HasOneOfTags({"prey", "bird", "insect", "wall"}) and not target:HasTag("hostile"))

    if weapon ~= nil and not weapon:HasTag("projectile") and not weapon:HasTag("rangedweapon") then
        if weapon:HasTag("katanaskill") and not inst.components.timer:TimerExists("hit_cd") and
            not inst.sg:HasStateTag("skilling") then -- GainKenExp
            if kenjutsulevel < 10 then
                kenjutsuexp = kenjutsuexp + (1 * M_CONFIG.KEXPMTP)
            end
            inst.components.timer:StartTimer("hit_cd", .5)
        end

        if cant_tags then
            if math.random(1, 100) <= criticalrate + kenjutsulevel and
                not inst.components.timer:TimerExists("critical_cd") and not inst.sg:HasStateTag("skilling") then
                inst.components.timer:StartTimer("critical_cd", 15 - (kenjutsulevel / 2)) -- critical
                local hitfx = SpawnPrefab("slingshotammo_hitfx_rock")
                if hitfx then
                    hitfx.Transform:SetScale(.8, .8, .8)
                    hitfx.Transform:SetPosition(tx, ty, tz)
                end
                inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
                inst.components.combat.damagemultiplier = (MANUTSAWEE_DAMAGE + MANUTSAWEE_CRIDMG)
                inst:DoTaskInTime(.1, function(inst)
                    inst.components.combat.damagemultiplier = MANUTSAWEE_DAMAGE
                end)
            end
        end

        if cant_tags then
            if not inst.components.timer:TimerExists("heart_cd") and not inst.sg:HasStateTag("skilling") and
                not inst.inspskill then
                inst.components.timer:StartTimer("heart_cd", .3) -- mind gain
                hitcount = hitcount + 1
                if hitcount >= M_CONFIG.MINDREGEN_COUNT and inst.components.kenjutsuka:GetKenjutsuLevel() >= 1 then
                    if mindpower < kenjutsuka:GetMaxMindpower() then
                        kenjutsuka.onmindregenfn(inst, mindpower)
                    else
                        inst.components.sanity:DoDelta(1)
                    end
                    hitcount = 0
                end
            end
        end
    end

    if kenjutsuexp >= kenjutsumaxexp then
        kenjutsuexp = kenjutsuexp - kenjutsumaxexp
        kenjutsuka:KenjutsuLevelUp()
    end
end

local function OnPlayerReroll(inst)
    local kenjutsulevel = inst.components.kenjutsuka:GetKenjutsuLevel()

    inst:SkillRemove()

    if kenjutsulevel > 0 then
        local x, y, z = inst.Transform:GetWorldPosition()
        for i = 1, kenjutsulevel do
            local fruit = SpawnPrefab("mfruit")
            if fruit ~= nil then
                if fruit.Physics ~= nil then
                    local speed = 2 + math.random()
                    local angle = math.random() * 2 * PI
                    fruit.Physics:Teleport(x, y + 1, z)
                    fruit.Physics:SetVel(speed * math.cos(angle), speed * 3, speed * math.sin(angle))
                else
                    fruit.Transform:SetPosition(x, y, z)
                end

                if fruit.components.propagator ~= nil then
                    fruit.components.propagator:Delay(5)
                end
            end
        end
        kenjutsulevel = 0
    end
end

local function OnPostInit(inst)
    local kenjutsuka = inst.components.kenjutsuka
	if kenjutsuka.is_master then
        kenjutsuka.kenjutsulevel = M_CONFIG.LEVEL_VALUE
        kenjutsuka.onupgradefn(inst, kenjutsuka.kenjutsulevel, kenjutsuka.kenjutsuexp)
    end
end

local Kenjutsuka = Class(function(self, inst)
    self.inst = inst

    self.is_master = M_CONFIG.IS_MASTER
	self.kenjutsulevel = 0
	self.kenjutsuexp = 0
	self.kenjutsumaxexp = 250

    self.mindpower = 0
    self.max_mindpower = M_CONFIG.MIND_MAX
    self.mindpower_regen_rate = M_CONFIG.MINDREGEN_RATE

    self.onupgradefn = nil

    self.inst:ListenForEvent("onattackother", OnAttackOther)
    self.inst:ListenForEvent("ms_playerreroll", OnPlayerReroll)

    self.inst:DoTaskInTime(0, OnPostInit)
end)

function Kenjutsuka:OnRemoveFromEntity()
    self:StopRegenMindPower()

    self.inst:RemoveEventCallback("onattackother", OnAttackOther, self.inst)
    self.inst:RemoveEventCallback("ms_playerreroll", OnPlayerReroll, self.inst)
end

function Kenjutsuka:GetDebugString()
    return string.format("Is Kenjutsu Master:%s, Exp:%d, Level:%d, Power:%d", tostring(self.is_master), self.kenjutsuexp, self.kenjutsulevel, self.mindpower)
end

function Kenjutsuka:SetKenjutsuExp(exp)
    self.kenjutsuexp = exp
end

function Kenjutsuka:SetKenjutsuLevel(exp)
    self.kenjutsulevel = exp
end

function Kenjutsuka:SetMindpower(mindpower)
    self.mindpower = mindpower
end

function Kenjutsuka:SetMaxMindpower(mindpower)
    self.max_mindpower = mindpower
end

function Kenjutsuka:SetOnUpgradeFn(fn)
    self.onupgradefn = fn
end

function Kenjutsuka:SetOnMindPowerRegenFn(fn)
    self.onmindregenfn = fn
end

function Kenjutsuka:GetKenjutsuExp()
    return self.kenjutsuexp
end

function Kenjutsuka:GetKenjutsuLevel()
    return self.kenjutsulevel
end

function Kenjutsuka:GetMindpower()
    return self.mindpower
end

function Kenjutsuka:GetMaxMindpower()
    return self.max_mindpower
end

function Kenjutsuka:GetIsMaster()
    return self.is_master
end

function Kenjutsuka:KenjutsuLevelUp()
    if self.onupgradefn ~= nil then
    	self.kenjutsulevel = self.kenjutsulevel + 1
        self.onupgradefn(self.inst, self.kenjutsulevel, self.kenjutsuexp)
    end
end

local function OnRegenMindPower(inst)
    local kenjutsuka = inst.components.kenjutsuka
    if kenjutsuka.mindpower < (kenjutsuka.max_mindpower / 2) then
        kenjutsuka.mindpower = kenjutsuka.mindpower + 1
        kenjutsuka.onmindregenfn(inst, kenjutsuka.mindpower)
    end
    kenjutsuka.regen = inst:DoTaskInTime(kenjutsuka.mindpower_regen_rate, OnRegenMindPower)
end

function Kenjutsuka:StartRegenMindPower()
    self:StopRegenMindPower()

    if self.regen == nil then
        self.regen = self.inst:DoTaskInTime(self.mindpower_regen_rate, OnRegenMindPower)
    end
end

function Kenjutsuka:StopRegenMindPower()
    if self.regen ~= nil then
        self.regen:Cancel()
        self.regen = nil
    end
end

function Kenjutsuka:OnSave()
    return {
        kenjutsuexp = self.kenjutsuexp,
        kenjutsulevel = self.kenjutsulevel,
        mindpower = self.mindpower,
    }
end

function Kenjutsuka:OnLoad(data)
    if data ~= nil then
        self.kenjutsulevel = data.kenjutsulevel
        self.kenjutsuexp = data.kenjutsuexp
        self.mindpower = data.mindpower
    end
end

return Kenjutsuka
