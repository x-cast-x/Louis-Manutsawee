--------------------------------------------------------------------------
--[[ Player Key Handler Status class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

    --------------------------------------------------------------------------
    --[[ Dependencies ]]
    --------------------------------------------------------------------------

    --------------------------------------------------------------------------
    --[[ Member variables ]]
    --------------------------------------------------------------------------

    -- Public
    self.inst = inst

    -- Private
    local _world = TheWorld
    local _ismastersim = _world.ismastersim
    local _frontend = TheFrontEnd
    local _input = TheInput

    --------------------------------------------------------------------------
    --[[ Private member functions ]]
    --------------------------------------------------------------------------

    local IsActiveHUDScreen = function(inst)
        local screen = _frontend:GetActiveScreen().name
        if screen == "HUD" and ((not inst:HasTag("time_stopped")) and (not inst:HasTag("sleeping"))) then
            return true
        end
        return false
    end

    local HandleKeyAction = function(namespace, action, ...)
        if IsActiveHUDScreen(inst) then
            if _ismastersim then
                local fn = GetModRPCHandler(namespace, action)
                if fn ~= nil then
                    fn(inst, ...)
                end
            else
                SendModRPCToServer(GetModRPC(namespace, action))
            end
        end
    end

    --------------------------------------------------------------------------
    --[[ Private event handlers ]]
    --------------------------------------------------------------------------


    --------------------------------------------------------------------------
    --[[ Public member functions ]]
    --------------------------------------------------------------------------

    function self:AddKeyUpListener(namespace, key, action)
        _input:AddKeyUpHandler(key, function(_key)
            HandleKeyAction(namespace, action, key, _key)
        end)
    end

    function self:AddCombinationKeyListener(namespace, key, _key, action)
        _input:AddCombinationKeyHandler(key, _key, function(key, pressed_key)
            HandleKeyAction(namespace, action, key, _key, pressed_key)
        end)
    end

    function self:AddSequentialKeyHandler(namespace, key, _key, action)
        _input:AddSequentialKeyHandler(key, _key, function(key, last_key_released)
            HandleKeyAction(namespace, action, key, last_key_released)
        end)
    end

    --------------------------------------------------------------------------
    --[[ Save/Load ]]
    --------------------------------------------------------------------------



    --------------------------------------------------------------------------
    --[[ OnRemoveEntity ]]
    --------------------------------------------------------------------------

    --------------------------------------------------------------------------
    --[[ Debug ]]
    --------------------------------------------------------------------------

    --------------------------------------------------------------------------
    --[[ Initialization ]]
    --------------------------------------------------------------------------

    -- Register events


    --------------------------------------------------------------------------
    --[[ Post initialization ]]
    --------------------------------------------------------------------------


    --------------------------------------------------------------------------
    --[[ End ]]
    --------------------------------------------------------------------------

end)
