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

--[[
require "behaviours/wander"
require "behaviours/chaseandattack"
require "behaviours/panic"
require "behaviours/attackwall"
require "behaviours/minperiod"
require "behaviours/leash"
require "behaviours/faceentity"
require "behaviours/doaction"
require "behaviours/standstill"
require "behaviours/runaway"

local BrainCommon = require "brains/braincommon"

local Shadow_Dwx_Brain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
    --self.reanimatetime = nil
end)

local MIN_FOLLOW_LEADER = 0
local MAX_FOLLOW_LEADER = 10
local TARGET_FOLLOW_LEADER = 7

-----------搜索周围砍树的距离
local SEE_TREE_DIST = 15
local KEEP_CHOPPING_DIST = 10

local KEEP_WORKING_DIST = 14 --在领导者附近这个距离可以工作
local SEE_WORK_DIST = 10 --在领导者这个范围寻找可以工作的目标
--------------风筝敌人
local KITING_DIST = 3
local STOP_KITING_DIST = 5

local RUN_AWAY_DIST = 5
local STOP_RUN_AWAY_DIST = 8
--------------------
local LEASH_RETURN_DIST = 10
local LEASH_MAX_DIST = 40

local HOUSE_MAX_DIST = 40
local HOUSE_RETURN_DIST = 50

local SIT_BOY_DIST = 10
local SEE_BUSH_DIST = 24

local DIG_TAGS = { "stump", "grave", "farm_debris" }

local function Unignore(inst, sometarget, ignorethese)
    ignorethese[sometarget] = nil
end
local function IgnoreThis(sometarget, ignorethese, leader, worker)
    if ignorethese[sometarget] ~= nil and ignorethese[sometarget].task ~= nil then
        ignorethese[sometarget].task:Cancel()
        ignorethese[sometarget].task = nil
    else
        ignorethese[sometarget] = { worker = worker, }
    end
    ignorethese[sometarget].task = leader:DoTaskInTime(5, Unignore, sometarget, ignorethese)
end

local function GetLeader(inst)
    return inst.components.follower.leader
end

local function GetHome(inst)
    return inst.components.homeseeker and inst.components.homeseeker.home or nil
end

-------------砍树相关
--local TOWORK_CANT_TAGS = { "fire", "smolder", "event_trigger", "INLIMBO", "NOCLICK", "carnivalgame_part" }
--local function FindEntityToWorkAction(inst, action, addtltags)
--    -- DEPRECATED, use FindAnyEntityToWorkActionsOn.
--    local leader = GetLeader(inst)
--    local target = inst.sg.statemem.target
--    if leader ~= nil
--            --只能协同领导者执行劈砍的动作
--            and ((target ~= nil and target.components.workable and target.components.workable:CanBeWorked() and target.components.workable:GetWorkAction() == ACTIONS.CHOP)
--            or (leader.sg and leader.sg:HasStateTag("chopping"))) then
--        --Keep existing target?
--        if target ~= nil and
--                target:IsValid() and
--                not (target:IsInLimbo() or target:HasTag("NOCLICK") or target:HasTag("event_trigger")) and
--                target:IsOnValidGround() and target.components.workable ~= nil and target.components.workable:CanBeWorked() and target.components.workable:GetWorkAction() == action
--                and not (target.components.burnable ~= nil
--                and (target.components.burnable:IsBurning() or
--                target.components.burnable:IsSmoldering())) and
--                target.entity:IsVisible() and
--                target:IsNear(leader, KEEP_WORKING_DIST) then
--
--            if addtltags ~= nil then
--                for i, v in ipairs(addtltags) do
--                    if target:HasTag(v) then
--                        return BufferedAction(inst, target, action)
--                    end
--                end
--            else
--                return BufferedAction(inst, target, action)
--            end
--        end
--
--        --Find new target
--        target = FindEntity(leader, SEE_WORK_DIST, nil, { action.id .. "_workable" }, TOWORK_CANT_TAGS, addtltags)
--        return target ~= nil and BufferedAction(inst, target, action) or nil
--    end
--end

---------------
--风筝敌人
local function ShouldKite(target, inst)
    return inst.components.combat:TargetIs(target)
            and target.components.health ~= nil
            and not target.components.health:IsDead()
end

--
local function GetHomePos(inst)
    local home = GetHome(inst)
    return home ~= nil and home:GetPosition() or nil
end

local function GetNoLeaderLeashPos(inst)
    return GetLeader(inst) == nil and GetHomePos(inst) or nil
end

local function ShouldStandStill(inst)
    --HasTag("sxy")我不知道该不该加，不加不会有什么问题
    return inst:HasTag("sxy") and not TheWorld.state.isday and not GetLeader(inst) and not inst.components.combat:HasTarget()
end

local excludes = { "INLIMBO", "burnt", "oldfish_farmer", "oldfish_farmhome", "insect", "playerghost", "animal", "player", "spider" }

local function HasBerry(item, inst)
    if item.components.dryer then
        return item:HasTag("dried")

    elseif item.components.harvestable
            and item.components.harvestable:CanBeHarvested()
            and (item:HasTag("beebox") or item:HasTag("mushroom_farm")) then
        return true

    elseif item.components.crop ~= nil then
        if item.components.crop:IsReadyForHarvest() or item:HasTag("withered") then
            return true
        end
    else
        if item.components.pickable ~= nil then
            return item.components.pickable.canbepicked
                    --这里对可采集的物品使用排除法
                    and item.prefab ~= "flower"
        end
    end
end

local function PickBerriesAction(inst)
    local leader = inst.components.follower.leader or nil
    if inst.prefab ~= "shadow_ly" then
        return
    end
    if inst.components.inventory and inst.components.inventory:IsFull() then
        return
    end

    local target = FindEntity(inst, SEE_BUSH_DIST, HasBerry, nil, excludes)
    if inst.pickbrain --按下技能后
            and target and leader and leader:IsNear(target, SEE_BUSH_DIST) then
        --nd inst.home and inst.home:IsValid() and inst.home:IsNear(target, SEE_BUSH_DIST)

        if target:HasTag("dried") then
            return BufferedAction(inst, target, ACTIONS.HARVEST)

        elseif target:HasTag("beebox") and target.components.harvestable.produce >= 6 then
            return BufferedAction(inst, target, ACTIONS.HARVEST)

        elseif target.components.crop then
            if target.components.crop:IsReadyForHarvest() or target:HasTag("withered") then
                return BufferedAction(inst, target, ACTIONS.HARVEST)
            end

        elseif target:HasTag("mushroom_farm") and target.components.harvestable.produce >= 4 then
            return BufferedAction(inst, target, ACTIONS.HARVEST)
        elseif target.components.pickable then
            return BufferedAction(inst, target, ACTIONS.PICK)
        end
    end
end

function Shadow_Dwx_Brain:OnStart()
    local root = PriorityNode({
        WhileNode(function()
            return not self.inst.sg:HasStateTag("jumping")
        end, "NotJumpingBehaviour", PriorityNode({
            WhileNode(function()
                return GetLeader(self.inst) == nil
            end, "NoLeader", AttackWall(self.inst)),

            ---------------------风筝敌人相关
            -- if self.inst == "shadow_ly"
            WhileNode(function()
                return self.inst.prefab == "shadow_ly" and self.inst.components.combat:GetCooldown() > .5 and ShouldKite(self.inst.components.combat.target, self.inst)
            end, "Dodge",
                    RunAway(self.inst, { fn = ShouldKite, tags = { "_combat", "_health" }, notags = { "INLIMBO" } }, KITING_DIST, STOP_KITING_DIST)),

            ChaseAndAttack(self.inst),
            ---------------------收集物资
            DoAction(self.inst, PickBerriesAction, "Pick Thing", true),

            ---------------------协同工作
            BrainCommon.NodeAssistLeaderDoAction(self, {
                action = "CHOP", -- Required.
                --chatterstring = "MERM_TALK_HELP_CHOP_WOOD", --协同工作时说的话，我不知道如何替换，这个是跟self绑定的
            }),

            BrainCommon.NodeAssistLeaderDoAction(self, {
                action = "MINE", -- Required.
            }),

            ---------------------
            Leash(self.inst, GetNoLeaderLeashPos, HOUSE_MAX_DIST, HOUSE_RETURN_DIST),

            Follow(self.inst, GetLeader, MIN_FOLLOW_LEADER, TARGET_FOLLOW_LEADER, MAX_FOLLOW_LEADER),
            FaceEntity(self.inst, GetLeader, GetLeader), --一直朝向领导者

            StandStill(self.inst, ShouldStandStill),
        }, .25)),
    }, .25)

    self.bt = BT(self.inst, root)
end

return Shadow_Dwx_Brain

]]

return MomoBrain
