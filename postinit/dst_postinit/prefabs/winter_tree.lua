local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local trees = {
    "winter_tree",
    "winter_twiggytree",
    "winter_deciduoustree",
    "winter_palmconetree"
}

local function fn(inst)
    if TheWorld.ismastersim then
        return
    end

    local queuegifting = M_Util.GetUpvalue(inst.OnEntityWake, "queuegifting")
    local trygifting = M_Util.GetUpvalue(queuegifting, "trygifting")
end

for _, v in pairs(trees) do
    AddPrefabPostInit(v, fn)
end
