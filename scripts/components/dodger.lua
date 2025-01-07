local _GetPointSpecialActions

local function GetPointSpecialActions(inst, pos, useitem, right)
    local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    local rider = inst.replica.rider
    local dodger = inst.components.dodger
    if equip ~= nil and not (equip:HasTag("iai")) and equip:HasTag("katanaskill") and inst:HasTag("kenjutsu") and right and GetTime() - dodger.last_dodge_time > dodger.dodge_cooldown_time and not inst:HasTag("sitting_on_chair") then
        if rider == nil or not rider:IsRiding() then
            return {ACTIONS.MDODGE}
        end
    elseif inst:HasTag("kenjutsu") and right and GetTime() - dodger.last_dodge_time > dodger.dodge_cooldown_time and not inst:HasTag("sitting_on_chair") then
        if rider == nil or not rider:IsRiding() then
            return {ACTIONS.MDODGE2}
        end
    end
    return {}
end

-- Here we need to deal with it.
-- Execute the original function first, then execute the function I defined
local function OnSetOwner(inst)
    if inst.components.playeractionpicker ~= nil then
        _GetPointSpecialActions = inst.components.playeractionpicker.pointspecialactionsfn
        inst.components.playeractionpicker.pointspecialactionsfn = function(inst, pos, useitem, right)
            local callback = _GetPointSpecialActions(inst, pos, useitem, right)
            return not IsTableEmpty(callback) and callback or GetPointSpecialActions(inst, pos, useitem, right)
        end
    end
end

local function GetLastDodgeTime(inst, self)
    self.last_dodge_time = GetTime()
end

local Dodger = Class(function(self, inst)

    self.inst = inst

    self.dodge_time = net_bool(inst.GUID, "dodge_time", "dodgetimedirty")
    self.dodge_cooldown_time = M_CONFIG.DODGE_CD
    self.last_dodge_time = GetTime()

    inst:ListenForEvent("dodgetimedirty", GetLastDodgeTime, self)
    inst:ListenForEvent("setowner", OnSetOwner)
end)
