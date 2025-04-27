local AddComponentPostInit = AddComponentPostInit
GLOBAL.setfenv(1, GLOBAL)

AddComponentPostInit("playerlightningtarget", function(self, inst)
    local _OnStrike = self.onstrikefn
    function self.onstrikefn(inst)
        local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        local has_lightningcutter = weapon ~= nil and weapon:HasTag("lightningcutter")
        if has_lightningcutter then
            inst:FollwerFx("electricchargedfx")
            inst:FollwerFx("thunderbird_fx_charge_loop")

            weapon:PushEvent("lightningstrike")
            inst:PushEvent("lightningdamageavoided", has_lightningcutter)
        else
            _OnStrike(inst)
        end
    end
end)
