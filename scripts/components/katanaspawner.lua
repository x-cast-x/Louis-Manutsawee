--------------------------------------------------------------------------
--[[ katanaspawner class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

    assert(TheWorld.ismastersim, "Katana Spawner should not exist on client")

    self.inst = inst

    local katanas = {}

    function self:TrackKatana(name, katana)
        local function onremove()
            katanas[name] = nil
        end
        katanas[name] = { inst = inst, onremove = onremove }
        self.inst:ListenForEvent("onremove", onremove, inst)
        katanas[name] = katana
    end

    function self:ForgetKatana(name)
        if katanas[name] ~= nil then
            self.inst:RemoveEventCallback("onremove", katanas[name].onremove, katanas[name].inst)
            katanas[name] = nil
        end
    end

    function self:GetKatana(name)
        return katanas[name] ~= nil and katanas[name].inst or nil
    end

    function self:OnSave()
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
    end

    function self:LoadPostPass(ents, data)
        if data.katanas ~= nil then
            for i, v in ipairs(data.katanas) do
                local ent = ents[v.GUID]
                if ent ~= nil then
                    self:TrackEntity(v.name, ent.entity)
                end
            end
        end
    end

    function self:GetDebugString()
        local str = "\n"
        for k, v in pairs(katanas) do
            str = str.."    --"..k..": "..tostring(v.inst).."\n"
        end
        return str
    end

end)
