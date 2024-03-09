local AddPrefabPostInit = AddPrefabPostInit
local UpvalueUtil = require("utils/upvalueutil")
GLOBAL.setfenv(1, GLOBAL)

local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end

local function GetSpawnPoint(pt)
    local radius_override = 5
	if TheWorld.has_ocean then
		local function OceanSpawnPoint(offset)
			local x = pt.x + offset.x
			local y = pt.y + offset.y
			local z = pt.z + offset.z
			return TheWorld.Map:IsAboveGroundAtPoint(x, y, z, true) and NoHoles(pt)
		end

		local offset = FindValidPositionByFan(math.random() * 2 * PI, radius_override, 12, OceanSpawnPoint)
		if offset ~= nil then
			offset.x = offset.x + pt.x
			offset.z = offset.z + pt.z
			return offset
		end
	else
		if not TheWorld.Map:IsAboveGroundAtPoint(pt:Get()) then
			pt = FindNearbyLand(pt, 1) or pt
		end
		local offset = FindWalkableOffset(pt, math.random() * 2 * PI, radius_override, 12, true, true, NoHoles)
		if offset ~= nil then
			offset.x = offset.x + pt.x
			offset.z = offset.z + pt.z
			return offset
		end
	end
end

local function DoSpawnMomo(inst, bait, summoner)
    local pt = inst:GetPosition()
    local spawn_pt = GetSpawnPoint(pt)

    if spawn_pt ~= nil then
        local momo = SpawnPrefab("momo")
        if momo ~= nil then
            momo.Transform:SetPosition(spawn_pt:Get())
            momo:FacePoint(pt)
            -- she has only one target
            momo.locksummoner = summoner
            momo.components.entitytracker:TrackEntity(summoner.prefab, summoner)
            momo.components.entitytracker:TrackEntity("m_pantsu", bait)
            momo:DoTaskInTime(1*FRAMES, momo.OnPostInit)
            inst:Remove()
        end
    end
end

local function TrySpawnMomo(inst, bait, summoner)
    inst:DoTaskInTime(3, function() DoSpawnMomo(inst, bait, summoner) end)
end

local function OnBaitedFn(inst, bait, summoner)
    if bait ~= nil and bait.prefab == "m_pantsu" then
        TrySpawnMomo(inst, bait, summoner)
    end
end

AddPrefabPostInit("trap", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst.components.trap:SetOnBaitedFn(OnBaitedFn)
end)
