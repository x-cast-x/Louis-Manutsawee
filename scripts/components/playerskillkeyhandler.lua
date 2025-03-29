--------------------------------------------------------------------------
--[[ Player Skill Manager Status class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

    assert(TheWorld.ismastersim, "Player Skill Manager should not exist on client")

    --------------------------------------------------------------------------
    --[[ Dependencies ]]
    --------------------------------------------------------------------------

    --------------------------------------------------------------------------
    --[[ Member variables ]]
    --------------------------------------------------------------------------

    -- Public
    self.inst = inst

    -- Private
    local _world = TheWorld
    local _ismastersim = _world.ismastersim

    local _handler = nil

    local skill_keys_handler = {}

    local MUST_TAG = {"tool", "sharp", "weapon", "katanaskill"}
    local CANT_TAG = {"projectile", "whip", "rangedweapon"}

    --------------------------------------------------------------------------
    --[[ Private member functions ]]
    --------------------------------------------------------------------------

    local CanActivateSkill_Client = not _ismastersim and function(inst, data, key)
        local screen = TheFrontEnd:GetActiveScreen().name
        if data.inst == inst and data.key == key and not (screen == "HUD") and ((not inst:HasTag("time_stopped")) and (not inst:HasTag("sleeping"))) then
            return true
        end
        return false
    end or nil

    local CanActivateSkill_Master = _ismastersim and function(inst, weapon)
        if not weapon
        or (not inst.components.kenjutsuka)
        or (not inst.components.playerskillcontroller)
        or inst.components.sleeper:IsAsleep()
        or inst.components.freezable:IsFrozen()
        or inst.components.rider:IsRiding()
        or inst.components.inventory:IsHeavyLifting()
        or inst:HasTag("playerghost")
        or weapon:HasOneOfTags(CANT_TAG) and (not weapon:HasOneOfTags(MUST_TAG)) then
            return false
        end

        return true
    end or nil

    local function MindpowerNotEnough(inst, currentmindpower, requiredmindpower)
        inst.components.talker:Say(STRINGS.SKILL.MINDPOWER_NOT_ENOUGH.. currentmindpower .. "/" .. requiredmindpower .. "\n ", 1, true)
    end

    local function CheckSkillKeyCooldown(inst, cooldown)
        if inst.components.timer:TimerExists("skill_key_cd") then
            inst.components.talker:Say(cooldown, 1, true)
            return false
        end
        return true
    end

    local function ActivateSkill(inst, weapen, tag, requiredlevel, currentlevel, requiredmindpower, currentmindpower, cooldown, combatrange, startmessage)
        if currentlevel < requiredlevel then
            inst.components.talker:Say(STRINGS.SKILL.UNLOCK_SKILL .. requiredlevel, 1, true)
        elseif currentmindpower >= requiredmindpower then
            if CheckSkillKeyCooldown(inst, cooldown) then
                inst:AddTag(tag)
                inst.components.combat:SetRange(combatrange)
                inst.components.talker:Say(startmessage.. currentmindpower .. "/" ..requiredmindpower .. "\n ", 1, true)
            end
        else
            MindpowerNotEnough(inst, currentmindpower, requiredmindpower)
        end
    end

    local function SkillKeyHandler(inst, fn, data)
        local weapon = inst.components.inventory ~= nil and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

        if CanActivateSkill_Master(inst, weapon) then
            inst.components.playerskillcontroller:DeactivateSkill()

            local level = inst.components.kenjutsuka:GetLevel()
            local mindpower = inst.components.kenjutsuka:GetMindpower()
            local weapon_is_katana = weapon:HasTag("katana")
            local HasOneOfTags = inst:HasOneOfTags({"ichimonji", "isshin", "ryusen"})

            inst.components.timer:StartTimer("skill_key_cd", 1)

            if mindpower >= data.requiredmindpower then
                if HasOneOfTags then
                    inst.components.talker:Say(STRINGS.SKILL.SKILL_LATER, 1, true)
                else
                    fn(inst, weapon, data)
                end
            else
                MindpowerNotEnough(inst, mindpower, data.requiredmindpower)
            end
        end
    end

    --------------------------------------------------------------------------
    --[[ Private event handlers ]]
    --------------------------------------------------------------------------


    --------------------------------------------------------------------------
    --[[ Public member functions ]]
    --------------------------------------------------------------------------

    function self:AddSkillKey(key, skillname, testfn, namespace, action)
        TheInput:AddKeyUpHandler(key, function(inst, data)
            if CanActivateSkill_Client(inst, data, key) then
                if _ismastersim then
                    inst:PushEvent("keyaction" .. namespace .. action, { namespace = namespace, action = action, fn = GetModRPCHandler(namespace, action)})
                else
                    SendModRPCToServer(GetModRPC(namespace, action))
                end
            end
        end)
    end

    function self:AddTierSkillKey(key, _key, skillname, fn)
        TheInput:AddCombinationKeyHandler(key, _key, fn)
    end



    --------------------------------------------------------------------------
    --[[ Save/Load ]]
    --------------------------------------------------------------------------



    --------------------------------------------------------------------------
    --[[ OnRemoveEntity ]]
    --------------------------------------------------------------------------

    --------------------------------------------------------------------------
    --[[ Debug ]]
    --------------------------------------------------------------------------

    --------------------------------------------------------------------------
    --[[ Initialization ]]
    --------------------------------------------------------------------------

    -- Register events
    if _ismastersim then
        inst:ListenForEvent("keyaction" .. namespace .. action, function(inst, data)
            if data.action == action and data.namespace == namespace then
                data.fn(inst)
            end
        end)
    end

    --------------------------------------------------------------------------
    --[[ Post initialization ]]
    --------------------------------------------------------------------------


    --------------------------------------------------------------------------
    --[[ End ]]
    --------------------------------------------------------------------------

end)
