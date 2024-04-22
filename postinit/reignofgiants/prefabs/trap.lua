local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local function TrySpawnMomo(inst, bait, summoner)
    inst:DoTaskInTime(3, function() TheWorld:PushEvent("ms_momo_spawn", {pt = inst:GetPosition(), honey = summoner}) end)
end

local function OnBaitedFn(inst, bait, summoner)
    local datingmanager = TheWorld.components.datingmanager
    local momo_in_the_world = datingmanager ~= nil and datingmanager:GetMomoInTheWorld() or false
    if bait ~= nil and bait.prefab == "m_pantsu" and summoner ~= nil and (not momo_in_the_world) then
        TrySpawnMomo(inst, bait, summoner)
    end
end

AddPrefabPostInit("trap", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst.components.trap:SetOnBaitedFn(OnBaitedFn)
end)
