--------------------------------------------------------------------------
--[[ Track Target Status class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

    assert(TheWorld.ismastersim, "Track Target Status should not exist on client")

    --------------------------------------------------------------------------
    --[[ Dependencies ]]
    --------------------------------------------------------------------------

    local SpawnUtil = require("utils/spawnutil")
    local CreateLight = SpawnUtil.CreateLight

    --------------------------------------------------------------------------
    --[[ Member variables ]]
    --------------------------------------------------------------------------

    -- Public
    self.inst = inst

    -- Private
    local _world = TheWorld
    local _datingmanager = _world.components.datingmanager
    local _isdatingrelationship = _datingmanager ~= nil and _datingmanager:GetIsDatingRelationship() or false

    --------------------------------------------------------------------------
    --[[ Private member functions ]]
    --------------------------------------------------------------------------

    local function OnIsDay(inst, active)
        local honey = inst:TheHoney()
        if active then
            if honey ~= nil and honey.momo_light ~= nil then
                honey.momo_light:Remove()
            end
        end
    end

    local function ToggleLunarHail(inst, active)
        local onimpact_canttags = TheWorld.components.lunarhailmanager.onimpact_canttags
        if active then
            table.insert(onimpact_canttags, "manutsawee")
        else
            RemoveByValue(onimpact_canttags, "manutsawee")
        end
    end

    local function ToggleAcidRain(inst, active)
        local honey = inst:TheHoney()
        if honey ~= nil then
            if active then
                honey:AddTag("acidrainimmune")
            else
                honey:RemoveTag("acidrainimmune")
            end
        end
    end

    --------------------------------------------------------------------------
    --[[ Private event handlers ]]
    --------------------------------------------------------------------------

    local function OnSanityDelta(inst, data)
        local honey = inst:TheHoney()
        local newpercent = data.newpercent

        if newpercent <= 0.1 then
            inst:PushEvent("")
        end
    end

    local function OnHungerDelta(inst, data)
        local honey = inst:TheHoney()
        local newpercent = data.newpercent

        if newpercent <= 0.1 then

        end
    end

    local function OnHealthDelta(inst, data)
        local honey = inst:TheHoney()
        local newpercent = data.newpercent

        if newpercent <= 0.1 then

        end
    end

    local function OnMoistureDelta(inst, data)
        local honey = inst:TheHoney()
        local newpercent = data.newpercent

        if newpercent >= 0.5 then

        end
    end

    local function OnTemperatureDelta(inst, data)
        local honey = inst:TheHoney()
        local newpercent = data.newpercent

        if newpercent <= 5 then

        end
    end

    local function OnHearGrue(inst)
        local honey = inst:TheHoney()
        if honey ~= nil then
            local fx_book_light_upgraded = SpawnPrefab("fx_book_light_upgraded")
            local x, y, z = honey.Transform:GetWorldPosition()
            fx_book_light_upgraded.Transform:SetScale(.9, 2.5, 1)
            fx_book_light_upgraded.Transform:SetPosition(x, y, z)

            -- before Charlie's attack, set the light to be released after 0.5 seconds
            honey:DoTaskInTime(0.5, function()
                if honey.momo_light == nil then
                    honey.momo_light = CreateLight(true)
                    honey.momo_light.Follower:FollowSymbol(honey.GUID)
                else
                    honey.momo_light.Light:Enable(true)
                end
            end)
        end
    end

    local function OnTeleported(inst)
        local honey = inst:TheHoney()
        if honey ~= nil then
            inst:PushEvent("useteleport")
        end
    end

    --------------------------------------------------------------------------
    --[[ Initialization ]]
    --------------------------------------------------------------------------

    -- Register events

    --------------------------------------------------------------------------
    --[[ Post initialization ]]
    --------------------------------------------------------------------------



    --------------------------------------------------------------------------
    --[[ Public member functions ]]
    --------------------------------------------------------------------------

    function self:StartTrack(honey)
        if honey ~= nil and _isdatingrelationship then
            honey:ListenForEvent("sanitydelta", OnSanityDelta, inst)
            honey:ListenForEvent("hungerdelta", OnHungerDelta, inst)
            honey:ListenForEvent("healthdelta", OnHealthDelta, inst)
            honey:ListenForEvent("moisturedelta", OnMoistureDelta, inst)
            honey:ListenForEvent("temperaturedelta", OnTemperatureDelta, inst)
            honey:ListenForEvent("heargrue", OnHearGrue, inst)
            honey:ListenForEvent("teleported", OnTeleported, inst)

            -- watch world state
            self:WatchWorldState("islunarhailing", ToggleLunarHail)
            self:WatchWorldState("isacidraining", ToggleAcidRain)
            self:WatchWorldState("isday", OnIsDay)
        end
    end

    function self:StopTrack(honey)
        if honey ~= nil then
            honey:RemoveEventCallback("sanitydelta", OnSanityDelta, inst)
            honey:RemoveEventCallback("hungerdelta", OnHungerDelta, inst)
            honey:RemoveEventCallback("healthdelta", OnHealthDelta, inst)
            honey:RemoveEventCallback("moisturedelta", OnMoistureDelta, inst)
            honey:RemoveEventCallback("temperaturedelta", OnTemperatureDelta, honey)
            honey:RemoveEventCallback("heargrue", OnHearGrue, inst)
            honey:RemoveEventCallback("teleported", OnTeleported, inst)

            self:StopWatchingWorldState("isday", OnIsDay)
            self:StopWatchingWorldState("islunarhailing", ToggleLunarHail)
            self:StopWatchingWorldState("isacidraining", ToggleAcidRain)
        end
    end

    function self:OnPostInit()
        if _isdatingrelationship then
            OnIsDay(self, TheWorld.state.isday)
            ToggleLunarHail(self, TheWorld.state.islunarhailing)
            ToggleAcidRain(self, TheWorld.state.isacidraining)
        end
    end

    --------------------------------------------------------------------------
    --[[ Save/Load ]]
    --------------------------------------------------------------------------



    --------------------------------------------------------------------------
    --[[ OnRemoveEntity ]]
    --------------------------------------------------------------------------

    self.OnRemoveEntity = self.StopTrack
    self.OnRemoveFromEntity = self.StopTrack

    --------------------------------------------------------------------------
    --[[ Debug ]]
    --------------------------------------------------------------------------


    --------------------------------------------------------------------------
    --[[ End ]]
    --------------------------------------------------------------------------

end)
