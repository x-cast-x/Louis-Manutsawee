local function GetCooldownTime(inst, dodger)
    return GetTime() - inst.components.dodger.last_dodge_time > inst.components.dodger.dodge_cooldown_time
end

local function GetPointSpecialActions(inst, pos, useitem, right)
    local rider = inst.replica.rider
    local sailor = inst.replica.sailor
    if inst:HasTag("dodger") and right and not rider:IsRiding() and sailor ~= nil and not sailor:IsSailing() and GetCooldownTime(inst) and not inst:HasTag("sitting_on_chair") then
        return {ACTIONS.MDODGE}
    end
    return {}
end

local function OnSetOwner(inst)
    if inst.components.playeractionpicker ~= nil then
        inst.components.playeractionpicker.pointspecialactionsfn = GetPointSpecialActions
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
