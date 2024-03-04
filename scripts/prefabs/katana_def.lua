local SkillUtil = require("utils/skillutil")

local function SheathMode(inst, owner)
    inst.spelltype = "PULLOUT"

    owner = owner or inst.components.inventoryitem.owner or nil
	owner.AnimState:OverrideSymbol("swap_object", "swap_S" .. inst.build, "swap_S" .. inst.build)

	inst.AnimState:SetBank(inst.build)
    inst.AnimState:SetBuild(inst.build)

    if IA_ENABLED then
        if inst.components.tool ~= nil then
            inst:RemoveComponent("tool")
        end
    end

	inst.components.weapon:SetRange(1, 1.5)

	if not owner:HasTag("notshowscabbard")  then
        owner.AnimState:ClearOverrideSymbol("swap_body_tall")
    end

	inst.components.equippable.walkspeedmult = 1.25

	if inst:HasTag("mkatana") then
        inst:RemoveTag("mkatana")
    end

    if not inst:HasTag("iai") then
        inst:AddTag("iai")
    end

    inst.weaponstatus = false
end

local function UnsheathMode(inst, owner)
    inst.spelltype = "INSERT"

    owner = owner or inst.components.inventoryitem.owner or nil
	owner.AnimState:OverrideSymbol("swap_object", "swap_" .. inst.build, "swap_" .. inst.build)

	inst.AnimState:SetBank(inst.build .. "2")
    inst.AnimState:SetBuild(inst.build .. "2")

    if IA_ENABLED then
        if inst.components.tool == nil then
            inst:AddComponent("tool")
            inst.components.tool:SetAction(ACTIONS.HACK, 3)
        end
    end

	if not owner:HasTag("notshowscabbard") then
        owner.AnimState:OverrideSymbol("swap_body_tall", "sc_" .. inst.build, "tail")
    end

	inst.components.weapon:SetRange(.8, 1.2)

	inst.components.equippable.walkspeedmult = 1.15

	if inst:HasTag("mkatana")then
        inst:RemoveTag("mkatana")
    end

    if inst:HasTag("iai") then
        inst:RemoveTag("iai")
    end

	if owner:HasTag("kenjutsu") and not inst:HasTag("mkatana") then
        inst:AddTag("mkatana")
    end

    inst.weaponstatus = true
end

local function CastFn(inst, target, position, doer)
	if not inst.weaponstatus then
        inst.UnsheathMode(inst, doer)
    else
        inst.SheathMode(inst, doer)
    end

    if inst:HasTag("mortalblade") then
        inst.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")
    end

    if inst.first_time_unsheathed then
        local health = doer.components.health
        local inventory = doer.components.inventory
        local body = inventory:GetEquippedItem(EQUIPSLOTS.BODY)
        local head = inventory:GetEquippedItem(EQUIPSLOTS.HEAD)

        if head ~= nil then
            inventory:DropItem(head)
        end

        if body ~= nil then
            inventory:DropItem(body)
        end

        if health ~= nil then
            if health:IsInvincible() then
                health:SetInvincible(false)
            end
            health:Kill()
            inst.first_time_unsheathed = false
        end
    end
end

local function OnEquip(inst, owner)
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

	if owner:HasTag("kenjutsu") then
		inst.components.weapon:SetDamage(inst.components.weapon.damage + (owner.components.kenjutsuka:GetKenjutsuLevel() * 2))
	end

    if inst:HasTag("mortalblade") then
        inst.TryStartFx(inst, owner)
    end

	if not inst.weaponstatus then
        inst.SheathMode(inst, owner)
    else
        inst.UnsheathMode(inst, owner)
    end
end

local function OnUnequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    if inst:HasTag("mortalblade") then
        inst.StopFx(inst)
    end

	inst.components.weapon:SetDamage(TUNING.KATANA.DAMAGE)
end

local function OnPocket(inst, owner)
    if owner ~= nil and not owner:HasTag("notshowscabbard") and owner:HasTag("player") then
        owner.AnimState:OverrideSymbol("swap_body_tall", "sc_" .. inst.build .. "2", "tail")
    end
end

local has_broken = {
    "hitokiri",
    "shirasaya",
    "raikiri",
    "koshirae",
    -- "kurokatana",
    "tokijin"
}

local function OnFinished(inst)
    if inst:HasTag("mortalblade") then
        inst.StopFx(inst)
    end

    if has_broken[inst.prefab] then
        local katana_broken = SpawnPrefab(inst.build .. "_broken")
        local x,y,z = inst.Transform:GetWorldPosition()
        katana_broken.Transform:SetPosition(x,y,z)
    end

    local owner = inst.components.inventoryitem:GetGrandOwner()

    if owner ~= nil and not owner:HasTag("notshowscabbard") then
        owner.AnimState:ClearOverrideSymbol("swap_body_tall")
    end

    inst:Remove()
end

local function OnPutInInventory(inst, owner)
    local damage = 10
    local fx
	if owner ~= nil and owner.components.inventory ~= nil and owner:HasTag("player") and not owner:HasTag("bladesmith") then
        owner.components.talker:Say("it doesn't seem to like me very much...")
        local pos = inst:GetPosition():Get()
        inst:DoTaskInTime(0.1, function()
            if inst:HasTag("lightningcutter") then
                fx = SpawnPrefab("electrichitsparks")
                fx.Transform:SetPosition(pos)
            elseif inst:HasTag("shadow_item") then
                damage = 30
                fx = SpawnPrefab("wanda_attack_pocketwatch_old_fx")
                fx.Transform:SetPosition(pos)
            end
			if owner.components.combat ~= nil then
				owner.components.combat:GetAttacked(inst, damage)
			end
			owner.components.inventory:DropItem(inst)
		end)
    end
end

local function OnSave(inst, data)
    data.weaponstatus = inst.weaponstatus

    if inst.first_time_unsheathed ~= nil then
        data.first_time_unsheathed = inst.first_time_unsheathed
    end
end

local function OnLoad(inst, data)
    if data ~= nil then
        inst.weaponstatus = data.weaponstatus

        if inst.first_time_unsheathed ~= nil then
            inst.first_time_unsheathed = data.first_time_unsheathed
        end

        local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem:GetGrandOwner()
        if owner ~= nil and owner:HasTag("kenjutsu") then
            inst.components.weapon:SetDamage(inst.components.weapon.damage + (owner.components.kenjutsuka:GetKenjutsuLevel() * 2))
        end
    end
end

local function IsShadow(target)
    return target ~= nil and target:IsValid() and (target:HasTag("shadow") or target:HasTag("shadowminion") or target:HasTag("shadowchesspiece") or target:HasTag("stalker") or target:HasTag("stalkerminion"))
end

local function IsLunar(target)
    return target ~= nil and target:IsValid() and (target:HasTag("lunar_aligned"))
end

local MakeKatana = function(data)
    local name = data.name
    local build = data.build
    local assets = {
        Asset("ANIM", "anim/" .. build .. ".zip"),
        Asset("ANIM", "anim/" .. build .. "2.zip"),
        Asset("ANIM", "anim/swap_" .. build .. ".zip"),
        Asset("ANIM", "anim/swap_S" .. build .. ".zip"),
        Asset("ANIM", "anim/sc_" .. build .. ".zip"),
        Asset("ANIM", "anim/sc_" .. build .. "2.zip"),
    }
    local prefabs = {}

    local function OnAttack(inst, attacker, target)
        SkillUtil.OnAttackCommonFn(inst, attacker, target)
        if data.onattack ~= nil then
            data.onattack(inst, attacker, target)
        end
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
    	inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(build)
        inst.AnimState:SetBuild(build)
        inst.AnimState:PlayAnimation("idle")

        inst.spelltype = "PULLOUT"

        inst:AddTag("nosteal")
    	inst:AddTag("sharp")
        inst:AddTag("veryquickcast")
        inst:AddTag("katanaskill")
    	inst:AddTag("waterproofer")

        --weapon (from weapon component) added to pristine state for optimization
        inst:AddTag("weapon")

    	MakeInventoryFloatable(inst, nil, 0.1)

        if data.common_postinit ~= nil then
            data.common_postinit(inst)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(0)

        inst:AddComponent("weapon")
    	inst.components.weapon:SetDamage(data.damage)
    	inst.components.weapon:SetOnAttack(OnAttack)

        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.nobounce = true
        inst.components.inventoryitem.keepondeath = true
        inst.components.inventoryitem.keepondrown = true
        inst.components.inventoryitem.canonlygoinpocket = true
        inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)

    	inst:AddComponent("finiteuses")
    	inst.components.finiteuses:SetMaxUses(TUNING.KATANA.USES)
    	inst.components.finiteuses:SetUses(TUNING.KATANA.USES)
    	inst.components.finiteuses:SetOnFinished(OnFinished)

    	inst:AddComponent("spellcaster")
        inst.components.spellcaster:SetSpellFn(CastFn)
    	inst.components.spellcaster.canusefrominventory = true
    	inst.components.spellcaster.veryquickcast = true

    	inst:AddComponent("equippable")
    	inst.components.equippable:SetOnEquip(OnEquip)
        inst.components.equippable:SetOnUnequip(OnUnequip)
    	inst.components.equippable:SetOnPocket(OnPocket)

        inst.build = build
        inst.weaponstatus = false

        inst.IsLunar = IsLunar
        inst.IsShadow = IsShadow
        inst.SheathMode = SheathMode
        inst.UnsheathMode = UnsheathMode

        inst.OnSave = OnSave
        inst.OnLoad = OnLoad

    	MakeHauntableLaunch(inst)

        if data.master_postinit ~= nil then
            data.master_postinit(inst)
        end

        return inst
    end
    return Prefab(name, fn, assets, prefabs)
end

-- No one will use it, but I wrote it anyway
AddBrokenKatana = function(katana)
    if type(katana) == "string" then
        table.insert(has_broken, katana)
    end
end

return MakeKatana
