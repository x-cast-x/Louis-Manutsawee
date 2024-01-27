local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local function GetStatus(inst, viewer)
    if not TheWorld.components.katanaspawner:GetTheWorldHasTomb() then
        return "HASKATANA"
    end
end

AddPrefabPostInit("fissure", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    if inst.components.inspectable ~= nil then
        inst.components.inspectable.getstatus = GetStatus
    end

    local katanaspawner = TheWorld.components.katanaspawner
    local _OnFissureMinedFinished = inst.components.workable.onfinish
    function inst.components.workable.onfinish(inst, worker)
        _OnFissureMinedFinished(inst, worker)
        local pt = inst:GetPosition()
        if katanaspawner ~= nil and not katanaspawner:GetHasKatana("mortalblade") then
            inst.components.lootdropper:SpawnLootPrefab("mortalblade", pt)
            katanaspawner:SetHasKatana("mortalblade", true)
        end
    end

    local _OnNightmarePhaseChanged = inst.OnNightmarePhaseChanged
    local _ShowPhaseState = M_Util.GetUpvalue(_OnNightmarePhaseChanged, "ShowPhaseState")
    local _states = M_Util.GetUpvalue(_ShowPhaseState, "states")
    local _controlled = _states.controlled
    function states.controlled(inst, instant, oldstate)
        _controlled(inst, instant, oldstate)
        if katanaspawner ~= nil and not not katanaspawner:GetHasKatana("mortalblade") and inst.AnimState:IsCurrentAnimation("idle_open_rift") then
            local fx = SpawnPrefab("dreadstone_spawn_fx")
            fx.entity:SetParent(inst.entity)
            inst.AnimState:SetBank("nightmare_crack_upper_tomb")
            inst.AnimState:SetBuild("nightmare_crack_upper_tomb")
            inst.AnimState:PushAnimation("idle_open_rift", true)
        end
    end
end)
