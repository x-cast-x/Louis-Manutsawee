local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("pighouse", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    local _OnPlayerNear = inst.components.playerprox.onnear

    local OnPlayerNear = function(inst, player)
        if player ~= nil and not player:HasTag("naughtychild") then
            _OnPlayerNear(inst, player)
        end
    end

    inst.components.playerprox:SetOnPlayerNear(OnPlayerNear)
end)
