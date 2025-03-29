local RADIUS = 0.8
local SPAWN_PERIOD = 0
local MAX_COUNT = 20
local MAX_ICESPIKE_SFX = 10
local SFX_PERIOD = math.ceil(MAX_COUNT / (MAX_ICESPIKE_SFX / 2 - 1))
local SPACING = RADIUS * 2 + 0.05
local TUNNEL_RADIUS = 3
local MIN_DRIFT = 0.25
local DRIFT_VAR = 0.25
local OUTER_DRIFT_LIMIT = 1.5
local INNER_DRIFT_LIMIT = 0.5

local function EndTask(inst, taskname)
    if inst[taskname] then
        inst[taskname]:Cancel()
        inst[taskname] = nil
    end
    if not (inst.task_R or inst.task_L or inst.task_M) then
        inst:Remove()
    end
end

local spike_fx = {
    "electricchargedfx",
    "electrichitsparks",
    "thunderbird_fx_idle",
    "thunderbird_fx_shoot",
    "thunderbird_fx_charge_loop",
    "thunderbird_fx_charge_pre",
    "thunderbird_fx_charge_pst",
}

local spike_fx_scale = {
    3,
    2.5,
    2,
    1.5,
    1,
}

local function DoSpawnSpike(inst, data, targets, flip, offset)
    local rot = inst.Transform:GetRotation()
    local scale = spike_fx_scale[math.random(1, #spike_fx_scale)]
    local fx, final, shouldsfx
    if data.queued_x then
        fx = SpawnPrefab(spike_fx[math.random(1, #spike_fx)])
        fx.Transform:SetPosition(data.queued_x, 0, data.queued_z)
        fx.Transform:SetRotation(rot + (flip and -70 or 70))
        fx.Transform:SetScale(scale, scale, scale)
        fx.targets = targets

        if data.next_sfx > 0 then
            data.next_sfx = data.next_sfx - 1
        else
            data.next_sfx = SFX_PERIOD
            shouldsfx = true
        end

        data.count = data.count + 1
        if data.count < MAX_COUNT then
            if data.next_drift_change > 1 then
                data.next_drift_change = data.next_drift_change - 1
            else
                local max_drift_dist = flip and INNER_DRIFT_LIMIT or OUTER_DRIFT_LIMIT
                local min_drift_dist = flip and -OUTER_DRIFT_LIMIT or -INNER_DRIFT_LIMIT
                local mid_drift_dist = (min_drift_dist + max_drift_dist) / 2
                local drift_dir
                if flip and data.drift_dist > mid_drift_dist and data.drift < 0 then
                    drift_dir = -1 --favour outward a bit
                    data.next_drift_change = 1
                elseif not flip and data.drift_dist < mid_drift_dist and data.drift > 0 then
                    drift_dir = 1 --favour outward a bit
                    data.next_drift_change = 1
                else
                    drift_dir =
                        (data.drift_dist > max_drift_dist and -1) or
                        (data.drift_dist < min_drift_dist and 1) or
                        data.drift > 0 and -1 or 1
                    data.next_drift_change = math.random(2, 3)
                end
                data.drift = drift_dir * (MIN_DRIFT + math.random() * DRIFT_VAR)
            end
            data.drift_dist = data.drift_dist + data.drift
        else
            final = true
        end
    end

    if not final then
        local x, y, z = inst.Transform:GetWorldPosition()
        local theta = rot * DEGREES
        local dist = data.count * SPACING
        local perptheta = (rot + 90) * DEGREES
        local perpdist = (flip and -TUNNEL_RADIUS or TUNNEL_RADIUS) + data.drift_dist
        x = x + dist * math.cos(theta) + perpdist * math.cos(perptheta)
        z = z - dist * math.sin(theta) - perpdist * math.sin(perptheta)
        if TheWorld.Map:IsPassableAtPoint(x, 0, z) then
            data.queued_x = x
            data.queued_z = z
        else
            final = true
        end
    end

    if final then
        EndTask(inst, flip and "task_L" or "task_R")
    end
end

local function DoSpawnMiddleSpike(inst, data, targets)
    local rot = inst.Transform:GetRotation()
    local scale = spike_fx_scale[math.random(1, #spike_fx_scale)]
    local fx, final, shouldsfx

    if data.queued_x then
        fx = SpawnPrefab(spike_fx[math.random(1, #spike_fx)])
        fx.Transform:SetPosition(data.queued_x, 0, data.queued_z)
        fx.Transform:SetRotation(rot)
        fx.Transform:SetScale(scale, scale, scale)
        fx.targets = targets

        if data.next_sfx > 0 then
            data.next_sfx = data.next_sfx - 1
        else
            data.next_sfx = SFX_PERIOD
            shouldsfx = true
        end

        data.count = data.count + 1
        if data.count >= MAX_COUNT then
            final = true
        end
    end

    if not final then
        local x, y, z = inst.Transform:GetWorldPosition()
        local theta = rot * DEGREES
        local dist = data.count * SPACING
        local perptheta = (rot + 90) * DEGREES
        local perpdist = data.drift_dist
        x = x + dist * math.cos(theta) + perpdist * math.cos(perptheta)
        z = z - dist * math.sin(theta) - perpdist * math.sin(perptheta)
        if TheWorld.Map:IsPassableAtPoint(x, 0, z) then
            data.queued_x = x
            data.queued_z = z
        else
            final = true
        end
    end

    if final then
        EndTask(inst, "task_M")
    end
end

local function fn()
    local inst = CreateEntity()

    inst:AddTag("CLASSIFIED")
    inst.persists = false

    inst.entity:AddTransform()

    local targets = {}

    -- DoPeriodicTask有点耗资源，但只是一瞬间的
    inst.task_R = inst:DoPeriodicTask(SPAWN_PERIOD, DoSpawnSpike, 0, {
        count = 0,
        drift_dist = -0.9,
        drift = MIN_DRIFT + (0.7 + 0.3 * math.random()) * DRIFT_VAR,
        next_drift_change = math.random(2, 3),
        next_sfx = 0,
    }, targets)

    inst.task_L = inst:DoPeriodicTask(SPAWN_PERIOD, DoSpawnSpike, 0, {
        count = 0,
        drift_dist = 0.9,
        drift = -MIN_DRIFT - (0.7 + 0.3 * math.random()) * DRIFT_VAR,
        next_drift_change = math.random(2, 3),
        next_sfx = math.floor(SFX_PERIOD / 2),
    }, targets, true)

    inst.task_M = inst:DoPeriodicTask(SPAWN_PERIOD, DoSpawnMiddleSpike, 0, {
        count = 0,
        drift_dist = 0,  -- 中间的漂移距离为0
        drift = nil,
        next_drift_change = nil,
        next_sfx = 0,
    }, targets)

    return inst
end

return Prefab("lightningspike_fx", fn, nil, spike_fx)
