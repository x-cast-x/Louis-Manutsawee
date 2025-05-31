--------------------------------------------------------------------------
--[[ Player Key Handler Status class definition ]]
--------------------------------------------------------------------------

local PlayerKeyHandler = Class(function(self, inst)
    self.inst = inst
end)

local IsActiveHUDScreen = function()
    return (TheFrontEnd:GetActiveScreen().name == "HUD") or false
end

function PlayerKeyHandler:HandleKeyAction(namespace, action, ...)
    if IsActiveHUDScreen() then
        if TheWorld.ismastersim then
            local fn = GetModRPCHandler(namespace, action)
            if fn ~= nil then
                fn(self.inst, ...)
            end
        else
            SendModRPCToServer(GetModRPC(namespace, action))
        end
    end
end

function PlayerKeyHandler:AddKeyListener(namespace, key, action)
    TheInput:AddSpecialKeyHandler(key, function(_key, down)
        if key == _key then
            for k, v in pairs(TheInput.pressed_keys) do
                if k ~= key then
                    return false
                end
            end
            return self:HandleKeyAction(namespace, action) or false
        end
    end)
end

function PlayerKeyHandler:AddCombinationKeyListener(namespace, key, _key, action)
    TheInput:AddCombinationKeyHandler(key, _key, function(key, pressed_key)
        self:HandleKeyAction(namespace, action)
    end)
end

function PlayerKeyHandler:AddSequentialKeyHandler(namespace, key, _key, action)
    TheInput:AddSequentialKeyHandler(key, _key, function(key, last_key_released)
        self:HandleKeyAction(namespace, action)
    end)
end


return PlayerKeyHandler
