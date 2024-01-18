local assets = {
    Asset("ANIM", "anim/mingot.zip"),

	Asset("ANIM", "anim/katanabody.zip"),
}

local function DownGrade(inst, worker, workleft, workdone)
    local num_loots = math.clamp(workdone / TUNING.MINGOT_WORK_REQUIRED, 1, TUNING.MINGOT_LOOT.WORK_MAX_SPAWNS)
    num_loots = math.min(num_loots, inst.components.stackable:StackSize())

	if inst.components.stackable:StackSize() > num_loots then
		if num_loots == TUNING.MINGOT_LOOT.WORK_MAX_SPAWNS then
			LaunchAt(inst, inst, worker, TUNING.SPOILED_FISH_LOOT.LAUNCH_SPEED, TUNING.SPOILED_FISH_LOOT.LAUNCH_HEIGHT, nil, TUNING.SPOILED_FISH_LOOT.LAUNCH_ANGLE)
		end
    end

    for i = 1, num_loots do
        inst.components.lootdropper:DropLoot()
    end

    local mingot = inst.components.stackable:Get(num_loots)

    mingot.Transform:SetPosition(inst:GetPosition():Get())
	local collapse_fx = SpawnPrefab("collapse_small")
    collapse_fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    mingot:Remove()
end

local function mingotfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("mingot")
    inst.AnimState:SetBuild("mingot")
    inst.AnimState:PlayAnimation("idle")

	inst:AddTag("molebait")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

	inst:AddComponent("bait")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem:SetSinks(true)

	inst:AddComponent("cookable")
    inst.components.cookable.product = "hmingot"

	inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetOnWorkCallback(DownGrade)
    inst.components.workable:SetWorkLeft(3)

	inst:AddComponent("lootdropper")

	MakeHauntableLaunchAndSmash(inst)

    return inst
end

local function upgrade(inst, chopper)
	local collapse_fx = SpawnPrefab("collapse_small")
    collapse_fx.Transform:SetPosition(inst.Transform:GetWorldPosition())

	local item = SpawnPrefab("katanabody")
	item.Transform:SetPosition(inst.Transform:GetWorldPosition())

	inst:Remove()
end

local function onhit(inst)
	local fx = SpawnPrefab("sparks")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.SoundEmitter:PlaySound("dontstarve/impacts/impact_mech_med_sharp")
end

local function OnDropped(inst)
    inst.Light:Enable(true)
end

local function OnPickup(inst)
    inst.Light:Enable(false)
end

local function hmingotfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
	inst.entity:AddLight()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("hmingot")
    inst.AnimState:SetBuild("mingot")
    inst.AnimState:PlayAnimation("idle")
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

	inst.Light:SetFalloff(0.7)
    inst.Light:SetIntensity(.5)
    inst.Light:SetRadius(0.5)
    inst.Light:SetColour(255/255, 135/255, 0/255)
    inst.Light:Enable(true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

   -- inst:AddComponent("stackable")
   -- inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem:SetSinks(true)
	inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
    inst.components.inventoryitem:SetOnPickupFn(OnPickup)

	inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_ONE_DAY)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "mingot"

	inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetOnFinishCallback(upgrade)
    inst.components.workable:SetWorkLeft(40)
	inst.components.workable:SetOnWorkCallback(onhit)

	MakeHauntableLaunchAndSmash(inst)

    return inst
end

local function katanabodyfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("katanabody")
    inst.AnimState:SetBuild("katanabody")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem:SetSinks(true)

	inst:AddComponent("cookable")
    inst.components.cookable.product = "hmingot"

	MakeHauntableLaunch(inst)

    return inst
end

local function Makeitem(name, fn, assets)
    return Prefab(name, fn, assets)
end

return Makeitem("mingot", mingotfn, assets),
        Makeitem("hmingot", hmingotfn, assets),
        Makeitem("katanabody", katanabodyfn, assets)
