--------------------------------------------------------------------------
--[[ Dating Manager class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

    assert(inst.ismastersim, "Dating Manager should not exist on client")

    --------------------------------------------------------------------------
    --[[ Public Member Variables ]]
    --------------------------------------------------------------------------

    self.inst = inst

    --------------------------------------------------------------------------
    --[[ Private Member Variables ]]
    --------------------------------------------------------------------------

    local _world = inst
    local _map = _world.Map
    local _worldsettingstimer = _world.components.worldsettingstimer

    local _is_pl_enabled = PL_ENABLED
    local _is_um_enabled = UM_ENABLED
    local _is_hof_enabled = HOF_ENABLED

    local void_stand_point = {0, 30, 0}
    local momo_npc = "momo_npc"
    local MOMO_TIMERNAME = "momo_givegift"

    local _momo_defeated_count = 0

    local _dating_relationship = false
    local _momo_in_the_world = false

    local MOMO_GIFTS = STRINGS.NAMES.MOMO_GIFTS
    local gifts = {
        [MOMO_GIFTS.AGIFTSTOENFROMKLEI] = {

        },
        [MOMO_GIFTS.MOMO_GIFT] = {

        },
        [MOMO_GIFTS.ATAKEOUT] = {

        },
        [MOMO_GIFTS.RESOURCES_COLLECTED_FROM_EVERYWHERE] = {

        },
        [MOMO_GIFTS.HEALTHY_VEGETABLES] = {

        },
        [MOMO_GIFTS.HEALTHY_FURIT] = {

        },
        [MOMO_GIFTS.AFTERNOON_TEA] = {

        },
        [MOMO_GIFTS.A_LITTLE_SNACK] = {

        },
        [MOMO_GIFTS.FEAST] = {

        },
        [MOMO_GIFTS.SEAFOOD] = {

        },
    }



    --------------------------------------------------------------------------
    --[[ Private member functions ]]
    --------------------------------------------------------------------------

    local GetSpawnGift = function(inst)
        local gift
        local loots = weighted_random_choice(gifts)

        local items = {}
        for k, v in pairs(loots) do
            local item = SpawnPrefab(k)
            if item ~= nil then
                if item.components.stackable ~= nil then
                    item.components.stackable:SetStackSize(math.max(1, v or 1))
                end
                table.insert(items, item)
            end
        end
        if #items > 0 then
            local gift = SpawnPrefab("gift")
            gift.components.unwrappable:WrapItems(items)
            for i, v in ipairs(items) do
                v:Remove()
            end
        end

        return gift ~= nil and gift
    end

    local function NoHoles(pt)
        return not _map:IsPointNearHole(pt)
    end

    local function GetSpawnPoint(pt)
        local radius_override = 8
        if not _map:IsAboveGroundAtPoint(pt:Get()) then
            pt = FindNearbyLand(pt, 1) or pt
        end
        local offset = FindWalkableOffset(pt, math.random() * 2 * PI, radius_override, 12, true, true, NoHoles)
        if offset ~= nil then
            offset.x = offset.x + pt.x
            offset.z = offset.z + pt.z
            return offset
        end
    end

    local OnMomoSpawn = function(inst, data)
        if data ~= nil then
            local pt = data.pt
            local honey = data.honey
            local spawn_pt = GetSpawnPoint(pt)

            if spawn_pt ~= nil then
                local momo = SpawnPrefab("momo")
                if momo ~= nil then
                    momo.Transform:SetPosition(spawn_pt:Get())
                    momo:FacePoint(pt)
                    momo.honey = honey
                    momo.honey_userid = honey.userid
                    momo.components.health:SetInvincible(false)
                    momo:PushEvent("start_dialogue")
                    _momo_in_the_world = true
                end
            end
        end
    end

    local OnMomoDefeated = function(inst, honey)
        _momo_defeated_count = _momo_defeated_count + 1
    end

    local ConfirmDatingRelationship = function(inst, honey)
        _dating_relationship = true
    end

    local ReturnIdlePointWait = function(inst, momo)
        momo:PushEvent("use_pocketwatch_portal", void_stand_point)
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

    function self:AddGift(name, loots)
        gifts[name] = loots
    end

    --------------------------------------------------------------------------
    --[[ Initialization ]]
    --------------------------------------------------------------------------

    -- Register events

    inst:ListenForEvent("ms_momo_spawn", OnMomoSpawn)
    inst:ListenForEvent("ms_momo_defeated", OnMomoDefeated)
    inst:ListenForEvent("ms_dating_relationship", ConfirmDatingRelationship)
    inst:ListenForEvent("ms_return_point", ReturnIdlePointWait)

    --------------------------------------------------------------------------
    --[[ Post initialization ]]
    --------------------------------------------------------------------------

    function self:OnPostInit()

    end

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
