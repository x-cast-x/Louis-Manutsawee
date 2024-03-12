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
    inst.Light:SetIntensity(.94)
    inst.Light:SetRadius(TUNING.WINONA_SPOTLIGHT_RADIUS)
    inst.Light:SetColour(255 / 255, 248 / 255, 198 / 255)
    inst.Light:Enable(true)

    return inst
end

local TrackTargetStatus = Class(function(self, inst)
    self.inst = inst

    self.target = nil
end)

local function OnSanityDelta(inst, data)
    local target = inst:GetTarget()
    local newpercent = data.newpercent

    if newpercent <= 0.1 then

    end
end

local function OnHungerDelta(inst, data)
    local target = inst:GetTarget()
    local newpercent = data.newpercent

    if newpercent <= 0.1 then

    end
end

local function OnHealthDelta(inst, data)
    local target = inst:GetTarget()
    local newpercent = data.newpercent

    if newpercent <= 0.1 then

    end
end

local function OnMoistureDelta(inst, data)
    local target = inst:GetTarget()
    local newpercent = data.newpercent

    if newpercent >= 0.5 then

    end
end

local function OnTemperatureDelta(inst, data)
    local target = inst:GetTarget()
    local newpercent = data.newpercent

    if newpercent <= 5 then

    end
end

local function OnHearGrue(inst)
    local target = inst:GetTarget()
    if target ~= nil then
        local fx_book_light_upgraded = SpawnPrefab("fx_book_light_upgraded")
        local x, y, z = target.Transform:GetWorldPosition()
        fx_book_light_upgraded.Transform:SetScale(.9, 2.5, 1)
        fx_book_light_upgraded.Transform:SetPosition(x, y, z)

        -- before Charlie's attack, set the light to be released after 0.5 seconds
        target:DoTaskInTime(0.5, function()
            if target.momo_light == nil then
                target.momo_light = CreateLight()
                target.momo_light.Follower:FollowSymbol(target.GUID)
            else
                target.momo_light.Light:Enable(true)
            end
        end)
    end
end

local function OnTeleported(inst)
    local target = inst:GetTarget()
    if target ~= nil then
        inst:PushEvent("useteleport")
    end
end

local function OnIsDay(self, active)
    if active then
        if self.target.momo_light ~= nil then
            self.target.momo_light:Remove()
        end
    end
end

local function ToggleLunarHail(self, active)
    local onimpact_canttags = TheWorld.components.lunarhailmanager.onimpact_canttags
    if active then
        table.insert(onimpact_canttags, "manutsawee")
    elseif onimpact_canttags["manutsawee"] ~= nil then
        table.remove(onimpact_canttags, onimpact_canttags["manutsawee"])
    end
end

local function ToggleAcidRain(self, active)
    if active then
        self.inst:AddTag("acidrainimmune")
    else
        self.inst:RemoveTag("acidrainimmune")
    end
end

local AddEventListeners = function(target, inst)
    target:ListenForEvent("sanitydelta", OnSanityDelta, inst)
    target:ListenForEvent("hungerdelta", OnHungerDelta, inst)
    target:ListenForEvent("healthdelta", OnHealthDelta, inst)
    target:ListenForEvent("moisturedelta", OnMoistureDelta, inst)
    target:ListenForEvent("temperaturedelta", OnTemperatureDelta, inst)
    target:ListenForEvent("heargrue", OnHearGrue, inst)
    target:ListenForEvent("teleported", OnTeleported, inst)
end

local AddWorldStateWatchers = function(self, target)
    self:WatchWorldState("islunarhailing", ToggleLunarHail)
    self:WatchWorldState("isacidraining", ToggleAcidRain)
    self:WatchWorldState("isday", OnIsDay)
end

function TrackTargetStatus:StartTrack(target)
    if target ~= nil then
        self.target = target
        AddEventListeners(target, self.inst)
        AddWorldStateWatchers(self, target)
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

        self:StopWatchingWorldState("isday", OnIsDay)
        self:StopWatchingWorldState("islunarhailing", ToggleLunarHail)
        self:StopWatchingWorldState("isacidraining", ToggleAcidRain)
    end
end

TrackTargetStatus.OnRemoveEntity = TrackTargetStatus.StopTrack
TrackTargetStatus.OnRemoveFromEntity = TrackTargetStatus.StopTrack

function TrackTargetStatus:OnLoad()
    local target = self.inst:GetTarget()
    if target ~= nil then
        self.inst.components.tracktargetstatus:StartTrack(target)
    end
end

return TrackTargetStatus
