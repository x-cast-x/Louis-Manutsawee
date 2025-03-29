local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("rainhat", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    local _onequipfn = inst.components.equippable.onequipfn
    local _onunequipfn = inst.components.equippable.onunequipfn

    local function OnEquip(inst, owner, from_ground)
        if owner ~= nil and owner:HasTag("naughtychild") then
            inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_ABSOLUTE)
        end

        _onequipfn(inst, owner, from_ground)
    end

    local function OnUnequip(inst, owner, from_ground)
        if owner ~= nil and owner:HasTag("naughtychild") then
            inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_LARGE)
        end

        _onunequipfn(inst, owner, from_ground)
    end

    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
end)
