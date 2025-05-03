return Class(function(self, inst)

    self.inst = inst

    local is_puted = false

    local glasses = {}

    function self:UpdateGlass(puted)
        local build = glasses[inst.AnimState:GetBuild()]
        local symbol = build ~= nil and build or "eyeglasses"
        if puted then
            inst.AnimState:ClearOverrideSymbol("swap_face")
        else
            inst.AnimState:OverrideSymbol("swap_face", symbol, "swap_face")
        end
        is_puted = puted
    end

    function self:IsPuted()
        return is_puted
    end

    function self:AddGlass(build, glass_build)
        glasses[build] = glass_build
    end

    function self:OnSave()
        local data = {}
        data.is_puted = is_puted
        return data
    end

    function self:OnLoad(data)
        if data ~= nil then
            if data.is_puted then
                self:UpdateGlass(data.is_puted)
            end
        end
    end

    function self:GetDebugString()
        return string.format("Is Puted Glass: %s", tostring(is_puted))
    end
end)
