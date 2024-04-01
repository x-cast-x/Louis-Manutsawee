local DIG_TAGS = { "stump", "grave", "farm_debris" }

local function Unignore(inst, sometarget, ignorethese)
    ignorethese[sometarget] = nil
end
local function IgnoreThis(sometarget, ignorethese, leader, worker)
    if ignorethese[sometarget] ~= nil and ignorethese[sometarget].task ~= nil then
        ignorethese[sometarget].task:Cancel()
        ignorethese[sometarget].task = nil
    else
        ignorethese[sometarget] = {worker = worker,}
    end
    ignorethese[sometarget].task = leader:DoTaskInTime(5, Unignore, sometarget, ignorethese)
end

local function FilterAnyWorkableTargets(targets, ignorethese, leader, worker)
    for _, sometarget in ipairs(targets) do
        if ignorethese[sometarget] ~= nil and ignorethese[sometarget].worker ~= worker then
            -- Ignore me!
        elseif sometarget.components.burnable == nil or (not sometarget.components.burnable:IsBurning() and not sometarget.components.burnable:IsSmoldering()) then
            if sometarget:HasTag("DIG_workable") then
                for _, tag in ipairs(DIG_TAGS) do
                    if sometarget:HasTag(tag) then
                        if sometarget.components.workable:GetWorkLeft() == 1 then
                            IgnoreThis(sometarget, ignorethese, leader, worker)
                        end
                        return sometarget
                    end
                end
            else -- CHOP_workable and MINE_workable has no special cases to handle.
                if sometarget.components.workable:GetWorkLeft() == 1 then
                    IgnoreThis(sometarget, ignorethese, leader, worker)
                end
                return sometarget
            end
        end
    end
    return nil
end

local ANY_TOWORK_ACTIONS = {ACTIONS.CHOP, ACTIONS.MINE, ACTIONS.DIG}
local ANY_TOWORK_MUSTONE_TAGS = {"CHOP_workable", "MINE_workable", "DIG_workable"}
local function PickValidActionFrom(target)
    if target.components.workable == nil then
        return nil
    end

    local desiredact = target.components.workable:GetWorkAction()
    for _, act in ipairs(ANY_TOWORK_ACTIONS) do
        if desiredact == act then
            return act
        end
    end
    return nil
end

local function FindAnyEntityToWorkActionsOn(inst, ignorethese) -- This is similar to FindEntityToWorkAction, but to be very mod safe FindEntityToWorkAction has been deprecated.
	if inst.sg:HasStateTag("busy") then
		return nil
	end
    local leader = GetLeader(inst)
    if leader == nil then -- There is no purpose for a puppet without strings attached.
        return nil
    end

    local target = inst.sg.statemem.target
    local action = nil
    if target ~= nil and target:IsValid() and not (target:IsInLimbo() or target:HasTag("NOCLICK") or target:HasTag("event_trigger") or target:HasTag("waxedplant")) and
        target:IsOnValidGround() and target.components.workable ~= nil and target.components.workable:CanBeWorked() and
        not (target.components.burnable ~= nil and (target.components.burnable:IsBurning() or target.components.burnable:IsSmoldering())) and
        target.entity:IsVisible() then
        -- Check if action is the one desired still.
        action = PickValidActionFrom(target)

        if action ~= nil and ignorethese[target] == nil then
            if target.components.workable:GetWorkLeft() == 1 then
                IgnoreThis(target, ignorethese, leader, inst)
            end
            return BufferedAction(inst, target, action)
        end
    end
    -- 'target' is invalid at this point, find a new one.

    local spawn = GetSpawn(inst)
    if spawn == nil then
        return nil
    end

    local px, py, pz = inst.Transform:GetWorldPosition()
    local target = FilterAnyWorkableTargets(TheSim:FindEntities(px, py, pz, TUNING.SHADOWWAXWELL_WORKER_WORK_RADIUS_LOCAL, nil, TOWORK_CANT_TAGS, ANY_TOWORK_MUSTONE_TAGS), ignorethese, leader, inst)
    if target ~= nil then
        local maxdist = TUNING.SHADOWWAXWELL_WORKER_WORK_RADIUS + TUNING.SHADOWWAXWELL_WORKER_WORK_RADIUS_LOCAL
        local dx, dz = px - spawn.x, pz - spawn.z
        if dx * dx + dz * dz > maxdist * maxdist then
            target = nil
        end
    end
    if target == nil then
        target = FilterAnyWorkableTargets(TheSim:FindEntities(spawn.x, spawn.y, spawn.z, TUNING.SHADOWWAXWELL_WORKER_WORK_RADIUS, nil, TOWORK_CANT_TAGS, ANY_TOWORK_MUSTONE_TAGS), ignorethese, leader, inst)
    end
    action = target ~= nil and PickValidActionFrom(target) or nil
    return action ~= nil and BufferedAction(inst, target, action) or nil
end

return {
    FindAnyEntityToWorkActionsOn = FindAnyEntityToWorkActionsOn,
    FilterAnyWorkableTargets = FilterAnyWorkableTargets,
}
