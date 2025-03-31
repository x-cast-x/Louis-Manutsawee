local Tool = require("components/tool")
GLOBAL.setfenv(1, GLOBAL)

function Tool:RemoveAction(action, effectiveness)
    assert(TOOLACTIONS[action.id], "invalid tool action")
    self.actions[action] = nil
    self.inst:RemoveTag(action.id.."_tool")
end
