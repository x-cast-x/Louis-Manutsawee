local LouisManutsawee = "LouisManutsawee"



local common_postinit = function(inst)
    if M_CONFIG.IDLE_ANIMATION then
        inst.AnimState:AddOverrideBuild("player_idles_wes")
        inst.AnimState:AddOverrideBuild("player_idles_wendy")
        inst.AnimState:AddOverrideBuild("player_idles_wanda")
    end

    if IA_ENABLED then
        inst:AddTag("surfer")
    end

    if M_CONFIG.CANCRAFTTENT then
        inst:AddTag("pinetreepioneer")
    end

    if M_CONFIG.CANUSESLINGSHOT then
        inst:AddTag("slingshot_sharpshooter")
        inst:AddTag("pebblemaker")
    end

    if (not AD_ENABLED) and M_CONFIG.ENABLE_SKILL then
        inst.components.keyhandler:AddActionListener(LouisManutsawee, M_CONFIG.SKILL1_KEY, "Skill1")
        inst.components.keyhandler:AddActionListener(LouisManutsawee, M_CONFIG.SKILL2_KEY, "Skill2")
        inst.components.keyhandler:AddActionListener(LouisManutsawee, M_CONFIG.SKILL3_KEY, "Skill3")
        inst.components.keyhandler:AddActionListener(LouisManutsawee, M_CONFIG.SKILL4_KEY, "Skill4")
        inst.components.keyhandler:AddActionListener(LouisManutsawee, M_CONFIG.SKILL_COUNTER_ATK_KEY, "CounterAttack")
        inst.components.keyhandler:AddActionListener(LouisManutsawee, M_CONFIG.QUICK_SHEATH_KEY, "QuickSheath")
        inst.components.keyhandler:AddActionListener(LouisManutsawee, M_CONFIG.SKILL_CANCEL_KEY, "SkillCancel")
    end

    if M_CONFIG.ENABLE_DODGE then
        inst:AddComponent("dodger")
    end
end

local master_postinit = function(inst)
    local _OnStrike = inst.components.playerlightningtarget.onstrikefn
    local OnStrike = function(inst)
        local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if weapon ~= nil and weapon:HasTag("lightningcutter") then
            local electricchargedfx = SpawnPrefab("electricchargedfx")
            electricchargedfx.entity:AddFollower()
            electricchargedfx.Follower:FollowSymbol(inst.GUID)

            local thunderbird_fx_charge_loop = SpawnPrefab("thunderbird_fx_charge_loop")
            thunderbird_fx_charge_loop.entity:AddFollower()
            thunderbird_fx_charge_loop.Follower:FollowSymbol(inst.GUID)

            weapon:PushEvent("lightningstrike")
            inst:PushEvent("lightningdamageavoided", weapon:HasTag("lightningcutter"))
        else
            _OnStrike(inst)
        end
    end

    if IA_ENABLED then
        inst.components.foodaffinity:AddPrefabAffinity("californiaroll", TUNING.AFFINITY_15_CALORIES_TINY)
        inst.components.foodaffinity:AddPrefabAffinity("caviar", TUNING.AFFINITY_15_CALORIES_TINY)
    end

    if PL_ENABLED then
        inst.components.foodaffinity:AddPrefabAffinity("caviar", TUNING.AFFINITY_15_CALORIES_TINY)
    end

    if UM_ENABLED then
        inst.components.foodaffinity:AddPrefabAffinity("liceloaf", TUNING.AFFINITY_15_CALORIES_TINY)
        inst.components.foodaffinity:AddPrefabAffinity("blueberrypancakes", TUNING.AFFINITY_15_CALORIES_TINY)
    end
end

return {
    common_postinit = common_postinit,
    master_postinit = master_postinit,
}
