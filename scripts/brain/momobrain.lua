require("behaviours/chaseandattack")
require("behaviours/faceentity")
require("behaviours/leash")
require("behaviours/standstill")
require("behaviours/wander")
require("behaviours/follow")
require("behaviours/doaction")

local BrainUtil = require("utils/brainutil")

local MomoBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function MomoBrain:OnStart()
    local root = PriorityNode({
    }, 0.25)

    self.bt = BT(self.inst, root)
end

return MomoBrain
