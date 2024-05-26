local AddPrefabPostInit = AddPrefabPostInit
local UpvalueUtil = require("utils/upvalueutil")
GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("sacred_chest", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    local container = inst.components.container
    if container ~= nil then
        local onclosefn = container.onclosefn
        local DoLocalOffering = UpvalueUtil.GetUpvalue(onclosefn, "DoLocalOffering")
        local CheckOffering = UpvalueUtil.GetUpvalue(DoLocalOffering, "CheckOffering")
        local offering_recipe = UpvalueUtil.GetUpvalue(CheckOffering, "offering_recipe")
        offering_recipe["kage_blueprint"] = {
            "katanablade",
            "livinglog",
            "nightmarefuel",
            "nightmarefuel",
            "nightmarefuel",
            "nightmarefuel",
        }
    end
end)
