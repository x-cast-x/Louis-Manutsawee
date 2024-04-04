local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local humanmeat = {
    "humanmeat",
    "humanmeat_cooked",
    "humanmeat_dried",
}

local function OnPutInInventory(inst, owner)
	if owner ~= nil then
        if owner.prefab == "manutsawee" and owner.components.inventory ~= nil then
            inst:DoTaskInTime(0.1, function()
                owner.components.inventory:DropItem(inst)
                owner.components.talker:Say(STRINGS.CHARACTERS.MANUTSAWEE.DESCRIBE[string.upper(humanmeat[math.random(1, #humanmeat)])])
            end)
        end
	end
end

for _, v in ipairs(humanmeat) do
    AddPrefabPostInit(v, function(inst)
        inst:AddTag("humanmeat")

        if not TheWorld.ismastersim then
            return
        end

        if inst.components.inventoryitem ~= nil then
            inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
        end
    end)
end
