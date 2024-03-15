--------------------------------------------------------------------------
--[[ Dating Manager class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "Dating Manager should not exist on client")

--------------------------------------------------------------------------
--[[ Public Member Variables ]]
--------------------------------------------------------------------------

self.inst = inst

--------------------------------------------------------------------------
--[[ Private Member Variables ]]
--------------------------------------------------------------------------

local _world = inst
local _map = _world.Map

local _momo_defeated_count = 0

local _dating_relationship = false
local _momo_in_the_world = false

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local OnMomoSpawn = function(inst)
    _momo_in_the_world = true
end

local OnMomoDefeated = function(inst, honey)
    _momo_defeated_count = _momo_defeated_count + 1
end

local ConfirmDatingRelationship = function(inst, honey)
    _dating_relationship = true
end

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

function self:GetMomoDefeatedCount()
	return _momo_defeated_count
end

function self:GetIsDatingRelationship()
    return _dating_relationship
end

function self:GetMomoInTheWorld()
    return _momo_in_the_world
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

inst:ListenForEvent("ms_momo_spawn", OnMomoSpawn)
inst:ListenForEvent("ms_momo_defeated", OnMomoDefeated)
inst:ListenForEvent("ms_dating_relationship", ConfirmDatingRelationship)

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

function self:OnSave()
    local data = {}
    data._momo_defeated_count = _momo_defeated_count
    data._dating_relationship = _dating_relationship
    data._momo_in_the_world = _momo_in_the_world

    return data
end

function self:OnLoad(data)
    if data ~= nil then
        if data._momo_defeated_count then
            _momo_defeated_count = data._momo_defeated_count
        end

        if data._dating_relationship then
            _dating_relationship = data._dating_relationship
        end

        if data._momo_in_the_world then
            _momo_in_the_world = data._momo_in_the_world
        end
    end
end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

-- function self:GetDebugString()

-- end

end)
