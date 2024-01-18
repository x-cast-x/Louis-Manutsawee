local function OnAttackOther(inst, data)
    if inst.components.rider:IsRiding() then
        return
    end

    local kenjutsuka = inst.components.kenjutsuka
    local kenjutsuexp = kenjutsuka.kenjutsuexp
    local kenjutsumaxexp = kenjutsuka.kenjutsumaxexp

    if kenjutsuexp >= kenjutsumaxexp then
        kenjutsuexp = kenjutsuexp - kenjutsumaxexp
        kenjutsuka:KenjutsuLevelUp()
    end
end

local Kenjutsuka = Class(function(self, inst)
    self.inst = inst

    self.is_master = M_CONFIG.IS_MASTER
	self.kenjutsulevel = 0
	self.kenjutsuexp = 0
	self.kenjutsumaxexp = 250

    self.onupgrade = nil

    self.inst:ListenForEvent("onattackother", OnAttackOther)
end)

function Kenjutsuka:SetOnUpgrade(fn)
    self.onupgrade = fn
end

function Kenjutsuka:KenjutsuLevelUp()
    if self.onupgrade ~= nil then
        self.onupgrade(self.inst)
    end


end

function Kenjutsuka:OnSave()
    return {
        kenjutsuexp = self.kenjutsuexp,
        kenjutsulevel = self.kenjutsulevel,
    }
end

function Kenjutsuka:OnLoad(data)
    self.kenjutsulevel = data.kenjutsulevel
	self.kenjutsuexp = data.kenjutsuexp
end

return Kenjutsuka
