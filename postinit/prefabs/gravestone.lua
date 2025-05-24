local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("gravestone", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    local mound = inst.mound
    if mound ~= nil and mound ~= nil then
        local _onfinish = mound.components.workable.onfinish
        local function OnFinishCallback(inst, worker, ...)
            if inst.setepitaph == "Sydney" then
                inst.AnimState:PlayAnimation("dug")
                inst:RemoveComponent("workable")
                inst.components.lootdropper:SpawnLootPrefab("m_pantsu")

                if worker ~= nil then
                    if worker.components.sanity ~= nil then
                        worker.components.sanity:DoDelta(-TUNING.SANITY_SMALL)
                    end
                end
            else
                _onfinish(inst, worker, ...)
            end
        end
        mound.components.workable:SetOnFinishCallback(OnFinishCallback)
    end
end)
