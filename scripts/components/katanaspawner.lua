--------------------------------------------------------------------------
--[[ Katana Spawner class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

    assert(TheWorld.ismastersim, "Katana Spawner should not exist on client")

    --------------------------------------------------------------------------
    --[[ Member variables ]]
    --------------------------------------------------------------------------

    self.inst = inst

    local _world = TheWorld
    local _ismastersim = _world.ismastersim
    local LouisManutsawee, SyncKatanaData = "LouisManutsawee", "SyncKatanaData"

    local katanas = {}

    print("Loading KatanaSpawner...")

    --------------------------------------------------------------------------
    --[[ Private member functions ]]
    --------------------------------------------------------------------------

    local SendModRPCToAllShards = function(id_table, ...)
        local sender_list = {}
        for i, v in pairs(Shard_GetConnectedShards()) do
            sender_list[#sender_list + 1] = i
        end

        SendModRPCToShard(id_table, sender_list, ...)
    end

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
        SendModRPCToAllShards(GetShardModRPC(LouisManutsawee, SyncKatanaData), true, name)
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
        SendModRPCToAllShards(GetShardModRPC(LouisManutsawee, SyncKatanaData), false, name)
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

    function self:PrintKatanas()
        for k, v in pairs(katanas) do
           print(k,v)
        end
    end

    --------------------------------------------------------------------------
    --[[ Save/Load ]]
    --------------------------------------------------------------------------

    if _ismastersim then function self:OnSave(data)
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
