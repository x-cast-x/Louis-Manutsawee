require("behaviours/chaseandattack")
require("behaviours/faceentity")
require("behaviours/leash")
require("behaviours/standstill")
require("behaviours/wander")
require("behaviours/follow")
require("behaviours/doaction")

local BrainHelper = require("utils/brainhelper")
local MomoData = require("utils/momodata")

local MIN_FOLLOW_DIST = 0
local TARGET_FOLLOW_DIST = 6
local MAX_FOLLOW_DIST = 8

local MAX_CHASE_TIME = 10
local MAX_CHASE_DIST = 30

local function OnAwareDanger(inst)

end

local Feed = function(inst)
    local honey = inst:TheHoney()
    local food = SpawnPrefab(math.random(1, #MomoData.foods))

    if honey ~= nil and food ~= nil then
        return BufferedAction(inst, honey, ACTIONS.FEED, food)
    end
end

local MomoBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function MomoBrain:OnStart()
    local want_to_feed = IfNode(function() return self.inst.components.brainhelper:feed_condition() end, "feed",
        WhileNode(function() return self.inst.components.brainhelper:feed_rejection() end, "keep feed",
            LoopNode{
                DoAction(self.inst, Feed)
            }
        )
    )

    local root = PriorityNode({
        want_to_feed,

        Follow(self.inst, self.inst.TheHoney, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
    })

    self.bt = BT(self.inst, root)
end

return MomoBrain
