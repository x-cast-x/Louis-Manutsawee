if M_CONFIG.DEBUGMODE then

local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("manutsawee", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst.components.builder:GiveAllRecipes()
	inst:PushEvent("techlevelchange")

    local invincible = inst.components.health.invincible
    inst.components.health:SetInvincible(not invincible)

end)

end

