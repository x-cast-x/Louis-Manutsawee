local LIGHT_INTENSITY_MAX = .94

local function CreateLight(bool_var)
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
    inst.Light:Enable(bool_var)

    return inst
end

local function GroundPoundFx(inst, scale)
    if inst ~= nil then
        local x, y, z = inst.Transform:GetWorldPosition()
        local fx = SpawnPrefab("groundpoundring_fx")
        fx.Transform:SetScale(scale, scale, scale)
        fx.Transform:SetPosition(x, y, z)
    end
end

local function SlashFx(inst, target, prefab, scale)
    if inst ~= nil and target ~= nil then
        local fx = SpawnPrefab(prefab)
        fx.Transform:SetScale(scale, scale, scale)
        fx.Transform:SetPosition(target:GetPosition():Get())
        inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
        inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe")
    end
end

local function FollowerFx(inst, prefab, scale)
    local fx = SpawnPrefab(prefab)
    fx.entity:AddFollower()
    fx.Follower:FollowSymbol(inst.GUID, "swap_body", 0, 0, 0)
    if scale ~= nil then
        fx.Transform:SetScale(scale, scale, scale)
    end
end

local function SpawnFxInTime(inst, time)
    inst:DoTaskInTime(time, fn)
end

return {
    FollowerFx = FollowerFx,
    SlashFx = SlashFx,
    GroundPoundFx = GroundPoundFx,
    CreateLight = CreateLight,
}
