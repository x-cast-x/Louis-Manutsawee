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

local function AbleToAcceptTest(inst, item, giver)
    if item ~= nil and giver ~= nil and giver:HasTag("momocubecaster") then
        local _item = item.prefab
        return (_item == "axe") or (_item == "pickaxe") or (_item == "goldenaxe") or (_item == "goldenpickaxe")
    end
end

local function OnAccept(inst, giver, item)
    if item ~= nil then
        local _item = item.prefab
        local is_tool = (_item == "axe") or (_item == "pickaxe")
        local is_gold = (_item == "goldenaxe") or (_item == "goldenpickaxe")
        if is_tool or is_gold then
            inst.transtoaxe = true
            if is_gold then
                inst.is_gold = true
            end
        end
    end
end

local function Transformation(inst, giver, target, pos)
    if giver ~= nil then
        local incarnation
        local inventory = giver.components.inventory

        if inst.transtoaxe then
            incarnation = SpawnPrefab("momoaxe")
            incarnation.Transform:SetPosition(inst.Transform:GetWorldPosition())
            if inst.is_gold then
                incarnation.components.finiteuses:SetUses(incarnation.components.finiteuses.current * 2)
            end

            if incarnation ~= nil and inventory ~= nil then
                inventory:GiveItem(incarnation)
            end

            inst:Remove()
        end
    end
end

local function OnSave(inst, data)
    if inst.is_gold then
        data.is_gold = inst.is_gold
    end
    if inst.changetoaxe then
        data.changetoaxe = inst.changetoaxe
    end
end

local function OnLoad(inst, data)
    if data ~= nil then
        if data.is_gold then
            inst.is_gold = inst.is_gold
        end
        if data.changetoaxe then
            inst.changetoaxe = inst.changetoaxe
        end
    end
end

local function fn()
	local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
	inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst:AddTag("momocube")
    inst:AddTag("momocube_mountedcast")
    inst:AddTag("trader")

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

    inst:AddComponent("momocube")
    inst.components.momocube.Transformation = Transformation

    inst:AddComponent("trader")
    inst.components.trader.onaccept = OnAccept
    inst.components.trader:SetAbleToAcceptTest(AbleToAcceptTest)

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.keepondeath = true
	inst.components.inventoryitem.keepondrown = true
	inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    MakeHauntableLaunchAndSmash(inst)

    return inst
end

return Prefab("momocube", fn, assets)
