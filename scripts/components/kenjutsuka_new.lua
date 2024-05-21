--------------------------------------------------------------------------
--[[ Kenjutsuka class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

    assert(TheWorld.ismastersim, "Kenjutsuka should not exist on client")

    --------------------------------------------------------------------------
    --[[ Member variables ]]
    --------------------------------------------------------------------------

    -- Public
    self.inst = inst

    -- Private
    local _config = M_CONFIG
    local _is_master = _config.IS_MASTER

    local kenjutsulevel = 0
    local kenjutsuexp = 0
	local kenjutsumaxexp = 250

    local mindpower = 0
    local max_mindpower = _config.MIND_MAX
    local mindpower_regen_rate = _config.MINDREGEN_RATE

    local MANUTSAWEE_DAMAGE = 1
    local MANUTSAWEE_CRIDMG = 0.1
    local hitcount = 0
    local criticalrate = 5

    local levelup_fns = {}

    local onlevelupfn
    local onmindregenfn

    --------------------------------------------------------------------------
    --[[ Private member functions ]]
    --------------------------------------------------------------------------

    local function IsKenjutsuMaster()
        kenjutsulevel = _config.LEVEL_VALUE
        if onlevelupfn ~= nil then
            onlevelupfn(self.inst, kenjutsulevel, kenjutsuexp)
        end
        if #levelup_fns > 0 then
            for i, v in ipairs(levelup_fns) do
                levelup_fns[v](self.inst, kenjutsulevel, kenjutsuexp)
            end
        end
    end

    local function OnPostInit(inst)
        if _is_master and onlevelupfn ~= nil then
            onlevelupfn(inst, kenjutsulevel, kenjutsuexp)
        end
    end

    local function OnRegenMindPower(inst, self)
        if mindpower < max_mindpower then
            mindpower = mindpower + 1
            if onmindregenfn ~= nil then
                onmindregenfn(inst, mindpower)
            end
        end
        self:StartRegenMindPower()
    end

    --------------------------------------------------------------------------
    --[[ Private event handlers ]]
    --------------------------------------------------------------------------

    local function OnAttackOther(inst, data)
        if inst.components.rider ~= nil and inst.components.rider:IsRiding() then
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
        local CAMT_TAG = not (target:HasOneOfTags({"prey", "bird", "insect", "wall"}) and not target:HasTag("hostile"))

        if weapon ~= nil and not weapon:HasTag("projectile") and not weapon:HasTag("rangedweapon") then
            if weapon:HasTag("katanaskill") and not inst.components.timer:TimerExists("hit_cd") and
                not inst.sg:HasStateTag("skilling") then -- GainKenExp
                if kenjutsulevel < 10 then
                    kenjutsuexp = kenjutsuexp + (1 * _config.KEXPMTP)
                end
                inst.components.timer:StartTimer("hit_cd", .5)
            end

            if CAMT_TAG then
                if math.random(1, 100) <= criticalrate + kenjutsulevel and
                    not inst.components.timer:TimerExists("critical_cd") and not inst.sg:HasStateTag("skilling") then
                    inst.components.timer:StartTimer("critical_cd", 15 - (kenjutsulevel / 2)) -- critical
                    local hitfx = SpawnPrefab("slingshotammo_hitfx_rock")
                    if hitfx ~= nil then
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

            if CAMT_TAG then
                if not inst.components.timer:TimerExists("heart_cd") and not inst.sg:HasStateTag("skilling") and
                    not inst.inspskill then
                    inst.components.timer:StartTimer("heart_cd", .3) -- mind gain
                    hitcount = hitcount + 1
                    if hitcount >= _config.MINDREGEN_COUNT and inst.components.kenjutsuka:GetKenjutsuLevel() >= 1 then
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

    --------------------------------------------------------------------------
    --[[ Initialization ]]
    --------------------------------------------------------------------------

    -- Register events

    inst:ListenForEvent("onattackother", OnAttackOther)
    inst:ListenForEvent("ms_playerreroll", OnPlayerReroll)

    --------------------------------------------------------------------------
    --[[ Post initialization ]]
    --------------------------------------------------------------------------

    inst:DoTaskInTime(0, OnPostInit)

    --------------------------------------------------------------------------
    --[[ Public member functions ]]
    --------------------------------------------------------------------------

    function self:SetKenjutsuExp(exp)
        kenjutsuexp = exp
    end

    function self:SetKenjutsuLevel(exp)
        kenjutsulevel = exp
    end

    function self:SetMindpower(power)
        mindpower = power
    end

    function self:SetMaxMindpower(mindpower)
        max_mindpower = mindpower
    end

    function self:SetOnLevelUp(fn)
        onlevelupfn = fn
    end

    function self:AddLevelUpFn(amount, fn)
        levelup_fns[amount] = fn
    end

    function self:AddLevelUpFns(fns)
        for i, v in ipairs(fns) do
            levelup_fns[i] = v
        end
    end

    function self:SetOnMindPowerRegenFn(fn)
        onmindregenfn = fn
    end

    function self:GetKenjutsuExp()
        return kenjutsuexp
    end

    function self:GetKenjutsuMaxExp()
        return kenjutsumaxexp
    end

    function self:GetKenjutsuLevel()
        return kenjutsulevel
    end

    function self:GetMindpower()
        return mindpower
    end

    function self:GetMaxMindpower()
        return max_mindpower
    end

    function self:GetIsMaster()
        return _is_master
    end

    function self:LevelUp()
        if onlevelupfn ~= nil then
            kenjutsulevel = kenjutsulevel + 1
            onlevelupfn(self.inst, kenjutsulevel, kenjutsuexp)
            if #levelup_fns > 0 then
                for i, v in ipairs(levelup_fns) do
                    levelup_fns[v](self.inst, kenjutsulevel, kenjutsuexp)
                end
            end
        end
    end

    local index = 0
    function self:StartRegenMindPower()
        print("StartRegenMindPower index: " .. index)
        if self.regen == nil then
            self.regen = self.inst:DoTaskInTime(mindpower_regen_rate, OnRegenMindPower, self)
            index = index + 1
        end
    end

    function self:StopRegenMindPower()
        if self.regen ~= nil then
            self.regen:Cancel()
            self.regen = nil
        end
    end

    --------------------------------------------------------------------------
    --[[ Save/Load ]]
    --------------------------------------------------------------------------

    function self:OnSave()
        return {
            kenjutsuexp = self.kenjutsuexp,
            kenjutsulevel = self.kenjutsulevel,
            mindpower = self.mindpower,
        }
    end

    function self:OnLoad(data)
        if data ~= nil then
            kenjutsulevel = data.kenjutsulevel
            kenjutsuexp = data.kenjutsuexp
            mindpower = data.mindpower
            if _is_master then
                IsKenjutsuMaster()
            end
        end
    end

    --------------------------------------------------------------------------
    --[[ OnRemoveEntity ]]
    --------------------------------------------------------------------------

    function self:OnRemoveEntity()
        self:StopRegenMindPower()

        self.inst:RemoveEventCallback("onattackother", OnAttackOther)
        self.inst:RemoveEventCallback("ms_playerreroll", OnPlayerReroll)
    end

    --------------------------------------------------------------------------
    --[[ Debug ]]
    --------------------------------------------------------------------------

    function self:GetDebugString()
        return string.format("Is Kenjutsu Master:%s, Exp:%d, Level:%d, Power:%d", tostring(self.is_master), self.kenjutsuexp, self.kenjutsulevel, self.mindpower)
    end

    --------------------------------------------------------------------------
    --[[ End ]]
    --------------------------------------------------------------------------
end)
