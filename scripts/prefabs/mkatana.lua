local assets = {
    Asset("ANIM", "anim/mkatana.zip"),
    Asset("ANIM", "anim/swap_mkatana.zip"),
    Asset("ANIM", "anim/swap_Smkatana.zip"),
    Asset("ANIM", "anim/sc_mkatana.zip"),
    Asset("ANIM", "anim/sc_mkatana2.zip"),
}

local function Firstmode(inst)
	local owner = inst.components.inventoryitem.owner
	owner.AnimState:OverrideSymbol("swap_object", "swap_Smkatana", "swap_Smkatana")
	inst.components.weapon:SetRange(1, 1.5)

    if not owner:HasTag("notshowscabbard")  then
        owner.AnimState:ClearOverrideSymbol("swap_body_tall")
    end

	if inst:HasTag("mkatana")then
        inst:RemoveTag("mkatana")
    end

	if not inst:HasTag("Iai") then
        inst:AddTag("Iai")
    end

    inst.wpstatus = true
end

local function Seccondmode(inst)
	local owner = inst.components.inventoryitem.owner
	owner.AnimState:OverrideSymbol("swap_object", "swap_mkatana", "swap_mkatana")

	if not owner:HasTag("notshowscabbard") and owner:HasTag("player") then
        owner.AnimState:OverrideSymbol("swap_body_tall", "sc_mkatana", "tail")
    end

	inst.components.weapon:SetRange(.8, 1.2)

	if inst:HasTag("mkatana") then
        inst:RemoveTag("mkatana")
    end

    if inst:HasTag("Iai") then
        inst:RemoveTag("Iai")
    end

    if owner:HasTag("kenjutsu") and not inst:HasTag("mkatana") then
        inst:AddTag("mkatana")
    end

    inst.wpstatus = false
end

local function onpocket(inst)
	local owner = inst.components.inventoryitem.owner
    if not owner:HasTag("notshowscabbard") and owner:HasTag("player") then
        owner.AnimState:OverrideSymbol("swap_body_tall", "sc_mkatana2", "tail")
    end
end

local function OnEquip(inst, owner)
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

	if owner:HasTag("kenjutsu") then --Owner
		inst.components.weapon:SetDamage(TUNING.YARI_DAMAGE+(owner.kenjutsulevel*2))
	end

	if inst.wpstatus then
        Firstmode(inst)
	else
        Seccondmode(inst)
    end
end

local function OnUnequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

	inst.components.weapon:SetDamage(TUNING.YARI_DAMAGE)
end

local function onSave(inst, data)
    data.wpstatus = inst.wpstatus
end

local function onLoad(inst, data)
    if data ~= nil then
        inst.wpstatus = data.wpstatus or false
    end
end

local function onattack(inst, owner, target)
	if owner.components.rider:IsRiding() then return end

	if not inst.wpstatus and inst:HasTag("Iai") then
        Firstmode(inst)
		if target.components.combat ~= nil then
            target.components.combat:GetAttacked(owner, inst.components.weapon.damage*.6)
        end
	end

	if math.random(1,4) == 1 then
		local num = math.random(1, 1.2)
        local x = num
		local y = num
		local z = num
		local slash	= {"shadowstrike_slash_fx","shadowstrike_slash2_fx"}

		slash = SpawnPrefab(slash[math.random(1,2)])
		slash.Transform:SetPosition(target:GetPosition():Get())
		slash.Transform:SetScale(x, y, z)
	end
end

local function CastFn(inst, target)
	if inst.wpstatus then
        Seccondmode(inst)
	else
        Firstmode(inst)
	end
end

local function Onfinish(inst)
	local owner = inst.components.inventoryitem:GetGrandOwner()

    if owner ~= nil and not owner:HasTag("notshowscabbard") then
        owner.AnimState:ClearOverrideSymbol("swap_body_tall")
    end

    inst:Remove()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("mkatana")
    inst.AnimState:SetBuild("mkatana")
    inst.AnimState:PlayAnimation("idle")

	inst:AddTag("sharp")
    inst:AddTag("veryquickcast")
    inst:AddTag("katanaskill")
    inst:AddTag("waterproofer")

	inst.spelltype = "SCIENCE"

	MakeInventoryFloatable(inst, nil, 0.1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(TUNING.YARI_DAMAGE)
	inst.components.weapon:SetOnAttack(onattack)

    inst:AddComponent("inspectable")

	inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(0)

	inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetMaxUses(TUNING.YARI_USES)
	inst.components.finiteuses:SetUses(TUNING.YARI_USES)
	inst.components.finiteuses:SetOnFinished(Onfinish)

    inst:AddComponent("inventoryitem")
    --inst.components.inventoryitem:SetSinks(true)
	inst.components.inventoryitem.canonlygoinpocket = true

	inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(CastFn)
	inst.components.spellcaster.canusefrominventory = true
	inst.components.spellcaster.veryquickcast = true
	--------------------------------------------------

	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
	inst.components.equippable:SetOnPocket(onpocket)

	 -- status
    inst.wpstatus = true
    inst.OnSave = onSave
    inst.OnLoad = onLoad

	MakeHauntableLaunch(inst)

    return inst
end

return Prefab("mkatana", fn, assets)
