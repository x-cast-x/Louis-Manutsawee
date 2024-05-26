--------------------------------------------------------------------------
--[[ Katana Spawner class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

    assert(TheWorld.ismastersim, "Katana Spawner should not exist on client")

    --------------------------------------------------------------------------
    --[[ Dependencies ]]
    --------------------------------------------------------------------------

    local RPCUtil = require("utils/rpcutil")

    --------------------------------------------------------------------------
    --[[ Member variables ]]
    --------------------------------------------------------------------------

    self.inst = inst

    local _world = TheWorld
    local _ismastersim = _world.ismastersim
    local LouisManutsawee, SyncKatanaSpawnerData = "LouisManutsawee", "SyncKatanaSpawnerData"

    local katanas = {}

    print("Loading KatanaSpawner...")

    --------------------------------------------------------------------------
    --[[ Private member functions ]]
    --------------------------------------------------------------------------

    --------------------------------------------------------------------------
    --[[ Private event handlers ]]
    --------------------------------------------------------------------------

    local TrackKatana = _ismastersim and function(inst, data)
        local name = data.name
        print("Run TrackKatana")
        if katanas[name] then
            return
        end
        print("TrackKatana: " .. tostring(name))
        katanas[name] = true
        print("Send RPC: " .. LouisManutsawee .. " TrackKatana")
        RPCUtil.SendModRPCToAllShards(GetShardModRPC(LouisManutsawee, SyncKatanaSpawnerData), true, name)
    end or nil

    local ForgetKatana =  _ismastersim and function(inst, data)
        local name = data.name
        print("Run ForgetKatana")
        if not katanas[name] then
            return
        end
        print("ForgetKatana: " .. tostring(name))
        katanas[name] = nil
        print("Send RPC: " .. LouisManutsawee .. " ForgetKatana")
        RPCUtil.SendModRPCToAllShards(GetShardModRPC(LouisManutsawee, SyncKatanaSpawnerData), false, name)
    end or nil

    --------------------------------------------------------------------------
    --[[ Initialization ]]
    --------------------------------------------------------------------------

    if _ismastersim then
        inst:ListenForEvent("ms_trackkatana", TrackKatana, _world)
        inst:ListenForEvent("ms_forgetkatana", ForgetKatana, _world)
    end

    --------------------------------------------------------------------------
    --[[ Public member functions ]]
    --------------------------------------------------------------------------

    function self:GetKatana(name)
        return katanas[name] ~= nil and katanas[name] or nil
    end

    --------------------------------------------------------------------------
    --[[ Save/Load ]]
    --------------------------------------------------------------------------

    if _ismastersim then function self:OnSave()
        local data = {}
        data.katanas = katanas

        return data
    end end

    if _ismastersim then function self:OnLoad(data)
        if data ~= nil then
            if data.katanas ~= nil then
                katanas = data.katanas
            end
        end
    end end

    --------------------------------------------------------------------------
    --[[ Debug ]]
    --------------------------------------------------------------------------

    function self:GetDebugString()
        local str = "\n"
        for k, v in pairs(katanas) do
            str = str.."    --"..k..": "..tostring(v).."\n"
        end
        return string.format(str)
    end

    --------------------------------------------------------------------------
    --[[ End ]]
    --------------------------------------------------------------------------

end)
