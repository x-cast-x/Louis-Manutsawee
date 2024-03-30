local AddAction = AddAction
local Vector3 = GLOBAL.Vector3
local AddComponentAction = AddComponentAction
local modimport = modimport
GLOBAL.setfenv(1, GLOBAL)

local ACTIONS = {
    MDODGE = Action({distance = math.huge, instant = true}),
    MDODGE2 = Action({distance = math.huge, instant = true}),
    TRANSFORMATION = Action({ priority=-1, rmb=true, mount_valid=true }),
}

for name, ACTION in pairs(ACTIONS) do
    ACTION.id = name
    ACTION.str = STRINGS.ACTIONS[name] or "Unknown ACTION"
    AddAction(ACTION)
end

ACTIONS.MDODGE.fn = function(act, data)
    if act.doer ~= nil then
        act.doer:PushEvent("redirect_locomote", {pos = act.pos or Vector3(act.target.Transform:GetWorldPosition())})
    end
    return true
end

ACTIONS.MDODGE2.fn = function(act, data)
    if act.doer ~= nil then
        act.doer:PushEvent("redirect_locomote2", {pos = act.pos or Vector3(act.target.Transform:GetWorldPosition())})
    end
    return true
end

ACTIONS.TRANSFORMATION.fn = function(act)
    local caster = act.doer
    if act.invobject ~= nil and caster ~= nil and caster:HasTag("momocubecaster") then
		act.invobject.components.momocube:Transform(caster, act.target, act:GetActionPoint())
	end
    return true
end

local M_COMPONENT_ACTIONS = {
    SCENE = {
    },

    USEITEM = {
    },

    POINT = {
    },

    EQUIPPED = {
    },

    INVENTORY = {
        momocube = function(inst, doer, actions)
            if inst:HasTag("momocube_inactive") and doer:HasTag("momocubecaster") and inst:HasTag("momocube") then
                if not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding()) or inst:HasTag("momocube_mountedcast") then
                    table.insert(actions, ACTIONS.TRANSFORMATION)
                end
            end
        end,
    },

    ISVALID = {
    },
}

for actiontype, actons in pairs(M_COMPONENT_ACTIONS) do
    for component, fn in pairs(actons) do
        AddComponentAction(actiontype, component, fn)
    end
end

modimport("postinit/actions")
