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
    local kenjutsuexp = kenjutsuka.kenjutsuexp
    local kenjutsumaxexp = kenjutsuka.kenjutsumaxexp
    local tx, ty, tz = target.Transform:GetWorldPosition()
    local cant_tags = not (target:HasOneOfTags({"prey", "bird", "insect", "wall"}) and not target:HasTag("hostile"))

    if weapon ~= nil and not weapon:HasTag("projectile") and not weapon:HasTag("rangedweapon") then
        if weapon:HasTag("katanaskill") and not inst.components.timer:TimerExists("HitCD") and
            not inst.sg:HasStateTag("skilling") then -- GainKenExp
            if kenjutsuka.kenjutsulevel < 10 then
                kenjutsuka.kenjutsuexp = kenjutsuka.kenjutsuexp + (1 * M_CONFIG.KEXPMTP)
            end
            inst.components.timer:StartTimer("HitCD", .5)
        end

        if cant_tags then
            if math.random(1, 100) <= criticalrate + kenjutsuka.kenjutsulevel and
                not inst.components.timer:TimerExists("CriCD") and not inst.sg:HasStateTag("skilling") then
                inst.components.timer:StartTimer("CriCD", 15 - (kenjutsuka.kenjutsulevel / 2)) -- critical
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
            if not inst.components.timer:TimerExists("HeartCD") and not inst.sg:HasStateTag("skilling") and
                not inst.inspskill then
                inst.components.timer:StartTimer("HeartCD", .3) -- mind gain
                hitcount = hitcount + 1
                if hitcount >= M_CONFIG.MINDREGEN_COUNT and inst.kenjutsulevel >= 1 then
                    if kenjutsuka.mindpower < kenjutsuka.max_mindpower then
                        kenjutsuka.onmindregenfn(inst, kenjutsuka)
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
    local self = inst.components.kenjutsuka

    inst:SkillRemove()

    if self.kenjutsulevel > 0 then
        local x, y, z = inst.Transform:GetWorldPosition()
        for i = 1, self.kenjutsulevel do
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
        self.kenjutsulevel = 0
    end
end

local function OnPostInit(inst, self)
	--custom start level
	if self.is_master then
        if self.kenjutsulevel < M_CONFIG.MASTER_VALUE then
            self.kenjutsulevel = M_CONFIG.MASTER_VALUE
            self.onupgradefn(inst, self.kenjutsulevel, self.kenjutsuexp)
        end
    end
end

local function OnRegenMindPower(inst, self)
	if self.mindpower < self.max_mindpower / 2 then
        self.onmindregenfn(inst, self)
   end
   self.regen = inst:DoTaskInTime(self.mindpower_regen_rate, OnRegenMindPower, self)
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

    inst:DoTaskInTime(2, OnPostInit, self)
end)

function Kenjutsuka:SetOnUpgradeFn(fn)
    self.onupgradefn = fn
end

function Kenjutsuka:SetOnMindPowerRegenFn(fn)
    self.onmindregenfn = fn
end

function Kenjutsuka:KenjutsuLevelUp()
    if self.onupgradefn ~= nil then
    	self.kenjutsulevel = self.kenjutsulevel + 1
        self.onupgradefn(self.inst, self.kenjutsulevel, self.kenjutsuexp)
    end
end

function Kenjutsuka:StartRegenMindPower()
    if self.regen == nil then
        self.regen = self.inst:DoTaskInTime(self.mindpower_regen_rate, OnRegenMindPower, self)
    end
end

function Kenjutsuka:StopRegenMindPower()
    if self.regen ~= nil then
        if self.regen ~= nil then
            self.regen:Cancel()
            self.regen = nil
        end
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
    self.kenjutsulevel = data.kenjutsulevel
	self.kenjutsuexp = data.kenjutsuexp
    self.mindpower = data.mindpower

    if self.onupgrade ~= nil then
    	self.onupgradefn(self.inst, self.kenjutsulevel, self.kenjutsuexp)
    end
end

return Kenjutsuka
