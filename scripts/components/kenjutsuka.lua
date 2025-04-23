return Class(function(self, inst)

    assert(TheWorld.ismastersim, "Kenjutsuka should not exist on client")

    --------------------------------------------------------------------------
    --[[ Member variables ]]
    --------------------------------------------------------------------------

    -- Public
    self.inst = inst

    -- Private
    local _config = M_CONFIG
    local _is_tatsujin = _config.IsTatsujin

    local level = 0
    local exp = 0
	local max_exp = 250

    local mindpower = 0
    local max_mindpower = _config.MIND_MAX
    local mindpower_regen_rate = _config.MINDREGEN_RATE

    local MANUTSAWEE_DAMAGE = 1
    local MANUTSAWEE_CRIDMG = 0.1
    local hitcount = 0
    local critical_rate = 5

    local levelup_callbacks = {}

    local onmindregen_callback

    --------------------------------------------------------------------------
    --[[ Private member functions ]]
    --------------------------------------------------------------------------

    local function IsKenjutsuMaster()
        if _is_tatsujin then
            level = _config.LEVEL_VALUE
            if #levelup_callbacks > 0 then
                for i, callback in ipairs(levelup_callbacks) do
                    callback(inst, level, exp)
                end
            end
        end
    end

    local function OnRegenMindPower(inst)
        if self.mindpower_regen_task == nil then
            if mindpower < max_mindpower then
                mindpower = mindpower + 1
                if onmindregen_callback ~= nil then
                    onmindregen_callback(inst, mindpower)
                end
            end
            self:StartRegenMindPower()
        end
    end

    local function HandleExpGain(inst, weapon, level, exp)
        if weapon:HasTag("katana") and not inst.components.timer:TimerExists("hit_cd") and
            not inst.sg:HasStateTag("skilling") then
            if level < 10 then
                exp = exp + (1 * _config.KEXPMTP)
            end
            inst.components.timer:StartTimer("hit_cd", .5)
        end
        return exp
    end

    local function HandleCriticalHit(inst, target, level, tx, ty, tz)
        if math.random(1, 100) <= critical_rate + level and
            not inst.components.timer:TimerExists("critical_cd") and not inst.sg:HasStateTag("skilling") then
            inst.components.timer:StartTimer("critical_cd", 15 - (level / 2)) -- critical
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

    local function HandleMindPowerGain(inst, mindpower, hitcount)
        if not inst.components.timer:TimerExists("heart_cd") and not inst.sg:HasStateTag("skilling") and
            not inst.inspskill then
            inst.components.timer:StartTimer("heart_cd", .3) -- mind gain
            hitcount = hitcount + 1
            if hitcount >= _config.MINDREGEN_COUNT and inst.components.kenjutsuka:Getlevel() >= 1 then
                if mindpower < inst.components.kenjutsuka:GetMaxMindpower() then
                    onmindregen_callback(inst, mindpower)
                else
                    inst.components.sanity:DoDelta(1)
                end
                hitcount = 0
            end
        end
    end

    --------------------------------------------------------------------------
    --[[ Private event handlers ]]
    --------------------------------------------------------------------------

    local function OnAttackOther(inst, data)
        if not (inst.components.rider ~= nil and inst.components.rider:IsRiding()) then
            local target = data.target
            local weapon = data.weapon
            local kenjutsuka = inst.components.kenjutsuka
            local exp = kenjutsuka:Getexp()
            local level = kenjutsuka:Getlevel()
            local mindpower = kenjutsuka:GetMindpower()
            local tx, ty, tz = target.Transform:GetWorldPosition()
            local CAMT_TAG = not (target:HasOneOfTags({"prey", "bird", "insect", "wall"}) and not target:HasTag("hostile"))

            exp = HandleExpGain(inst, weapon, level, exp)

            if CAMT_TAG then
                HandleCriticalHit(inst, target, level, tx, ty, tz)
                HandleMindPowerGain(inst, mindpower, hitcount)
            end

            inst:PushEvent("")
        end
    end

    local function OnPlayerReroll(inst)
        local level = inst.components.kenjutsuka:Getlevel()

        inst.components.playerskillcontroller:DeactivateSkill()

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
            level = 0
        end
    end

    local function OnDeath(inst)
        local fx = SpawnPrefab("fx_book_light_upgraded")
        local x, y, z = inst.Transform:GetWorldPosition()
        fx.Transform:SetScale(.9, 2.5, 1)
        fx.Transform:SetPosition(x, y, z)

        inst.components.playerskillcontroller:DeactivateSkill()
    end

    local function OnEquip(inst, data)
        local item = data.item
        if item ~= nil and (item.prefab == "onemanband" or item.prefab == "armorsnurtleshell") then
            if not inst:HasTag("notshowscabbard") then
                inst:AddTag("notshowscabbard")
            end
        end
    end

    local function OnUnEquip(inst, data)
        local item = data.item
        if item ~= nil and (item.prefab == "onemanband" or item.prefab == "armorsnurtleshell") then
            if inst:HasTag("notshowscabbard") then
                inst:RemoveTag("notshowscabbard")
            end
        end

        if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) == nil then
            inst.components.playerskillcontroller:DeactivateSkill()
        end
    end

    local function OnDroped(inst, data)
        local item = data ~= nil and (data.prev_item or data.item)

        if item ~= nil and item:HasTag("katana") and not item:HasTag("woodensword") then
            if not inst:HasTag("notshowscabbard") then
                inst.AnimState:ClearOverrideSymbol("swap_body_tall")
            end
        end
    end

    local function LevelUp(inst)
        if exp >= max_exp then
            exp = exp - max_exp
            level = level + 1
            if #levelup_callbacks > 0 then
                for i, v in ipairs(levelup_callbacks) do
                    levelup_callbacks[i](inst, level, exp)
                end
            end

            max_mindpower = _config.MIND_MAX + level

            local fx = SpawnPrefab("fx_book_light_upgraded")
            fx.Transform:SetScale(.9, 2.5, 1)
            fx.entity:AddFollower()
            fx.Follower:FollowSymbol(inst.GUID, "swap_body", 0, 0, 0)
        end
    end

    --------------------------------------------------------------------------
    --[[ Initialization ]]
    --------------------------------------------------------------------------

    -- Register events

    inst:ListenForEvent("onattackother", OnAttackOther)
    inst:ListenForEvent("ms_playerreroll", OnPlayerReroll)
    inst:ListenForEvent("death", OnDeath)
    inst:ListenForEvent("unequip", OnUnEquip)
    inst:ListenForEvent("equip", OnEquip)
    inst:ListenForEvent("dropitem", OnDroped)
    inst:ListenForEvent("itemlose", OnDroped)
    inst:ListenForEvent("levelup", LevelUp)

    --------------------------------------------------------------------------
    --[[ Post initialization ]]
    --------------------------------------------------------------------------

    inst:DoTaskInTime(0, IsKenjutsuMaster)

    --------------------------------------------------------------------------
    --[[ Public member functions ]]
    --------------------------------------------------------------------------

    function self:SetExp(exp)
        exp = exp
    end

    function self:SetLevel(exp)
        level = exp
    end

    function self:SetMindpower(power)
        mindpower = power
    end

    function self:AddLevelUpCallback(level, fn)
        levelup_callbacks[level] = fn
    end

    function self:SetOnMindPowerRegen(fn)
        onmindregen_callback = fn
    end

    function self:GetExp()
        return exp
    end

    function self:GetLevel()
        return level
    end

    function self:GetMindpower()
        return mindpower
    end

    function self:IsMaster()
        return level >= 10
    end

    function self:IsTatsujin()
        return _is_tatsujin
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

    --------------------------------------------------------------------------
    --[[ Save/Load ]]
    --------------------------------------------------------------------------

    function self:OnSave()
        return {
            exp = exp,
            level = level,
            mindpower = mindpower,
        }
    end

    function self:OnLoad(data)
        if data ~= nil then
            level = data.level
            exp = data.exp
            mindpower = data.mindpower
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

    --------------------------------------------------------------------------
    --[[ Debug ]]
    --------------------------------------------------------------------------

    function self:GetDebugString()
        return string.format("Is Kenjutsu Master:%s, Exp:%d, Level:%d, Power:%d", tostring(self:IsMaster()), exp, level, mindpower)
    end

    --------------------------------------------------------------------------
    --[[ End ]]
    --------------------------------------------------------------------------
end)
