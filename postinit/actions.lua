GLOBAL.setfenv(1, GLOBAL)

local _BAIT_fn = ACTIONS.BAIT.fn
ACTIONS.BAIT.fn = function(act)
    if act.target.components.trap and act.doer:HasTag("naughtychild") then
        act.target.components.trap:SetBait(act.doer.components.inventory:RemoveItem(act.invobject), act.doer)
        return true
    end
    return _BAIT_fn(act)
end
