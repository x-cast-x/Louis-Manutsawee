require("behaviours/chaseandattack")
require("behaviours/faceentity")
require("behaviours/leash")
require("behaviours/standstill")
require("behaviours/wander")
require("behaviours/follow")

local MIN_FOLLOW_DIST = 0
local TARGET_FOLLOW_DIST = 6
local MAX_FOLLOW_DIST = 8

local MAX_CHASE_TIME = 10
local MAX_CHASE_DIST = 30

local function OnAwareDanger(inst)
    -- body
end

local Feed = function(inst)
    local honey = inst:TheHoney()

    if honey ~= nil then
        return BufferedAction(inst, honey, ACTIONS.FEED)
    end
end

local MomoBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function MomoBrain:OnStart()
    local root = PriorityNode({
        WhileNode( function() return self.inst.components.combat.target == nil or not self.inst.components.combat:InCooldown() end, "AttackMomentarily",
                    ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST) )
        -- Follow(self.inst, self.inst.TheHoney, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
    })

    self.bt = BT(self.inst, root)
end

return MomoBrain
