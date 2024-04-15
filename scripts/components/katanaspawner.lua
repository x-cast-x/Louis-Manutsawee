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
    local _ismastershard = _world.ismastershard

    local katanas = {}

    --------------------------------------------------------------------------
    --[[ Private member functions ]]
    --------------------------------------------------------------------------

    --------------------------------------------------------------------------
    --[[ Private event handlers ]]
    --------------------------------------------------------------------------

    local TrackKatana = _ismastersim and function(name, katana)
        if _ismastershard then
            if katanas[name] then
                return
            end
            local function onremove()
                katanas[name] = nil
            end
            katanas[name] = { inst = katana, onremove = onremove }
            self.inst:ListenForEvent("onremove", onremove, katana)
            katanas[name] = katana
        else
            SendModRPCToShard(SHARD_MOD_RPC["manutsawee"]["SyncKatanaData"], 1, true, katana)
        end
    end or nil

    local ForgetKatana =  _ismastersim and function(name)
        if _ismastershard then
            if not katanas[name] then
                return
            end
            if katanas[name] ~= nil then
                self.inst:RemoveEventCallback("onremove", katanas[name].onremove, katanas[name].inst)
                katanas[name] = nil
            end
        else
            SendModRPCToShard(SHARD_MOD_RPC["manutsawee"]["SyncKatanaData"], 1, false, name)
        end
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
        return katanas[name] ~= nil and katanas[name].inst or nil
    end

    --------------------------------------------------------------------------
    --[[ Save/Load ]]
    --------------------------------------------------------------------------

    if _ismastersim then function self:OnSave()
        if next(katanas) == nil then
            return
        end

        local ents = {}
        local refs = {}

        for k, v in pairs(katanas) do
            table.insert(ents, { name = k, GUID = v.inst.GUID })
            table.insert(refs, v.inst.GUID)
        end

        return { katanas = ents }, refs
    end end

    if _ismastersim then function self:LoadPostPass(ents, data)
        if data.katanas ~= nil then
            for i, v in ipairs(data.katanas) do
                local ent = ents[v.GUID]
                if ent ~= nil then
                    self:TrackEntity(v.name, ent.entity)
                end
            end
        end
    end end

    --------------------------------------------------------------------------
    --[[ Debug ]]
    --------------------------------------------------------------------------

    function self:GetDebugString()
        local str = "\n"
        for k, v in pairs(katanas) do
            str = str.."    --"..k..": "..tostring(v.inst).."\n"
        end
        return str
    end

    --------------------------------------------------------------------------
    --[[ End ]]
    --------------------------------------------------------------------------

end)
