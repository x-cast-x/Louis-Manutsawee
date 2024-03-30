
local function oninactive(self, inactive)
    if inactive then
        self.inst:AddTag("momocube_inactive")
    else
        self.inst:RemoveTag("momocube_inactive")
    end
end

local MomoCube = Class(function(self, inst)
    self.inst = inst

	self.inactive = true
end,
nil,
{
    inactive = oninactive,
})

function MomoCube:OnRemoveFromEntity()
    self.inst:RemoveTag("momocube_inactive")
end

function MomoCube:CanTrans(doer, target, pos)
	return self.inactive and (self.CanTransFn == nil or self.CanTransFn(self.inst, doer, target, pos))
end

function MomoCube:Transform(doer, target, pos)
	if self.Transformation ~= nil and self.inactive then
		self.Transformation(self.inst, doer, target, pos)
	end
end

return MomoCube
