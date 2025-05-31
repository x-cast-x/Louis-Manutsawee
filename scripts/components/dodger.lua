local function GetCooldownTime(inst, dodger)
    return GetTime() - inst.components.dodger.last_dodge_time > inst.components.dodger.dodge_cooldown_time
end

local function GetPointSpecialActions(inst, pos, useitem, right)
    local rider = inst.replica.rider
    if inst:HasTag("dodger") and right and not rider:IsRiding() and GetCooldownTime(inst) and not inst:HasTag("sitting_on_chair") then
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

    if not TheWorld.ismastersim then
        inst:ListenForEvent("dodgetimedirty", GetLastDodgeTime)
        inst:ListenForEvent("setowner", OnSetOwner)
    end
end)

function Dodger:SetCooldownTime(time)
    if TheWorld.ismastersim then
        self.dodge_cooldown_time = time
    end
end

function Dodger:OnRemoveFromEntity()
    if not TheWorld.ismastersim then
        self.inst:RemoveEventCallback("dodgetimedirty", GetLastDodgeTime)
        self.inst:RemoveEventCallback("setowner", OnSetOwner)
    end
end

return Dodger
