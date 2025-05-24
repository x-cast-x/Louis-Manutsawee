local _config = M_CONFIG
local damage_multiplier = 1
local damage_critical = 0.1
local hitcount = 0
local critical_rate = 5

local function OnPostInit(inst)
    local kenjutsuka = inst.components.kenjutsuka
    if kenjutsuka ~= nil then
        local require_exp = kenjutsuka:IndexLevel(kenjutsuka:GetMaxLevel()).require_exp
        if require_exp ~= nil then
            kenjutsuka:SetMaxExp(require_exp)
        end
        if kenjutsuka:IsTatsujin() then
            kenjutsuka:SetExp(kenjutsuka:GetMaxExp(), kenjutsuka:IsTatsujin())
        end
    end
end

local function OnAttackOther(inst, data)
    local target = data.target
    local weapon = data.weapon
    local kenjutsuka = inst.components.kenjutsuka
    local CANT_TAG = {"prey", "bird", "insect", "wall"}

    if target ~= nil and weapon ~= nil and kenjutsuka ~= nil and not weapon:HasTag("projectile") and not weapon:HasTag("rangedweapon") and not inst.sg:HasStateTag("skilling") then
        if not inst.components.timer:TimerExists("hit_cd") and weapon:HasTag("katana") then
            inst.components.timer:StartTimer("hit_cd", .5)
            kenjutsuka:SetExp(kenjutsuka:GetExp() + (1 * _config.KenjutsuExpMultiple))
        end

        if not target:HasOneOfTags(CANT_TAG) then
            if not inst.components.timer:TimerExists("critical_cd") then
                if math.random(1, 100) <= critical_rate + kenjutsuka:GetLevel() then
                    inst.components.timer:StartTimer("critical_cd", 15 - (kenjutsuka:GetLevel() / 2))
                    target:SpawnPrefabInPos("slingshotammo_hitfx_rock")-- :SetScale(.8)
                    inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
                    inst.components.combat.damagemultiplier = (damage_multiplier + (damage_critical * kenjutsuka:GetLevel()))
                    inst:DoTaskInTime(1, function(inst)
                        inst.components.combat.damagemultiplier = damage_multiplier
                    end)
                end
            end

            if not inst.components.timer:TimerExists("heart_cd") then
                inst.components.timer:StartTimer("heart_cd", .3)
                hitcount = hitcount + 1
                if hitcount >= _config.RegenMindPowerCount then
                    inst:PushEvent("ms_regenmindpower")
                    inst.components.sanity:DoDelta(1)
                    hitcount = 0
                end
            end
        end
    end
end

local function OnPlayerReroll(inst)
    local level = inst.components.kenjutsuka:GetLevel()

    if level > 0 then
        local x, y, z = inst.Transform:GetWorldPosition()
        for i = 1, level do
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
        inst.components.kenjutsuka:SetLevel(0)
    end
end

local Kenjutsuka = Class(function(self, inst)
    assert(TheWorld.ismastersim, "Kenjutsuka should not exist on client")

    self.inst = inst
    self.onlevelupcallback = {}
    self.onregenindpower = nil

    self.is_tatsujin = _config.IsTatsujin

    self.level = 0
    self.exp = 0
	self.max_exp = 0

    self.mindpower = 0
    self.max_mindpower = _config.MaxMindPower
    self.regen_mindpower_rate = _config.RegenMindPowerRate
    self.enable_regen_mindpower = false

    self.inst:DoTaskInTime(0, OnPostInit)

    self.inst:ListenForEvent("onattackother", OnAttackOther)
    self.inst:ListenForEvent("ms_playerreroll", OnPlayerReroll)
    self.inst:ListenForEvent("ms_levelup", function(inst, data) self:OnLevelUp(data) end)
    self.inst:ListenForEvent("ms_expdelta", function(inst, data) self:OnExpDelta(data) end)
    self.inst:ListenForEvent("ms_regenmindpower", self.RegenMindPower)
end)

function Kenjutsuka:RegenMindPower()
    local current_mindpower = self:GetMindpower()
    if current_mindpower < self:GetMaxMindpower() then
        self:SetMindpower(current_mindpower + 1)
        if self.onregenindpower ~= nil then
            self.onregenindpower(self.inst, self:GetMindpower())
        end
    end
    self:StartRegenMindPower()
end

function Kenjutsuka:OnLevelUp(data)
    if data ~= nil then
        if data.level ~= nil then
            self:SetLevel(data.level)
            self:SetMaxMindpower(self:GetMaxMindpower() + data.level)
        end

        if data.fn ~= nil then
            data.fn(self.inst, self:GetLevel(), self:GetExp())
        end
    end
end

function Kenjutsuka:IsExpEligible(current_exp, require_exp)
    return current_exp >= require_exp
end

function Kenjutsuka:OnExpDelta(data)
    if data ~= nil then
        for k, v in (function()
            if self.spawnfx ~= nil then
                self.spawnfx(self.inst)
            end
            return pairs(self.onlevelupcallback)
        end)() do
            if v ~= nil and self:IsExpEligible(data.exp, v.require_exp) then
                self.inst:PushEvent("ms_levelup", {level = self:GetLevel() + 1, fn = v.fn})
            end
        end
    end
end

function Kenjutsuka:GetExp()
    return self.exp
end

function Kenjutsuka:SetExp(exp, force)
    if not force and exp > self:GetMaxExp() then
        return
    end

    self.exp = exp
    self.inst:PushEvent("ms_expdelta", {exp = self:GetExp()})
end

function Kenjutsuka:SetMaxExp(exp)
    self.max_exp = exp
end

function Kenjutsuka:SetLevel(level)
    if level > self:GetMaxLevel() then
        return
    end

    self.level = level
end

function Kenjutsuka:SetMindpower(power)
    self.mindpower = power
end

function Kenjutsuka:SetMaxMindpower(power)
    self.max_mindpower = power
end

function Kenjutsuka:AddOnLevelUp(onlevelup)
    self.onlevelupcallback = onlevelup
end

function Kenjutsuka:AddSpawnFx(spawnfx)
    self.spawnfx = spawnfx
end

function Kenjutsuka:SetOnRegenMindPower(fn)
    self.onregenindpower = fn
end

function Kenjutsuka:GetMaxExp()
    return self.max_exp
end

function Kenjutsuka:GetLevel()
    return self.level
end

function Kenjutsuka:GetMaxLevel()
    return GetTableSize(self.onlevelupcallback)
end

function Kenjutsuka:IndexLevel(i)
    local level = "Level" .. i
    local data = self.onlevelupcallback[level]
    return data ~= nil and data or {}
end

function Kenjutsuka:GetMindpower()
    return self.mindpower
end

function Kenjutsuka:GetMaxMindpower()
    return self.max_mindpower
end

function Kenjutsuka:IsMaxLevel()
    return self:GetLevel() >= self:GetMaxLevel()
end

function Kenjutsuka:IsTatsujin()
    return self.is_tatsujin
end

function Kenjutsuka:IsEnableMindpowerRegen()
    return self.enable_regen_mindpower
end

function Kenjutsuka:StartRegenMindPower()
    self:StopRegenMindPower()
    if self.mindpower_regen_task == nil then
        self.mindpower_regen_task = self.inst:DoTaskInTime(self.regen_mindpower_rate, function() self:RegenMindPower() end)
    end
end

function Kenjutsuka:StopRegenMindPower()
    if self.mindpower_regen_task ~= nil then
        self.mindpower_regen_task:Cancel()
        self.mindpower_regen_task = nil
    end
end

function Kenjutsuka:SetRegenMindPower(enable)
    self.enable_regen_mindpower = enable
    if self:IsEnableMindpowerRegen() then
        self:StartRegenMindPower()
    else
        self:StopRegenMindPower()
    end
end

function Kenjutsuka:OnSave()
    return {
        exp = self:GetExp(),
        mindpower = self:GetMindpower(),
    }
end

function Kenjutsuka:OnLoad(data)
    if data ~= nil then
        self:SetExp(data.exp, true)
        self:SetMindpower(data.mindpower)
    end
end

function Kenjutsuka:OnRemoveEntity()
    self:StopRegenMindPower()

    self.inst:RemoveEventCallback("onattackother", OnAttackOther)
    self.inst:RemoveEventCallback("ms_playerreroll", OnPlayerReroll)
    self.inst:RemoveEventCallback("ms_levelup", function(inst, data) self:OnLevelUp(data) end)
    self.inst:RemoveEventCallback("ms_expdelta", function(inst, data) self:OnExpDelta(data) end)
    self.inst:RemoveEventCallback("ms_regenmindpower", self.RegenMindPower)
end

Kenjutsuka.OnRemoveFromEntity = Kenjutsuka.OnRemoveEntity

function Kenjutsuka:GetDebugString()
    return string.format("Is Tatsujin: %s, Exp: %s, Level: %s, Power: %s, Max Exp: %s, Max Level: %s, Max Mindpower: %s, Enable Regen MindPower: %s", tostring(self:IsTatsujin()), self:GetExp(), self:GetLevel(), self:GetMindpower(), self:GetMaxExp(), self:GetMaxLevel(), self:GetMaxMindpower(), tostring(self:IsEnableMindpowerRegen()))
end

return Kenjutsuka
