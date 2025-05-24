return Class(function(self, inst)
    self.inst = inst

    local Hair_Growth_Lengths = {
        short  = { days = 3,  bits = 2 },
        medium = { days = 7,  bits = 5 },
        long   = { days = 16, bits = 9 },
    }

    local Hair_Lengths = {"cut", "short", "medium", "long"}
    local Hair_Styles  = {"", "_yoto", "_ronin", "_pony", "_twin", "_htwin", "_ball" }
    local Hair_Symbols = {"hairpigtails", "hair", "hair_hat", "headbase", "headbase_hat"}

    local hair_length = 1
    local hair_style  = 1

    local function GetHairLengthIndex(length)
        for i, v in ipairs(Hair_Lengths) do
            if v == length then
                return i
            end
        end
        return nil
    end

    local function SetCutHairLength(inst)
        hair_length = 1
        hair_style  = 1
        for i = 1, #Hair_Symbols do
            inst.AnimState:ClearOverrideSymbol(Hair_Symbols[i])
        end
    end

    local function SetHairLength(inst)
        local atlas = "hair_" .. Hair_Lengths[hair_length] .. Hair_Styles[hair_style]
        for i = 1, #Hair_Symbols do
            inst.AnimState:OverrideSymbol(Hair_Symbols[i], atlas, Hair_Symbols[i])
        end

        inst.components.beard.insulation_factor = (hair_style <= 2) and 1 or 0.1
    end

    local function SetHairGrowthLength(inst, length)
        hair_length = GetHairLengthIndex(length) or 1
        inst.components.beard.bits = Hair_Growth_Lengths[length].bits
        SetHairLength(inst)
    end

    local function OnResetHair(inst)
        if hair_length > 2 then
            hair_length = hair_length - 1
            local length = Hair_Lengths[hair_length]
            inst.components.beard.daysgrowth = Hair_Growth_Lengths[length].days
            SetHairGrowthLength(inst, length)
        else
            SetCutHairLength(inst)
        end
    end

    local function OnEquip(inst, data)
        local eslot = data.eslot
        if eslot ~= nil and eslot == EQUIPSLOTS.HEAD then
            SetHairLength(inst)
        end
    end

    function self:SetUpHair()
        local beard = inst:AddComponent("beard")
        beard.insulation_factor = 1
        beard.onreset = OnResetHair
        beard.prize = "beardhair"
        beard.is_skinnable = false

        beard:AddCallback(Hair_Growth_Lengths.short.days,  function() SetHairGrowthLength(inst, "short")  end)
        beard:AddCallback(Hair_Growth_Lengths.medium.days, function() SetHairGrowthLength(inst, "medium") end)
        beard:AddCallback(Hair_Growth_Lengths.long.days,   function() SetHairGrowthLength(inst, "long")   end)
    end

    function self:ChangeHairStyle()
        hair_style = hair_style % #Hair_Styles + 1
        SetHairLength(inst)
    end

    function self:GetHairLength()
        return Hair_Lengths[hair_length]
    end

    function self:GetHairStyle()
        return Hair_Styles[hair_style]
    end

    function self:GetDebugString()
        local hair_style = self:GetHairStyle()
        return string.format("Hair Length: %s, Hair Style: %s",
            tostring(self:GetHairLength()),
            tostring(hair_style == "" and "None" or hair_style)
        )
    end

    function self:OnSave()
        return {
            hair_length = hair_length,
            hair_style  = hair_style,
        }
    end

    function self:OnLoad(data)
        if data ~= nil then
            hair_length = data.hair_length or hair_length
            hair_style  = data.hair_style  or hair_style
            inst:DoTaskInTime(0, SetHairLength)
        end
    end

    inst:ListenForEvent("equip", OnEquip)
    inst:ListenForEvent("death", SetCutHairLength)
end)
