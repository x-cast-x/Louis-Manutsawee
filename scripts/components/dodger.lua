local function GetCooldownTime(inst, dodger)
    return GetTime() - dodger.last_dodge_time > dodger.dodge_cooldown_time
end

local function GetPointSpecialActions(inst, pos, useitem, right)
    local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    local rider = inst.replica.rider
    local dodger = inst.components.dodger
    if inst:HasTag("dodger") and right and not rider:IsRiding() and GetCooldownTime(inst, dodger) and not inst:HasTag("sitting_on_chair") then
        if equip ~= nil and not equip:HasTag("iai") and equip:HasTag("katana") then
            return {ACTIONS.MDODGE}
        else
            return {ACTIONS.MDODGE2}
        end
    end
    return {}
end

-- Here we need to deal with it.
-- Execute the original function first, then execute the function I defined
local function OnSetOwner(inst)
    if inst.components.playeractionpicker ~= nil then
        local _GetPointSpecialActions = inst.components.playeractionpicker.pointspecialactionsfn ~= nil and inst.components.playeractionpicker.pointspecialactionsfn
        inst.components.playeractionpicker.pointspecialactionsfn = function(inst, pos, useitem, right)
            local callback = _GetPointSpecialActions(inst, pos, useitem, right)
            return (callback ~= nil and not IsTableEmpty(callback) and callback) or GetPointSpecialActions(inst, pos, useitem, right)
        end
    end
end

local function GetLastDodgeTime(inst)
    inst.components.dodger.last_dodge_time = GetTime()
end

local Dodger = Class(function(self, inst)

    self.inst = inst

    self.dodge_time = net_bool(inst.GUID, "dodge_time", "dodgetimedirty")
    self.dodge_cooldown_time = TUNING.DEFAULT_DODGE_COOLDOWN_TIME
    self.last_dodge_time = GetTime()

    inst:ListenForEvent("dodgetimedirty", GetLastDodgeTime)
    inst:ListenForEvent("setowner", OnSetOwner)
end)

function Dodger:SetCooldownTime(time)
    self.dodge_cooldown_time = time
end

return Dodger
