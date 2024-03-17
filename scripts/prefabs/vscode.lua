local assets = {
    Asset("ANIM", "anim/vscode.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("vscode")
    inst.AnimState:SetBuild("vscode")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("nosteal")
    inst:AddTag("vscode")

    MakeInventoryFloatable(inst, "small", 0.1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    return inst
end

return Prefab("vscode", fn, assets)
