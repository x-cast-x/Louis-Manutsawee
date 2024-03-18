local AddComponentAction = AddComponentAction
GLOBAL.setfenv(1, GLOBAL)

local _BAIT_fn = ACTIONS.BAIT.fn
-- override this function
ACTIONS.BAIT.fn = function(act)
    if act.target.components.trap then
        act.target.components.trap:SetBait(act.doer.components.inventory:RemoveItem(act.invobject), act.doer)
        return true
    end
end

-- SCENE        using an object in the world
-- USEITEM      using an inventory item on an object in the world
-- POINT        using an inventory item on a point in the world
-- EQUIPPED     using an equiped item on yourself or a target object in the world
-- INVENTORY    using an inventory item
local M_COMPONENT_ACTIONS = {
    SCENE = { -- args: inst, doer, actions, right
    },

    USEITEM = { -- args: inst, doer, target, actions, right
    },

    POINT = { -- args: inst, doer, pos, actions, right, target
    },

    EQUIPPED = { -- args: inst, doer, target, actions, right
    },

    INVENTORY = { -- args: inst, doer, actions, right
        momocube = function(inst, doer, actions)
            if inst:HasTag("momocube_inactive") and doer:HasTag("momocubecaster") and inst:HasTag("momocube") then
                if not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding()) or inst:HasTag("momocube_mountedcast") then
                    table.insert(actions, ACTIONS.TRANSFORMATION)
                end
            end
        end,
    },

    ISVALID = { -- args: inst, action, right
    },
}

for actiontype, actons in pairs(M_COMPONENT_ACTIONS) do
    for component, fn in pairs(actons) do
        AddComponentAction(actiontype, component, fn)
    end
end
