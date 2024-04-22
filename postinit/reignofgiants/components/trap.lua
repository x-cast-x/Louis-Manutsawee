local Trap = require("components/trap")
GLOBAL.setfenv(1, GLOBAL)

local _SetBait = Trap.SetBait
-- override this function
function Trap:SetBait(bait, doer)
    self:RemoveBait()
    if bait ~= nil and bait.components.bait ~= nil then
        self.bait = bait
        if self.baitsortorder ~= nil then
            self.bait.AnimState:SetFinalOffset(self.baitsortorder)
        end
        bait.components.bait.trap = self
        bait.Transform:SetPosition(self.inst.Transform:GetWorldPosition())
        if self.onbaited ~= nil then
            self.onbaited(self.inst, self.bait, doer)
        end
    end
end
