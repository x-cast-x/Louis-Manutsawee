return Class(function(self, inst)

    assert(TheWorld.ismastersim, "Kenjutsuka should not exist on client")

    --------------------------------------------------------------------------
    --[[ Member variables ]]
    --------------------------------------------------------------------------

    -- Public
    self.inst = inst
    self.onlevelup = {}
    self.onmindpowerregen = nil

    -- Private
    local _config = M_CONFIG
    local _is_tatsujin = _config.IsTatsujin

    local level = 0
    local exp = 0
	local max_exp = 250

    local mindpower = 0
    local max_mindpower = _config.MaxMindPower
    local mindpower_regen_rate = _config.MindRegenRate
    local enable_mindpower_regen = false

    local damage_multiplier = 1
    local damage_critical = 0.1
    local hitcount = 0
    local critical_rate = 5

    --------------------------------------------------------------------------
    --[[ Private member functions ]]
    --------------------------------------------------------------------------

    local function IsTatsujin()
        local kenjutsuka = inst.components.kenjutsuka
        if kenjutsuka ~= nil then
            kenjutsuka:SetLevel(kenjutsuka:GetMaxLevel())
            local onlevelup = kenjutsuka:GetOnLevelUp()
            for i = 1, #onlevelup do
                onlevelup[i](inst, level, exp)
            end
        end
    end

    local function OnPostInit()
        local kenjutsuka = inst.components.kenjutsuka
        if kenjutsuka ~= nil then
            if kenjutsuka:IsTatsujin() then
                IsTatsujin()
            end
        end
    end

    local function OnRegenMindPower(inst, _mindpower)
        local kenjutsuka = inst.components.kenjutsuka
        if kenjutsuka ~= nil then
            if _mindpower < kenjutsuka:GetMaxMindpower() then
                kenjutsuka:SetMindpower(_mindpower + 1)
                inst:PushEvent("mindpowerregen", {mindpower = _mindpower})
            end
        end
    end

    --------------------------------------------------------------------------
    --[[ Private event handlers ]]
    --------------------------------------------------------------------------

    local function OnAttackOther(inst, data)
        local target = data.target
        local weapon = data.weapon
        local kenjutsuka = inst.components.kenjutsuka
        local tx, ty, tz = target.Transform:GetWorldPosition()
        local CANT_TAG = {"prey", "bird", "insect", "wall", "hostile"}

        if weapon ~= nil and kenjutsuka ~= nil and not weapon:HasTag("projectile") and not weapon:HasTag("rangedweapon") and not inst.sg:HasStateTag("skilling") then
            if not inst.components.timer:TimerExists("hit_cd") and weapon:HasTag("katana") then --not kenjutsuka:IsMaxLevel()
                inst.components.timer:StartTimer("hit_cd", .5)
                kenjutsuka:SetExp(kenjutsuka:GetExp() + (1 * _config.KenjutsuExpMultiple))
            end

            if not target:HasOneOfTags(CANT_TAG) then
                if not inst.components.timer:TimerExists("critical_cd") then
                    if math.random(1, 100) <= critical_rate + kenjutsuka:GetLevel() then
                        inst.components.timer:StartTimer("critical_cd", 15 - (kenjutsuka:GetLevel() / 2)) -- critical
                        target:SpawnPrefabInPos("slingshotammo_hitfx_rock"):SetScale(.8)
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
                    if hitcount >= _config.MindRegenCount and kenjutsuka:IsEnableMindpowerRegen() then
                        OnRegenMindPower(inst, kenjutsuka:GetMindpower())
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

    local function OnLevelUp(inst, data)
        local kenjutsuka = inst.components.kenjutsuka
        if kenjutsuka ~= nil then
            kenjutsuka:SetLevel(data.level)
            inst.components.kenjutsuka:SetMaxMindpower(data.level + kenjutsuka:GetMaxMindpower())
            for i = 1, data.level do
                local fn = self:GetNextLevel().fn
                if fn ~= nil then
                    fn(inst, data.level, kenjutsuka:GetExp())
                end
            end

            local fx = inst:FollwerFx("fx_book_light_upgraded")
            fx.Transform:SetScale(.9, 2.5, 1)

            kenjutsuka:SetMaxExp(self:GetNextLevel().require_exp)
        end
    end

    local function OnMindpowerRegen(inst, data)
        local kenjutsuka = inst.components.kenjutsuka
        if kenjutsuka ~= nil then
            local fn = kenjutsuka.onmindpowerregen
            if fn ~= nil then
                fn(inst, data.mindpower)
            end
            kenjutsuka:StartRegenMindPower()
        end
    end

    local function OnExpDelta(inst, data)
        local kenjutsuka = inst.components.kenjutsuka
        local _exp = data._exp
        if kenjutsuka ~= nil then
            local data = self:GetNextLevel()
            if data ~= nil and _exp ~= nil and _exp >= data.require_exp then
                inst:PushEvent("levelup", {level = kenjutsuka:GetLevel() + 1})
            end
        end
    end

    --------------------------------------------------------------------------
    --[[ Initialization ]]
    --------------------------------------------------------------------------

    -- Register events
    inst:ListenForEvent("onattackother", OnAttackOther)
    inst:ListenForEvent("ms_playerreroll", OnPlayerReroll)
    inst:ListenForEvent("levelup", OnLevelUp)
    inst:ListenForEvent("mindpowerregen", OnMindpowerRegen)
    inst:ListenForEvent("expdelta", OnExpDelta)

    --------------------------------------------------------------------------
    --[[ Post initialization ]]
    --------------------------------------------------------------------------

    inst:DoTaskInTime(0, OnPostInit)

    --------------------------------------------------------------------------
    --[[ Public member functions ]]
    --------------------------------------------------------------------------

    function self:GetExp()
        return exp
    end

    function self:SetExp(_exp)
        exp = _exp

        inst:PushEvent("expdelta", {_exp = exp})
    end

    function self:SetMaxExp(_exp)
        max_exp = _exp
    end

    function self:SetLevel(_level)
        level = _level
    end

    function self:SetMindpower(power)
        mindpower = power
    end

    function self:SetMaxMindpower(power)
        max_mindpower = power
    end

    function self:AddOnLevelUp(_level, data)
        self.onlevelup[_level] = data
    end

    function self:SetOnMindPowerRegen(fn)
        self.onmindpowerregen = fn
    end

    function self:GetMaxExp()
        return max_exp
    end

    function self:IsMaxExp()
        return self:GetExp() >= self:GetMaxExp()
    end

    function self:GetLevel()
        return level
    end

    function self:GetMaxLevel()
        return #self:GetOnLevelUp()
    end

    function self:GetOnLevelUp()
        return self.onlevelup
    end

    function self:GetNextLevel()
        return self:GetOnLevelUp()["Level" .. self:GetLevel() + 1]
    end

    function self:GetMindpower()
        return mindpower
    end

    function self:GetMaxMindpower()
        return max_mindpower
    end

    function self:IsMaxLevel()
        return self:GetLevel() >= self:GetMaxLevel()
    end

    function self:IsTatsujin()
        return _is_tatsujin
    end

    function self:EnableMindpowerRegen(enable)
        enable_mindpower_regen = enable
        self:SetRegenMindPower(enable)
    end

    function self:IsEnableMindpowerRegen()
        return enable_mindpower_regen
    end

    function self:StartRegenMindPower()
        self:StopRegenMindPower()
        if self.mindpower_regen_task == nil then
            self.mindpower_regen_task = inst:DoTaskInTime(mindpower_regen_rate, OnRegenMindPower)
        end
    end

    function self:StopRegenMindPower()
        if self.mindpower_regen_task ~= nil then
            self.mindpower_regen_task:Cancel()
            self.mindpower_regen_task = nil
        end
    end

    function self:SetRegenMindPower(enable)
        if enable then
            self:StartRegenMindPower()
        else
            self:StopRegenMindPower()
        end
    end

    --------------------------------------------------------------------------
    --[[ Save/Load ]]
    --------------------------------------------------------------------------

    function self:OnSave()
        return {
            exp = self:GetExp(),
            level = self:GetLevel(),
            mindpower = self:GetMindpower(),
            enable_mindpower_regen = self:IsEnableMindpowerRegen(),
        }
    end

    function self:OnLoad(data)
        if data ~= nil then
            self:SetLevel(data.level)
            self:SetExp(data.exp)
            self:SetMindpower(data.mindpower)
            self:EnableMindpowerRegen(data.enable_mindpower_regen)
        end
    end

    --------------------------------------------------------------------------
    --[[ OnRemoveEntity ]]
    --------------------------------------------------------------------------

    function self:OnRemoveEntity()
        self:StopRegenMindPower()

        inst:RemoveEventCallback("onattackother", OnAttackOther)
        inst:RemoveEventCallback("ms_playerreroll", OnPlayerReroll)
    end

    self.OnRemoveFromEntity = self.OnRemoveEntity

    --------------------------------------------------------------------------
    --[[ Debug ]]
    --------------------------------------------------------------------------

    function self:GetDebugString()
        return string.format("Is Tatsujin: %s, Exp: %s, Level: %s, Power: %s, Max Level: %s", tostring(self:IsTatsujin()), self:GetExp(), self:GetLevel(), self:GetMindpower(), self:GetMaxExp())
    end

    --------------------------------------------------------------------------
    --[[ End ]]
    --------------------------------------------------------------------------
end)
