local AddComponentPostInit = AddComponentPostInit
GLOBAL.setfenv(1, GLOBAL)

AddComponentPostInit("wisecracker", function(self, inst)
    local _fn = inst:GetEventCallbacks("lightningdamageavoided")
    local fn = function(inst, hasraikiri)
        if hasraikiri then
            inst.components.talker:Say(GetString(inst, "ANNOUNCE_HASRAIKIRI"))
        else
            _fn(inst)
        end
    end

    inst:ListenForEvent("lightningdamageavoided", fn)
end)
