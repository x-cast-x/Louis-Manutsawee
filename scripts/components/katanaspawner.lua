--------------------------------------------------------------------------
--[[ katanaspawner class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

    assert(TheWorld.ismastersim, "Katana Spawner should not exist on client")

    self.inst = inst

    local katanas = {
        has_mortalblade = false,
        has_muramasa = false,
    }

    local has_mortalblade = false
    local has_tenseiga = false
    local has_bakusaiga = false
    local has_tessaiga = false
    local has_muramasa = false
    local has_tokishin = false

    function self.AddKatana(name, katana)
        katanas[name] = katana
    end

    function self.GetHasKatana(name)
        if katanas[name] ~= nil then
            return katanas[name]
        end
    end

    function self.SetHasKatana(name ,val)
        if katanas[name] ~= nil then
            katanas[name] = val
        end
    end

    function self:OnSave()
        return {
            katanas = katanas
        }
    end

    function self:OnLoad(data)
        if data ~= nil then
            katanas = data.katanas
        end
    end

    function self:GetDebugString()
        return string.format("%s, The World has ")
    end

end)
