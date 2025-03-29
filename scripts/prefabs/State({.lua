State({
    name = "ichimonji",
    tags = {"busy", "nopredict", "nointerrupt", "nomorph", "doing", "notalking", "skilling", "attack"}, -- Added "attack" tag during the relevant part

    -- Parameters:
    --   inst: The character instance
    --   target: The potential target passed from the trigger function (can be nil)
    onenter = function(inst, target)
        inst.inspskill = true -- Flag indicating a special skill is active
        inst.components.locomotor:Stop()

        local is_second_hit = inst.doubleichimonji == true -- Check if this is the automatic second hit

        -- 1. Handle Second Hit Logic First
        if is_second_hit then
            inst.doubleichimonji = nil -- Consume the flag
            inst.components.talker:Say(STRINGS.SKILL.SKILL1ATTACK, 2, true) -- Announce the second hit

            -- Target validation for second hit
            local valid_target = inst.sg.statemem.last_target -- Use the target from the first hit stored in statemem
            if not (valid_target and valid_target:IsValid() and not valid_target:HasTag("notarget")) then
                -- If the original target is gone, exit immediately
                inst.sg:GoToState("idle")
                return
            end
            inst.sg.statemem.target = valid_target -- Use the validated target
            inst:ForceFacePoint(valid_target.Transform:GetWorldPosition())

            -- Proceed directly to animations/attack for the second hit (no cost/cooldown checks)

        -- 2. Handle First Hit / Standalone Hit Logic
        else
            -- Check Cooldown (assuming skilltracker component)
            if inst.components.skilltracker and not inst.components.skilltracker:IsSkillReady(M_CONFIG.ICHIMONJI_TAG) then
                inst.sg:GoToState("idle")
                return -- Exit if on cooldown
            end

            -- Check Base Mindpower Cost
            if inst.components.kenjutsuka and inst.components.kenjutsuka:GetMindpower() < M_CONFIG.ICHIMONJI_COST then
                inst.sg:GoToState("idle")
                return -- Exit if not enough mindpower
            end

            -- Consume Base Mindpower
            if inst.components.kenjutsuka then
                inst.components.kenjutsuka:SetMindpower(inst.components.kenjutsuka:GetMindpower() - M_CONFIG.ICHIMONJI_COST)
            end

            -- Start Cooldown
            if inst.components.skilltracker then
                inst.components.skilltracker:StartSkillCooldown(M_CONFIG.ICHIMONJI_TAG)
            end

            -- Target Acquisition/Validation for First Hit
            local potential_target = target or inst.components.combat.target -- Use passed target or current combat target
            if potential_target and potential_target:IsValid() and inst:IsNear(potential_target, M_CONFIG.ICHIMONJI_RANGE + 2) and not potential_target:HasTag("notarget") then -- Added range check
                inst.sg.statemem.target = potential_target
                inst:ForceFacePoint(potential_target.Transform:GetWorldPosition())
            else
                -- Maybe find a new target nearby? Or just perform the skill facing forward?
                -- For now, let's store nil, the attack part needs to handle this.
                inst.sg.statemem.target = nil
                -- Or, maybe require a target?
                -- inst.sg:GoToState("idle")
                -- return
            end

            -- Check for Double Ichimonji Condition (Sheathed Weapon + Extra Mindpower)
            local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if weapon ~= nil and weapon.IsSheath ~= nil and weapon:IsSheath() and
               inst.components.kenjutsuka and inst.components.kenjutsuka:GetMindpower() >= M_CONFIG.ICHIMONJI_DOUBLE_EXTRA_COST then -- Check *remaining* mindpower for the *extra* cost

                -- Consume *Additional* Mindpower for Double
                inst.components.kenjutsuka:SetMindpower(inst.components.kenjutsuka:GetMindpower() - M_CONFIG.ICHIMONJI_DOUBLE_EXTRA_COST)
                inst.doubleichimonjistart = true -- Set flag to be checked on exit
                -- Note: The original 0.3s delay is omitted here for simplicity, assuming atk_prop_pre handles startup.
                -- If needed, a DoTaskInTime could be added here before playing animations.
            end
        end

        -- 3. Common Setup for Both First and Second Hits
        inst.AnimState:PlayAnimation("atk_prop_pre")
        inst.AnimState:PushAnimation("atk_prop_lag", false)
        inst.AnimState:PushAnimation("atk", false)
        inst.components.combat:EnableAreaDamage(true)
        inst.components.combat:SetAreaDamage(M_CONFIG.ICHIMONJI_AOE_RADIUS, M_CONFIG.ICHIMONJI_AOE_FALLOFF)
        inst.AnimState:SetDeltaTimeMultiplier(2.5)
        inst.components.combat:SetRange(M_CONFIG.ICHIMONJI_RANGE) -- Set range for the attack itself

    end,

    timeline = {
        TimeEvent(8 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe")
            SkillUtil.AddFollowerFx(inst, "electrichitsparks")
            SkillUtil.GroundPoundFx(inst, 0.5)
        end),

        TimeEvent(9 * FRAMES, function(inst)
            inst.AnimState:SetDeltaTimeMultiplier(1) -- Reset speed multiplier earlier?
            inst.Physics:SetMotorVelOverride(32, 0, 0)
            -- Face target again right before dash, if valid
            local target = inst.sg.statemem.target
            if target and target:IsValid() then
                inst:FacePoint(target.Transform:GetWorldPosition())
            end
        end),

        TimeEvent(10 * FRAMES, function(inst)
            inst.Physics:ClearMotorVelOverride()
            local x, y, z = inst.Transform:GetWorldPosition()
            local pufffx = SpawnPrefab("dirt_puff")
            if pufffx then
                pufffx.Transform:SetScale(.6, .6, .6)
                pufffx.Transform:SetPosition(x, y, z)
            end
        end),

        TimeEvent(17 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")
            inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")

            local target = inst.sg.statemem.target
            if target and target:IsValid() and not target:HasTag("notarget") then
                 inst:FacePoint(target.Transform:GetWorldPosition()) -- Ensure facing before attack
                -- Perform multiple attacks on the primary target
                for _ = 1, M_CONFIG.ICHIMONJI_ATTACK_MULTIPLIER do
                    inst.components.combat:DoAttack(target)
                end
                -- Store target for potential second hit
                inst.sg.statemem.last_target = target
            else
                 -- If no valid target, maybe perform a generic attack forward?
                 -- Or do nothing? Current DoAttack handles nil target gracefully (usually).
                 -- inst.components.combat:DoAttack() -- Attack in front if no target? Depends on desired behavior.
                 inst.sg.statemem.last_target = nil
            end

            -- Reset combat component settings after the attack action
            inst.components.combat:SetRange(TUNING.DEFAULT_ATTACK_RANGE)
            inst.components.combat:SetAreaDamage(1, 1) -- Reset AOE settings
            inst.components.combat:EnableAreaDamage(false) -- Disable AOE unless default is true

             inst:PerformBufferedAction() -- Allows queuing actions after the skill
        end),
    },

    -- ontimeout = function(inst)
        -- If timeline is precise, timeout might not be needed.
        -- Use animqueueover instead.
        -- inst.sg:GoToState("idle")
    -- end,

    events = {
        EventHandler("animqueueover", function(inst)
            if inst.AnimState:AnimDone() then
                -- GoToState is handled in onexit now for the double hit logic
                -- If not triggering a second hit, go to idle.
                if not inst.doubleichimonji then
                    inst.sg:GoToState("idle")
                end
            end
        end),
    },

    onexit = function(inst)
        -- Standard Cleanup
        if inst.components.combat ~= nil then
            inst.components.combat:SetTarget(nil) -- Clear explicit target setting
            inst.components.combat:SetRange(TUNING.DEFAULT_ATTACK_RANGE)
            inst.components.combat:EnableAreaDamage(false) -- Ensure AOE is off
            -- Note: Area Damage parameters (radius/falloff) reset within the timeline event
        end
        inst.AnimState:SetDeltaTimeMultiplier(1) -- Ensure multiplier is reset
        inst.Physics:ClearMotorVelOverride() -- Ensure physics override is cleared
        inst.inspskill = nil -- Clear the skill flag

        -- Double Ichimonji Trigger Logic
        local trigger_second_hit = false
        if inst.doubleichimonjistart then
            inst.doubleichimonjistart = nil -- Consume the start flag
            inst.doubleichimonji = true      -- Set the flag indicating the next one *is* the second hit
            trigger_second_hit = true
        end

        -- If we just finished the first hit AND the conditions were met, trigger the second immediately.
        if trigger_second_hit then
            local target = inst.sg.statemem.last_target -- Get target from the hit just performed
            if target and target:IsValid() then
                 -- Go back into the same state, it will detect inst.doubleichimonji == true
                inst.sg:GoToState("ichimonji", target)
            else
                 -- Target died or became invalid between hits, abort the second hit.
                inst.doubleichimonji = nil -- Clear the flag as we are not doing the second hit
                inst.sg:GoToState("idle") -- Go idle instead
            end
        end

         -- Clear statemem target if not chaining
        if not trigger_second_hit then
            inst.sg.statemem.target = nil
            inst.sg.statemem.last_target = nil
        end
    end,
})

