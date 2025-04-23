local Beard = require("components/beard")
return Class(Beard, function(self, inst)
    Beard._ctor(self)

    local Hair_Growth_Lengths = {
        cut = { days = 3, bits = 0 },
        short = { days = 7, bits = 2 },
        medium = { days = 16, bits = 3 },
        long = { days = 24, bits = 4 }
    }

    local Hair_Styles = {"none", "_yoto", "_ronin", "_pony", "_twin", "_htwin", "_ball"}
    local Hair_Symbols = {"hairpigtails", "hair", "hair_hat", "headbase", "headbase_hat"}

    local hair_length = "cut"
    local hair_style = "none"

    local function SetHairGrowthLength(inst, length, style)
        if Hair_Growth_Lengths[length] then
            hair_length = length
            hair_style = (length == "cut") and "none" or style

            for _, symbol in ipairs(Hair_Symbols) do
                if style == "cut" then
                    inst.AnimState:ClearOverrideSymbol(symbol)
                else
                    local override_build = "hair_" .. length .. (style ~= "none" and style or "")
                    inst.AnimState:OverrideSymbol(symbol, override_build, symbol)
                end
            end

            inst.components.hair.bits = Hair_Growth_Lengths[length].bits
            inst.components.hair.daysgrowth = Hair_Growth_Lengths[length].days
            inst.components.hair.insulation_factor = style and 1 or 1.5
        end
    end

    local function OnDeath(inst)
        SetHairGrowthLength(inst, "cut", "none")
    end

    local function OnResetHair(inst)
        SetHairGrowthLength(inst, (hair_length == "long" and "medium") or (hair_length == "medium" and "short") or "cut")
    end

    local function GetNextHairStyle(style)
        for i, v in ipairs(Hair_Styles) do
            if v == style then
                return i
            end
        end
    end

    function self:SetHairStyle(style)
        SetHairGrowthLength(inst, hair_length, style)
    end

    function self:ChangeHairStyle()
        local current_index = GetNextHairStyle(hair_style) or 0
        SetHairGrowthLength(inst, hair_length, Hair_Styles[(current_index % #Hair_Styles) + 1])
    end

    function self:GetHairLength()
        return hair_length
    end

    function self:GetHairStyle()
        return hair_style
    end

    function self:GetDebugString()
        return string.format("Hair Length: %s, Hair Style: %s", tostring(hair_length), tostring(hair_style))
    end

    function self:OnSave()
        local data = {
            hair_length = hair_length,
            hair_style = hair_style,
        }
        return data
    end

    function self:OnLoad(data)
        if data ~= nil then
            hair_length = data.hair_length
            hair_style = data.hair_style
        end
    end

    inst:ListenForEvent("death", OnDeath)
end)
