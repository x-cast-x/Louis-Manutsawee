GLOBAL.setfenv(1, GLOBAL)

if not rawget(EntityScript, "GetEventCallbacks") then
    function EntityScript:GetEventCallbacks(event, source, source_file)
        source = source or self

        assert(self.event_listening[event] and self.event_listening[event][source])

        for _, fn in ipairs(self.event_listening[event][source]) do
            if source_file then
                local info = debug.getinfo(fn, "S")
                if info and info.source == source_file then
                    return fn
                end
            else
                return fn
            end
        end
    end
end

EntityScript.SetTag = EntityScript.AddOrRemoveTag

function EntityScript:SetComponent()
end
