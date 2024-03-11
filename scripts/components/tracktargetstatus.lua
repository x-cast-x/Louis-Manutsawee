local function CreateLight()
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddFollower()

    inst.Light:SetFalloff(.9)
    inst.Light:SetIntensity(LIGHT_INTENSITY_MAX)
    inst.Light:SetRadius(TUNING.WINONA_SPOTLIGHT_RADIUS)
    inst.Light:SetColour(255 / 255, 248 / 255, 198 / 255)
    inst.Light:Enable(true)

    return inst
end

local TrackTargetStatus = Class(function(self, inst)
    self.inst = inst

    self.target = nil
end)

local function OnSanityDelta(target, data)
    local newpercent = data.newpercent

end

local function OnHungerDelta(target, data)
    local newpercent = data.newpercent

end

local function OnHealthDelta(target, data)
    local newpercent = data.newpercent

end

local function OnMoistureDelta(target, data)
    local newpercent = data.newpercent

end

local function OnTemperatureDelta(target, data)
    local newpercent = data.newpercent

end

local function OnHearGrue(target)
    if target ~= nil then
        local fx_book_light_upgraded = SpawnPrefab("fx_book_light_upgraded")
        local x, y, z = target.Transform:GetWorldPosition()
        fx_book_light_upgraded.Transform:SetScale(.9, 2.5, 1)
        fx_book_light_upgraded.Transform:SetPosition(x, y, z)

        target:DoTaskInTime(0.5, function()
            if target.light == nil then
                target.light = CreateLight()
                target.light.Follower:FollowSymbol(target.GUID)
            else
                target.light.Light:Enable(true)
            end
        end)
    end
end

local function OnIsDay(target, isday)
    if isday then
        if target.light ~= nil then
            target.light:Remove()
        end
    end
end

local function OnTeleported(target)

end

function TrackTargetStatus:StartTrack(target)
    if target ~= nil then
        self.target = target
        self.inst:ListenForEvent("sanitydelta", OnSanityDelta, target)
        self.inst:ListenForEvent("hungerdelta", OnHungerDelta, target)
        self.inst:ListenForEvent("healthdelta", OnHealthDelta, target)
        self.inst:ListenForEvent("moisturedelta", OnMoistureDelta, target)
        self.inst:ListenForEvent("temperaturedelta", OnTemperatureDelta, target)
        self.inst:ListenForEvent("heargrue", OnHearGrue, target)
        self.inst:ListenForEvent("teleported", OnTeleported, target)

        target:WatchWorldState("isday", OnIsDay)
    end
end

-- function TrackTargetStatus:OnUpdate(dt)

-- end

function TrackTargetStatus:StopTrack(target)
    if target ~= nil then
        self.target = nil
        self.inst:RemoveEventCallback("sanitydelta", OnSanityDelta, target)
        self.inst:RemoveEventCallback("hungerdelta", OnHungerDelta, target)
        self.inst:RemoveEventCallback("healthdelta", OnHealthDelta, target)
        self.inst:RemoveEventCallback("moisturedelta", OnMoistureDelta, target)
        self.inst:RemoveEventCallback("temperaturedelta", OnTemperatureDelta, target)
        self.inst:RemoveEventCallback("heargrue", OnHearGrue, target)
        self.inst:RemoveEventCallback("teleported", OnTeleported, target)

        target:StopWatchingWorldState("isday", OnIsDay)
    end
end

TrackTargetStatus.OnRemoveEntity = TrackTargetStatus.StopTrack
TrackTargetStatus.OnRemoveFromEntity = TrackTargetStatus.StopTrack

return TrackTargetStatus
