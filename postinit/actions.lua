GLOBAL.setfenv(1, GLOBAL)

local _BAIT_fn = ACTIONS.BAIT.fn
-- override this function
ACTIONS.BAIT.fn = function(act)
    if act.target.components.trap then
        act.target.components.trap:SetBait(act.doer.components.inventory:RemoveItem(act.invobject), act.doer)
        return true
    end
end
