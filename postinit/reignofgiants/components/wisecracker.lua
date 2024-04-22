local AddComponentPostInit = AddComponentPostInit
GLOBAL.setfenv(1, GLOBAL)

AddComponentPostInit("wisecracker", function(self, inst)
    local _fn = inst:GetEventCallbacks("lightningdamageavoided")
    inst:ListenForEvent("lightningdamageavoided", function(inst, hasraikiri)
        if hasraikiri then
            inst.components.talker:Say(GetString(inst, "ANNOUNCE_HASRAIKIRI"))
        else
            _fn(inst)
        end
    end)
end)
