local AddPrefabPostInit = AddPrefabPostInit
local UpvalueUtil = require("utils/upvalueutil")
GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("sacred_chest", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    local _onclosefn = inst.components.container.onclosefn
    local DoNetworkOffering = UpvalueUtil.GetUpvalue(_onclosefn, "DoNetworkOffering")
    local DoLocalOffering = UpvalueUtil.GetUpvalue(_onclosefn, "DoLocalOffering")
    local CheckOffering = UpvalueUtil.GetUpvalue(DoLocalOffering, "CheckOffering")
    local offering_recipe = UpvalueUtil.GetUpvalue(CheckOffering, "offering_recipe")
    offering_recipe["kage"] = {"katanablade", "livinglog", "nightmarefuel", "nightmarefuel", "nightmarefuel", "nightmarefuel",}
    local LockChest = UpvalueUtil.GetUpvalue(DoLocalOffering, "LockChest")
    local MIN_LOCK_TIME = UpvalueUtil.GetUpvalue(DoLocalOffering, "MIN_LOCK_TIME")
    local function _DoLocalOffering(inst, doer)
        if inst.components.container:IsFull() then
            local rewarditem = CheckOffering(inst.components.container.slots)
            if rewarditem then
                LockChest(inst)
                inst.components.container:DestroyContents()
                inst.components.container:GiveItem(SpawnPrefab(rewarditem))
                inst.components.timer:StartTimer("localoffering", MIN_LOCK_TIME)
                return true
            end
        end

        return false
    end
    function inst.components.container.onclosefn(inst, doer, ...)
        inst.AnimState:PlayAnimation("close")

        if not _DoLocalOffering(inst, doer) then
            DoNetworkOffering(inst, doer)
        end
    end

    -- offering_recipe["kage"].testfn = function(inst, doer)
    --     local kenjutsuka = doer ~= nil and doer.components.kenjutsuka
    --     return kenjutsuka ~= nil and kenjutsuka:IsMaxLevel() or nil
    -- end

    -- UpvalueUtil.SetUpvalue(inst.components.container.onclosefn, "DoLocalOffering", function(inst, doer, ...)
    --     if inst.components.container:IsFull() then
    --         local rewarditem = CheckOffering(inst.components.container.slots)
    --         local can_spawn_rewarditem = true
    --         if rewarditem ~= nil then
    --             -- if rewarditem == "kage" then
    --             --     can_spawn_rewarditem = kenjutsuka:IsMaxLevel()
    --             -- end
    --             -- if can_spawn_rewarditem then
    --                 LockChest(inst)
    --                 inst.components.container:DestroyContents()
    --                 inst.components.container:GiveItem(SpawnPrefab(rewarditem))
    --                 inst.components.timer:StartTimer("localoffering", MIN_LOCK_TIME)
    --                 -- end
    --             return true
    --         end
    --     end
    --     return false
    -- end)
end)
