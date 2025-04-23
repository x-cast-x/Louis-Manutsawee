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

function EntityScript:SetComponent(name, condition)
    if condition then
        self:AddComponent(name)
    end
end

function EntityScript:HasAllComponents(...)
    for i = 1, select("#", ...) do
        local cmp = select(i, ...)
        if not self:HasComponent(cmp) then
            return false
        end
    end
    return true
end

function EntityScript:HasAnyComponent(...)
    for i = 1, select("#", ...) do
        local cmp = select(i, ...)
        if self:HasComponent(cmp) then
            return true
        end
    end
    return false
end

function EntityScript:HasComponents(...)
    local cmps = select(1, ...)
    if type(cmps) == "table" then
        return self:HasAllComponents(unpack(cmps))
    else
        return self:HasAllComponents(...)
    end
end

function EntityScript:HasOneOfComponents(...)
    local cmps = select(1, ...)
    if type(cmps) == "table" then
        return self:HasAnyComponent(unpack(cmps))
    else
        return self:HasAnyComponent(...)
    end
end
