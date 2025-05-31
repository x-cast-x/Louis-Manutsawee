--[[
this is a dummy component that does nothing
it is used to check if an entity has a component without actually doing anything
use for testing
]]

local NilCmp = Class(function(self, inst)
    self.inst = inst
end)

function NilCmp:OnLoad(data)
    if data then

    end
end

function NilCmp:OnSave()
    return {}
end

return NilCmp
