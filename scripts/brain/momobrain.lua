require("behaviours/chaseandattack")
require("behaviours/faceentity")
require("behaviours/leash")
require("behaviours/standstill")
require("behaviours/wander")

local MomoBrain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)

function MomoBrain:OnStart()
    local root = PriorityNode({

    })

	self.bt = BT(self.inst, root)
end

return MomoBrain
