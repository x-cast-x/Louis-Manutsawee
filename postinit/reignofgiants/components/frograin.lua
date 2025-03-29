local FrogRain = require("components/frograin")
local AddComponentPostInit = AddComponentPostInit
local UpvalueUtil = require("utils/upvalueutil")
GLOBAL.setfenv(1, GLOBAL)


AddComponentPostInit("frograin", function(self, inst)

    -- local _datingmanager = inst.components.datingmanager
    -- local _isdatingrelationship = _datingmanager ~= nil and _datingmanager:GetIsDatingRelationship() or false

    -- local OnPlayerJoined = inst:GetEventCallbacks("ms_playerjoined", inst, "scripts/components/frograin.lua")
    -- local _ScheduleSpawn = UpvalueUtil.GetUpvalue(OnPlayerJoined, "ScheduleSpawn")
    -- local _SpawnFrogForPlayer = UpvalueUtil.GetUpvalue(_ScheduleSpawn, "SpawnFrogForPlayer")
    -- local _SpawnFrog = UpvalueUtil.GetUpvalue(_SpawnFrogForPlayer, "SpawnFrog")
end)
