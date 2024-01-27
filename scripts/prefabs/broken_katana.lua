local function OnHauntFn(inst, haunter)
    if math.random() <= launchchance then
        Launch(inst, haunter, TUNING.LAUNCH_SPEED_SMALL)
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_TINY

        if inst.components.inventoryitem ~= nil and inst.components.inventoryitem.is_landed then
            inst.components.inventoryitem:SetLanded(false, true)
        end
    end
    return false
end

local function MakeBroKenKatana(name)
    local assets = {
        Asset("ANIM", "anim/" .. name .. ".zip")
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("broken_katana")
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation("idle")

        inst:AddTag("broken_" .. name)

        MakeInventoryFloatable(inst)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inventoryitem")
        inst:AddComponent("inspectable")

        inst:AddComponent("hauntable")
        inst.components.hauntable.cooldown = TUNING.HAUNT_COOLDOWN_SMALL
        inst.components.hauntable:SetOnHauntFn(OnHauntFn)

        return inst
    end
    return Prefab("broken_" .. name, fn, assets)
end

local katana = {
    "tokishin",
    "raikiri",
    "shirasaya",
    "koshirae",
    "hitokiri",
    "tokishin",
}

local broken_katana = {}
for i = 1, #katana do
    table.insert(broken_katana, MakeBroKenKatana(katana[i]))
end

return unpack(broken_katana)
