local assets = {
	Asset("ANIM", "anim/momocube_build.zip"),
}

local function OnPutInInventory(inst, owner)
	if owner ~= nil and owner.components.inventory ~= nil and not owner:HasTag("naughtychild") then
        inst:DoTaskInTime(0.1, function()
            owner.components.inventory:DropItem(inst)
        end)
	end
end

local function fn()
	local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
	inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

	inst.MiniMapEntity:SetIcon("momocube.tex")

    inst.AnimState:SetBank("momocube")
    inst.AnimState:SetBuild("momocube_build")
    inst.AnimState:PlayAnimation("idle", true)

	MakeInventoryFloatable(inst, "small", 0.1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.keepondeath = true
	inst.components.inventoryitem.keepondrown = true
	inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)

    MakeHauntableLaunchAndSmash(inst)

    return inst
end

return Prefab("momocube", fn, assets)
