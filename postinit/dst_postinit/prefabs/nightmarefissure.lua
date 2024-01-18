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
        if katanaspawner ~= nil and not katanaspawner:GetTheWorldHasTomb() then
            inst.components.lootdropper:SpawnLootPrefab("mortalblade", pt)
            katanaspawner:SetHasTomb(true)
        end
    end

    local _OnNightmarePhaseChanged = inst.OnNightmarePhaseChanged
    local ShowPhaseState = M_Util.GetUpvalue(_OnNightmarePhaseChanged, "ShowPhaseState")
    local states = M_Util.GetUpvalue(ShowPhaseState, "states")
    local controlled = states.controlled
    function states.controlled(inst, instant, oldstate)
        controlled(inst, instant, oldstate)
        if katanaspawner ~= nil and not katanaspawner:GetTheWorldHasTomb() and inst.AnimState:IsCurrentAnimation("idle_open_rift") then
            local fx = SpawnPrefab("dreadstone_spawn_fx")
            fx.entity:SetParent(inst.entity)
            inst.AnimState:SetBank("nightmare_crack_upper_tomb")
            inst.AnimState:SetBuild("nightmare_crack_upper_tomb")
            inst.AnimState:PushAnimation("idle_open_rift", true)
        end
    end
end)
