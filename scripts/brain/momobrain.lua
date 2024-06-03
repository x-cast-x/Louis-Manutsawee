require("behaviours/chaseandattack")
require("behaviours/faceentity")
require("behaviours/leash")
require("behaviours/standstill")
require("behaviours/wander")
require("behaviours/follow")
require("behaviours/doaction")
require("behaviours/teleport")


local BrainUtil = require("utils/brainutil")

local AVOID_EXPLOSIVE_DIST = 5

local RUN_AWAY_DIST = 1
local STOP_RUN_AWAY_DIST = 8

local function ShouldAvoidExplosive(target)
    return target.components.explosive == nil
        or target.components.burnable == nil
        or target.components.burnable:IsBurning()
end

local function ShouldTeleport(target, inst)
    if target:HasTag("player") then
		return target.sg:HasStateTag("attack")
	end
	return true
end

local MomoBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function MomoBrain:OnStart()
    -- local AvoidExplosions = Teleport(self.inst, { fn = ShouldAvoidExplosive, tags = { "explosive" }, notags = { "INLIMBO" } }, AVOID_EXPLOSIVE_DIST, AVOID_EXPLOSIVE_DIST)
    local AvoidDanger = Teleport(self.inst, { fn = ShouldTeleport, oneoftags = { "monster", "hostile" }, notags = { "player", "INLIMBO", "companion", "spiderden" } }, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST)

    local root = PriorityNode({
        AvoidDanger,

    }, 0.25)

    self.bt = BT(self.inst, root)
end

return MomoBrain
