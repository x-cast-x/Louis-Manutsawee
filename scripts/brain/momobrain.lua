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

local function GetLeader(inst)
    return inst.components.follower.leader
end

local function GetLeaderPos(inst)
    return inst.components.follower.leader:GetPosition()
end

local function GetFaceTargetFn(inst)
    local target = FindClosestPlayerToInst(inst, START_FACE_DIST, true)
    return target ~= nil and not target:HasTag("notarget") and target or nil
end

local function KeepFaceTargetFn(inst, target)
    return not target:HasTag("notarget") and inst:IsNear(target, KEEP_FACE_DIST)
end

local function GetFaceLeaderFn(inst)
	local target = GetLeader(inst)
	return target ~= nil and target.entity:IsVisible() and inst:IsNear(target, START_FACE_DIST) and target or nil
end

local function KeepFaceLeaderFn(inst, target)
	return target.entity:IsVisible() and inst:IsNear(target, KEEP_FACE_DIST)
end

local function IsNearLeader(inst, dist)
    local leader = GetLeader(inst)
    return leader ~= nil and inst:IsNear(leader, dist)
end

local function FindAnyEntityCouldPoseHazard(inst)

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

local function ShouldWatchMinigame(inst)
	if inst.components.follower.leader ~= nil and inst.components.follower.leader.components.minigame_participator ~= nil then
		if inst.components.combat.target == nil or inst.components.combat.target.components.minigame_participator ~= nil then
			return true
		end
	end
	return false
end

local function WatchingMinigame(inst)
	return (inst.components.follower.leader ~= nil and inst.components.follower.leader.components.minigame_participator ~= nil) and inst.components.follower.leader.components.minigame_participator:GetMinigame() or nil
end

local function WatchingMinigame_MinDist(inst)
	local minigame = WatchingMinigame(inst)
	return minigame ~= nil and minigame.components.minigame.watchdist_min or 0
end
local function WatchingMinigame_TargetDist(inst)
	local minigame = WatchingMinigame(inst)
	return minigame ~= nil and minigame.components.minigame.watchdist_target or 0
end
local function WatchingMinigame_MaxDist(inst)
	local minigame = WatchingMinigame(inst)
	return minigame ~= nil and minigame.components.minigame.watchdist_max or 0
end

function MomoBrain:OnStart()
    local want_to_feed = IfNode(function() return self.inst.components.brainhelper:feed_condition() end, "feed",
        WhileNode(function() return self.inst.components.brainhelper:feed_rejection() end, "keep feed",
            LoopNode{
                DoAction(self.inst, Feed)
            }
        )
    )

	local watch_game = WhileNode(function() return ShouldWatchMinigame(self.inst) end, "Watching Game",
        PriorityNode({
            Follow(self.inst, WatchingMinigame, WatchingMinigame_MinDist, WatchingMinigame_TargetDist, WatchingMinigame_MaxDist),
            RunAway(self.inst, "minigame_participator", 5, 7),
            FaceEntity(self.inst, WatchingMinigame, WatchingMinigame),
        }, 0.25))

    local dance_party = WhileNode(function() return ShouldDanceParty(self.inst) end, "Dance Party",
            PriorityNode({
                Leash(self.inst, GetLeaderPos, KEEP_DANCING_DIST, KEEP_DANCING_DIST),
                ActionNode(function() DanceParty(self.inst) end),
        }, 0.25))

    local face_honey = FaceEntity(self.inst, GetFaceLeaderFn, KeepFaceLeaderFn)

    -- local root = PriorityNode({ -- This protector is set to defend an area and then vanish.
    --     -- Fun stuff.
    --     dance_party,
    --     watch_game,
    --     -- Attack.
    --     ChaseAndAttack(self.inst),
    --     -- Leashing is low priority.
    --     Leash(self.inst, GetSpawn, math.min(8, TUNING.SHADOWWAXWELL_PROTECTOR_DEFEND_RADIUS), math.min(4, TUNING.SHADOWWAXWELL_PROTECTOR_DEFEND_RADIUS)),
    --     -- Wander around and stare.
    --     face_honey,
    --     ParallelNode{
    --         CreateWanderer(self, math.min(6, TUNING.SHADOWWAXWELL_PROTECTOR_DEFEND_RADIUS)),
    --         CreateIdleOblivion(self, TUNING.SHADOWWAXWELL_MINION_IDLE_DESPAWN_TIME, TUNING.SHADOWWAXWELL_PROTECTOR_DEFEND_RADIUS),
    --     },
    -- }, 0.25)

    root = PriorityNode({
        --#1 priority is dancing beside your leader. Obviously.
        dance_party,
        watch_game,

        WhileNode(function() return IsNearLeader(self.inst, KEEP_WORKING_DIST) end, "Leader In Range",
            PriorityNode({
                --All shadows will avoid explosives
                avoid_explosions,
                --Duelists will try to fight before fleeing
                IfNode(function() return self.inst.prefab == "shadowduelist" end, "Is Duelist",
                    PriorityNode({
                        WhileNode(function() return self.inst.components.combat:GetCooldown() > .5 and ShouldKite(self.inst.components.combat.target, self.inst) end, "Dodge",
                            RunAway(self.inst, { fn = ShouldKite, tags = { "_combat", "_health" }, notags = { "INLIMBO" } }, KITING_DIST, STOP_KITING_DIST)),
                        ChaseAndAttack(self.inst),
                }, .25)),
                --All shadows will flee from danger at this point
                avoid_danger,
                --Workers will try to work if not fleeing
                WhileNode(function() return self.inst.prefab == "shadowlumber" and not self.inst.sg:HasStateTag("phasing") end, "Keep Chopping",
                    DoAction(self.inst, function() return FindEntityToWorkAction(self.inst, ACTIONS.CHOP) end)),
                WhileNode(function() return self.inst.prefab == "shadowminer" and not self.inst.sg:HasStateTag("phasing") end, "Keep Mining",
                    DoAction(self.inst, function() return FindEntityToWorkAction(self.inst, ACTIONS.MINE) end)),
                WhileNode(function() return self.inst.prefab == "shadowdigger" and not self.inst.sg:HasStateTag("phasing") end, "Keep Digging",
                    DoAction(self.inst, function() return FindEntityToWorkAction(self.inst, ACTIONS.DIG, DIG_TAGS) end)),
        }, 0.25)),

        Follow(self.inst, GetLeader, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),

        face_player,
    }, 0.25)

    self.bt = BT(self.inst, root)
end

return MomoBrain
