local AddComponentPostInit = AddComponentPostInit
GLOBAL.setfenv(1, GLOBAL)

AddComponentPostInit("playerlightningtarget", function(self, inst)
    local _OnStrike = self.onstrikefn
    function self.onstrikefn(inst)
        local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        local has_lightningcutter = weapon ~= nil and weapon:HasTag("lightningcutter")
        if has_lightningcutter then
            local electricchargedfx = SpawnPrefab("electricchargedfx")
            electricchargedfx.entity:AddFollower()
            electricchargedfx.Follower:FollowSymbol(inst.GUID)

            local thunderbird_fx_charge_loop = SpawnPrefab("thunderbird_fx_charge_loop")
            thunderbird_fx_charge_loop.entity:AddFollower()
            thunderbird_fx_charge_loop.Follower:FollowSymbol(inst.GUID)

            weapon:PushEvent("lightningstrike")
            inst:PushEvent("lightningdamageavoided", has_lightningcutter)
        else
            _OnStrike(inst)
        end
    end
end)
