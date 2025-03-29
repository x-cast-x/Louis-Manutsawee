AddModRPCHandler("LouisManutsawee", "ChangeHairStyle", function(inst, skinname)
    local hair_length = inst.components.hair:GetHairLength()
    if hair_length == "cut" then
        inst.components.talker:Say(STRINGS.SKILL.HAIRTOOSHORT)
        return
    end

    local function CanChangeHair(inst)
        local not_dead = not (inst.components.health ~= nil and inst.components.health:IsDead() and inst.sg:HasStateTag("dead"))
                         and not inst:HasTag("playerghost")
        local is_idle = inst.sg:HasStateTag("idle") or inst:HasTag("idle")
        local not_doing = not (inst.sg:HasStateTag("doing") or inst.components.inventory:IsHeavyLifting())
        local not_moving = not (inst.sg:HasStateTag("moving") or inst:HasTag("moving"))

        return not_dead and not_doing, not_moving, is_idle
    end

    local can_change, not_moving, is_idle = CanChangeHair(inst)
    if can_change and not_moving and is_idle then
        if not inst.components.timer:TimerExists("change_hair_cd") then
            inst.components.timer:StartTimer("change_hair_cd", 1.4)

            inst:DoTaskInTime(0.1, function()
                inst:PushEvent("changehair")
            end)
        end
    end
end)

-- Use the inheritance provided by Class, inheriting from Beard
-- see class.lua

return Class(Beard, function(self, inst)
    self.inst = inst

    local beard = inst:AddComponent("beard")
    local HAIR_DAYS = {cut = 3, short = 7, medium = 16}
    local HAIR_BITS = {cut = 0, short = 2, medium = 3, long = 3}
    local HAIR_TYPES = {none = nil, yoto = "yoto", ronin = "ronin", pony = "pony", twin = "twin", htwin = "htwin", ball = "ball"}
    local HAIR_SYMBOLS = {"hairpigtails", "hair", "hair_hat", "headbase", "headbase_hat"}

    local hair_length = "short"
    local hair_type = nil

    local function OnCutHair(inst)
        hair_length = "short"
        hair_type = nil
        for _, symbol in ipairs(HAIR_SYMBOLS) do
            inst.AnimState:ClearOverrideSymbol(symbol)
        end
    end

    local function OnGrowHair(inst, length, day)
        hair_length = length
        beard.bits = HAIR_BITS[length]

        if day then
            beard.daysgrowth = HAIR_DAYS[day]
        end

        inst.components.hair:OnChangeHair()
    end

    local function OnResetHair(inst)
        if hair_length == "medium" then
            OnGrowHair(inst, "long", "medium")
        elseif hair_length == "short" then
            OnGrowHair(inst, "medium", "short")
        else
            OnCutHair(inst)
        end
    end

    beard.insulation_factor = 1.5
    beard.onreset = OnResetHair
    beard.prize = "beardhair"
    beard.is_skinnable = false
    beard:AddCallback(HAIR_DAYS["cut"], function(inst) OnGrowHair(inst, "short") end)
    beard:AddCallback(HAIR_DAYS["short"], function(inst) OnGrowHair(inst, "medium") end)
    beard:AddCallback(HAIR_DAYS["medium"], function(inst) OnGrowHair(inst, "long") end)

    function self:GetHairTypes()
        return HAIR_TYPES
    end

    function self:GetCurrentHairType()
        return hair_type
    end

    function self:SetHairType(type)
        hair_type = type
    end

    function self:GetHairLength()
        return hair_length
    end

    function self:OnChangeHair()
        if hair_length == "short" and (hair_type ~= nil) then
            hair_type = nil
        end

        local override_build = "hair_" .. hair_length .. (hair_type or "")

        -- When rest, bocchi's headgear will be pushed off. I don't want to deal with it anymore.
        -- Maybe I should add another layer?
        for _, symbol in ipairs(HAIR_SYMBOLS) do
            inst.AnimState:OverrideSymbol(symbol, override_build, symbol)
        end

        beard.insulation_factor = hair_type and .1 or 1.5
    end

    function self:OnLoad(data)
        hair_length = data.hair_length
        hair_type = data.hair_type

        self:OnChangeHair()
    end

    function self:OnSave()
        return {
            hair_length = hair_length,
            hair_type = hair_type,
        }
    end
end)
