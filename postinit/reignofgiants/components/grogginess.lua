local Grogginess = require("components/grogginess")
GLOBAL.setfenv(1, GLOBAL)

local _SetEnableSpeedMod = Grogginess.SetEnableSpeedMod
function Grogginess:SetEnableSpeedMod(enabled)
    _SetEnableSpeedMod(self, enabled)

    if enabled and self.enablespeedmod and self.inst:HasTag("controlled") then
        self.inst:AddTag("groggy")
    end
end

local _OnUpdate = Grogginess.OnUpdate
function Grogginess:OnUpdate(dt)
    _OnUpdate(self, dt)

    if self.grog_amount <= 0 and self.inst:HasTag("controlled") then
        self.inst:AddTag("groggy")
    end
end