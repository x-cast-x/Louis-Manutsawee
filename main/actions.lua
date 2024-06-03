local AddAction = AddAction
local Vector3 = GLOBAL.Vector3
local AddComponentAction = AddComponentAction
local modimport = modimport
GLOBAL.setfenv(1, GLOBAL)

local M_ACTIONS = {
    MDODGE = Action({distance = math.huge, instant = true}),
    MDODGE2 = Action({distance = math.huge, instant = true}),
}

for name, ACTION in pairs(M_ACTIONS) do
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



local _BAIT_fn = ACTIONS.BAIT.fn
ACTIONS.BAIT.fn = function(act)
    if act.target.components.trap and act.doer:HasTag("naughtychild") then
        act.target.components.trap:SetBait(act.doer.components.inventory:RemoveItem(act.invobject), act.doer)
        return true
    end
    return _BAIT_fn(act)
end



-- local M_COMPONENT_ACTIONS = {
--     SCENE = {
--     },

--     USEITEM = {
--     },

--     POINT = {
--     },

--     EQUIPPED = {
--     },

--     INVENTORY = {
--     },

--     ISVALID = {
--     },
-- }

-- for actiontype, actons in pairs(M_COMPONENT_ACTIONS) do
--     for component, fn in pairs(actons) do
--         AddComponentAction(actiontype, component, fn)
--     end
-- end
