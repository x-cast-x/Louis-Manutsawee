require("stategraphs/commonstates")
local SkillUtil = require("utils/skillutil")

local function ToggleOffPhysics(inst)
    inst.sg.statemem.isphysicstoggle = true
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
end

local function ToggleOnPhysics(inst)
    inst.sg.statemem.isphysicstoggle = nil
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.GIANTS)
end

local function DoWortoxPortalTint(inst, val)
    if val > 0 then
        inst.components.colouradder:PushColour("portaltint", 154 / 255 * val, 23 / 255 * val, 19 / 255 * val, 0)
        val = 1 - val
        inst.AnimState:SetMultColour(val, val, val, 1)
    else
        inst.components.colouradder:PopColour("portaltint")
        inst.AnimState:SetMultColour(1, 1, 1, 1)
    end
end

local function DoTalkSound(inst)
    if inst.talksoundoverride ~= nil then
        inst.SoundEmitter:PlaySound(inst.talksoundoverride, "talk")
        return true
    elseif not inst:HasTag("mime") then
        inst.SoundEmitter:PlaySound((inst.talker_path_override or "dontstarve/characters/")..(inst.soundsname or inst.prefab).."/talk_LP", "talk")
        return true
    end
end

local function StopTalkSound(inst, instant)
    if inst.SoundEmitter:PlayingSound("talk") then
        if not instant and inst.endtalksound then
            inst.SoundEmitter:PlaySound(inst.endtalksound)
        end
        inst.SoundEmitter:KillSound("talk")
    end
end

local function DoMountSound(inst, mount, sound, ispredicted)
    if mount ~= nil and mount.sounds ~= nil then
        inst.SoundEmitter:PlaySound(mount.sounds[sound], nil, nil, ispredicted)
    end
end

local function SkillCollision(inst, enable)
    inst.Physics:ClearCollisionMask()
    if enable then
        inst.Physics:CollidesWith(COLLISION.WORLD)
        inst.Physics:CollidesWith(COLLISION.GROUND)
        if IA_ENABLED then
            inst.Physics:CollidesWith(COLLISION.WAVES)
        end
    else
        inst.Physics:CollidesWith(COLLISION.WORLD)
        inst.Physics:CollidesWith(COLLISION.OBSTACLES)
        inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
        inst.Physics:CollidesWith(COLLISION.CHARACTERS)
        inst.Physics:CollidesWith(COLLISION.GIANTS)
        if IA_ENABLED then
            inst.Physics:CollidesWith(COLLISION.WAVES)
        end
    end
end

local actionhandlers = {
    -- ActionHandler(ACTIONS.GIVE, "give"),
    -- ActionHandler(ACTIONS.CAST_POCKETWATCH, function(inst, action)
    --     local invobject = action.invobject
    --     return invobject ~= nil
    --         and (   invobject:HasTag("recall_unmarked") and "dolongaction"
    --                 or invobject:HasTag("pocketwatch_warp_casting") and "pocketwatch_warpback_pre"
    --                 or invobject.prefab == "pocketwatch_portal" and "pocketwatch_openportal"
    --             )
    --         or "pocketwatch_cast"
    -- end),
    -- ActionHandler(ACTIONS.BLINK, function(inst, action)
    --     return action.invobject == nil and inst:HasTag("soulstealer") and "portal_jumpin_pre" or "quicktele"
    -- end),
}

local events = {
    -- EventHandler("admitdefeated", function(inst, data)
    -- end),
    -- EventHandler("taunt", function(inst, data)
    -- end),
    -- EventHandler("locomote", function(inst)
    --     if not inst.sg:HasStateTag("busy") then
    --         local is_moving = inst.sg:HasStateTag("moving")
    --         local wants_to_move = inst.components.locomotor:WantsToMoveForward()
    --         if not inst.sg:HasStateTag("attack") and is_moving ~= wants_to_move then
    --             if wants_to_move then
    --                 inst.sg:GoToState("run_start")
    --             else
    --                 inst.sg:GoToState("idle")
    --             end
    --         end
    --     end
    -- end),
    -- EventHandler("ontalk", function(inst, data)
    --     if inst.sg:HasStateTag("idle") and not inst.sg:HasStateTag("notalking") then
    --         inst.sg:GoToState("talk", data.noanim)
	-- 	end
    -- end),
    -- EventHandler("useteleport", function(inst, data)
    --     inst.sg:GoToState("pocketwatch_openportal", data)
    -- end),
}

local states = {
    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst, pushanim)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end

            local anims = {}
            local dofunny = true

            table.insert(anims, "idle_loop")

            if pushanim then
                for k, v in pairs(anims) do
                    inst.AnimState:PushAnimation(v, k == #anims)
                end
            else
                inst.AnimState:PlayAnimation(anims[1], #anims == 1)
                for k, v in pairs(anims) do
                    if k > 1 then
                        inst.AnimState:PushAnimation(v, k == #anims)
                    end
                end
            end

            if dofunny then
                inst.sg:SetTimeout(math.random() * 4 + 2)
            end
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("funnyidle")
        end,
    },

    State{
        name = "funnyidle",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            local anim = inst.customidleanim ~= nil and (type(inst.customidleanim) == "string" and inst.customidleanim or inst:customidleanim()) or nil
            local state = anim == nil and (inst.customidlestate ~= nil and (type(inst.customidlestate) == "string" and inst.customidlestate or inst:customidlestate())) or nil
            if anim ~= nil or state ~= nil then
                if inst.sg.mem.idlerepeats == nil then
                    inst.sg.mem.usecustomidle = math.random() < .5
                    inst.sg.mem.idlerepeats = 0
                end
                if inst.sg.mem.idlerepeats > 1 then
                    inst.sg.mem.idlerepeats = inst.sg.mem.idlerepeats - 1
                else
                    inst.sg.mem.usecustomidle = not inst.sg.mem.usecustomidle
                    inst.sg.mem.idlerepeats = inst.sg.mem.usecustomidle and 1 or math.ceil(math.random(2, 5) * .5)
                end
                if inst.sg.mem.usecustomidle then
                    if anim ~= nil then
                        inst.AnimState:PlayAnimation(anim)
                    else
                        inst.sg:GoToState(state)
                    end
                else
                    inst.AnimState:PlayAnimation("idle_inaction")
                end
            else
                inst.AnimState:PlayAnimation("idle_inaction")
            end
        end,

        events = {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "talk",
        tags = { "idle", "talking" },

        onenter = function(inst, noanim)
            if not noanim then
                inst.AnimState:PlayAnimation(
					(inst.components.inventory:IsHeavyLifting() and not inst.components.rider:IsRiding() and "heavy_dial_loop") or
					(inst:IsChannelCasting() and (
						inst:IsChannelCastingItem() and "channelcast_idle_dial_loop" or "channelcast_oh_idle_dial_loop"
					)) or
                    "dial_loop",
                    true)
            end
            DoTalkSound(inst)
            inst.sg:SetTimeout(1.5 + math.random() * .5)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle")
        end,

        events =
        {
            EventHandler("donetalking", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        onexit = StopTalkSound,
    },

    State{
        name = "give",
        tags = { "giving" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("give")
            inst.AnimState:PushAnimation("give_pst", false)
        end,

        timeline =
        {
            TimeEvent(13 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "defeated",
        tags = {"idle", "defeated"},
        onenter = function(inst)

        end
    },

    State{
        name = "pocketwatch_openportal",
        tags = { "doing", "busy", "canrotate" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("useitem_pre")
            inst.AnimState:PushAnimation("pocketwatch_portal", false)
			inst.AnimState:PushAnimation("useitem_pst", false)

            inst.components.locomotor:Stop()

            local watch = inst.bufferedaction ~= nil and inst.bufferedaction.invobject
			if watch ~= nil then
		        inst.AnimState:OverrideSymbol("watchprop", watch.AnimState:GetBuild(), "watchprop")
	            inst.sg.statemem.castsound = watch.castsound
				inst.sg.statemem.same_shard = watch.components.recallmark ~= nil and watch.components.recallmark:IsMarkedForSameShard()
			end
        end,

        timeline =
        {
            TimeEvent(18 * FRAMES, function(inst)
				if not inst:PerformBufferedAction() then
					inst.sg.statemem.action_failed = true
					inst.AnimState:Hide("gemshard")
	                inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")
				else
	                inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
                end
            end),
			TimeEvent(32 * FRAMES, function(inst)
				if inst.sg.statemem.action_failed then
					inst.AnimState:Show("gemshard")
				end
			end),
			TimeEvent(37 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
			inst.AnimState:ClearOverrideSymbol("watchprop")
			if inst.sg.statemem.action_failed then
				inst.AnimState:Show("gemshard")
			end
        end,
    },

    State{
        name = "portal_jumpin_pre",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("wortox_portal_jumpin_pre")

            local buffaction = inst:GetBufferedAction()
            if buffaction ~= nil and buffaction.pos ~= nil then
                inst:ForceFacePoint(buffaction:GetActionPoint():Get())
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() and not inst:PerformBufferedAction() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "portal_jumpin",
        tags = { "busy", "pausepredict", "nodangle", "nomorph" },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("wortox_portal_jumpin")
            local x, y, z = inst.Transform:GetWorldPosition()
            SpawnPrefab("wortox_portal_jumpin_fx").Transform:SetPosition(x, y, z)
            inst.sg:SetTimeout(11 * FRAMES)
            inst.sg.statemem.from_map = data and data.from_map or nil
            local dest = data and data.dest or nil
            if dest ~= nil then
                inst.sg.statemem.dest = dest
                inst:ForceFacePoint(dest:Get())
            else
                inst.sg.statemem.dest = Vector3(x, y, z)
            end

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end
        end,

        onupdate = function(inst)
            if inst.sg.statemem.tints ~= nil then
                DoWortoxPortalTint(inst, table.remove(inst.sg.statemem.tints))
                if #inst.sg.statemem.tints <= 0 then
                    inst.sg.statemem.tints = nil
                end
            end
        end,

        timeline =
        {
            TimeEvent(FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/infection_post", nil, .7)
                inst.SoundEmitter:PlaySound("dontstarve/characters/wortox/soul/spawn", nil, .5)
            end),
            TimeEvent(2 * FRAMES, function(inst)
                inst.sg.statemem.tints = { 1, .6, .3, .1 }
                PlayFootstep(inst)
            end),
            TimeEvent(4 * FRAMES, function(inst)
                inst.sg:AddStateTag("noattack")
                inst.components.health:SetInvincible(true)
                inst.DynamicShadow:Enable(false)
            end),
        },

        ontimeout = function(inst)
            inst.sg.statemem.portaljumping = true
            inst.sg:GoToState("portal_jumpout", {dest = inst.sg.statemem.dest, from_map = inst.sg.statemem.from_map})
        end,

        onexit = function(inst)
            if not inst.sg.statemem.portaljumping then
                inst.components.health:SetInvincible(false)
                inst.DynamicShadow:Enable(true)
                DoWortoxPortalTint(inst, 0)
            end
        end,
    },

    State{
        name = "portal_jumpout",
        tags = { "busy", "nopredict", "nomorph", "noattack", "nointerrupt" },

        onenter = function(inst, data)
            ToggleOffPhysics(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("wortox_portal_jumpout")
            inst:ResetMinimapOffset()
            local dest = data and data.dest or nil
            if dest ~= nil then
                inst.Physics:Teleport(dest:Get())
            else
                dest = inst:GetPosition()
            end
            SpawnPrefab("wortox_portal_jumpout_fx").Transform:SetPosition(dest:Get())
            inst.DynamicShadow:Enable(false)
            inst.sg:SetTimeout(14 * FRAMES)
            DoWortoxPortalTint(inst, 1)
            inst.components.health:SetInvincible(true)
            inst:PushEvent("soulhop")
        end,

        onupdate = function(inst)
            if inst.sg.statemem.tints ~= nil then
                DoWortoxPortalTint(inst, table.remove(inst.sg.statemem.tints))
                if #inst.sg.statemem.tints <= 0 then
                    inst.sg.statemem.tints = nil
                end
            end
        end,

        timeline =
        {
            TimeEvent(FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/characters/wortox/soul/hop_out")
            end),
            TimeEvent(5 * FRAMES, function(inst)
                inst.sg.statemem.tints = { 0, .4, .7, .9 }
            end),
            TimeEvent(7 * FRAMES, function(inst)
                inst.components.health:SetInvincible(false)
                inst.sg:RemoveStateTag("noattack")
                inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
            end),
            TimeEvent(8 * FRAMES, function(inst)
                inst.DynamicShadow:Enable(true)
                ToggleOnPhysics(inst)
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            inst.components.health:SetInvincible(false)
            inst.DynamicShadow:Enable(true)
            DoWortoxPortalTint(inst, 0)
            if inst.sg.statemem.isphysicstoggle then
                ToggleOnPhysics(inst)
            end
        end,
    },

    State{
        name = "mkatana",
        tags = { "attack", "notalking", "abouttoattack", "autopredict" },

        onenter = function(inst)
			if inst.components.combat:InCooldown() then
                inst.sg:RemoveStateTag("abouttoattack")
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle", true)
                return
            end

            local buffaction = inst:GetBufferedAction()
            local target = buffaction ~= nil and buffaction.target or nil
            local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            local cooldown = inst.components.combat.min_attack_period + .5 * FRAMES

            inst.AnimState:OverrideSymbol("fx_lunge_streak", "player_lunge_blue", "fx_lunge_streak")
            inst.components.combat:SetTarget(target)
            inst.components.combat:StartAttack()
            inst.components.locomotor:Stop()

            if inst.components.rider ~= nil and inst.components.rider:IsRiding() then
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", false)
                DoMountSound(inst, inst.components.rider:GetMount(), "angry", true)
                cooldown = math.max(cooldown, 16 * FRAMES)
            elseif equip ~= nil and equip:HasTag("mkatana") then
                inst.sg.statemem.iskatana = true
				inst.AnimState:SetDeltaTimeMultiplier(1.2)

                local katanarnd = 1

                if katanarnd == 1 then
                    inst.AnimState:PlayAnimation("atk_prop_pre")
					inst.AnimState:PushAnimation("atk", false)
					katanarnd = math.random(2, 3)
                elseif katanarnd == 2 then
					inst.AnimState:SetDeltaTimeMultiplier(1.3)
					inst.sg:AddStateTag("mkatanaatk")
					inst.AnimState:PlayAnimation("chop_pre")
					katanarnd = 4
				elseif katanarnd == 3 then
					inst.AnimState:SetDeltaTimeMultiplier(1.4)
					inst.sg:AddStateTag("mkatanaatk")
					inst.AnimState:PlayAnimation("pickaxe_pre")
					katanarnd = 1
				elseif katanarnd == 4 then
					inst.AnimState:SetDeltaTimeMultiplier(1.4)
					inst.AnimState:PlayAnimation("spearjab_pre")
					inst.AnimState:PushAnimation("spearjab", false)
					katanarnd = 5
                elseif katanarnd == 5 then
                    inst.AnimState:SetDeltaTimeMultiplier(4)
                    inst.sg.statemem.scythe_anim = true
                    inst.AnimState:PlayAnimation("scythe_pre")
                    inst.AnimState:PushAnimation("scythe_loop", false)
                    katanarnd = 6
                else
                	inst.AnimState:PlayAnimation("atk_pre")
                	inst.AnimState:PushAnimation("atk", false)
                	katanarnd = 1
                end

                inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe")
                cooldown = math.max(cooldown, 13 * FRAMES)
            end

            inst.sg:SetTimeout(cooldown)
            if target ~= nil then
                inst.components.combat:BattleCry()
                if target:IsValid() then
                    inst:FacePoint(target:GetPosition())
                    inst.sg.statemem.attacktarget = target
                    inst.sg.statemem.retarget = target
                end
            end
        end,

        timeline = {
			TimeEvent(5 * FRAMES, function(inst)
				inst.AnimState:SetDeltaTimeMultiplier(1)
                if inst.sg.statemem.iskatana and inst.sg:HasStateTag("mkatanaatk") then
                    inst.AnimState:PlayAnimation("lunge_pst")
					inst.sg:RemoveStateTag("mkatanaatk")
                end
            end),

			TimeEvent(8 * FRAMES, function(inst)
                if inst.sg.statemem.iskatana then
    				inst:PerformBufferedAction()
                    inst.sg:RemoveStateTag("abouttoattack")
				end
                if inst.sg.statemem.scythe_anim then
                    local sharkboi_swipe_fx = SpawnPrefab("sharkboi_swipe_fx")
                    if sharkboi_swipe_fx ~= nil then
                        sharkboi_swipe_fx.AnimState:SetScale(0.88, 0.88, 0.88)
                        sharkboi_swipe_fx.entity:SetParent(inst.entity)
                        sharkboi_swipe_fx.Transform:SetPosition(1, 0, 0)
                        sharkboi_swipe_fx:Reverse()
                    end
                    inst.sg.statemem.bearger_swipe_fx = sharkboi_swipe_fx
                end
            end),

			TimeEvent(10 * FRAMES, function(inst)
                if not inst.sg.statemem.iskatana then
                    inst:PerformBufferedAction()
                    inst.sg:RemoveStateTag("abouttoattack")
                end
            end)
        },

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
        end,

        events = {
            EventHandler("equip", function(inst)
                inst.sg:GoToState("idle")
            end),
            EventHandler("unequip", function(inst)
                inst.sg:GoToState("idle")
            end),
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
					inst.AnimState:SetDeltaTimeMultiplier(1)
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.sg.statemem.scythe_anim = false
            inst.components.combat:SetTarget(nil)
            if inst.sg:HasStateTag("abouttoattack") then
                inst.components.combat:CancelAttack()
				inst.AnimState:SetDeltaTimeMultiplier(1)
				if inst.sg:HasStateTag("mkatanaatk") then
                    inst.sg:RemoveStateTag("mkatanaatk")
                end
            end
            local bearger_swipe_fx = inst.sg.statemem.bearger_swipe_fx
            if bearger_swipe_fx ~= nil and bearger_swipe_fx:IsValid() then
				bearger_swipe_fx:Remove()
			end
        end,
    },

    State{
        name = "iai",
        tags = { "attack", "notalking", "abouttoattack", "autopredict" }, --

        onenter = function(inst)
            if inst.components.combat:InCooldown() then
                inst.sg:RemoveStateTag("abouttoattack")
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle", true)
                return
            end

            local buffaction = inst:GetBufferedAction()
            local target = buffaction ~= nil and buffaction.target or nil
            local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            local cooldown = inst.components.combat.min_attack_period + .5 * FRAMES

            inst.AnimState:OverrideSymbol("fx_lunge_streak", "player_lunge_blue", "fx_lunge_streak")
            inst.components.combat:SetTarget(target)
            inst.components.combat:StartAttack()
            inst.components.locomotor:Stop()

            if inst.components.rider ~= nil and inst.components.rider:IsRiding() then
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", false)
                DoMountSound(inst, inst.components.rider:GetMount(), "angry", true)
                cooldown = math.max(cooldown, 16 * FRAMES)
            elseif equip ~= nil and equip:HasTag("iai") then
                inst.sg.statemem.iskatana = true
                inst.AnimState:PlayAnimation("spearjab_pre")
                inst.AnimState:PushAnimation("lunge_pst", false)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe")
                cooldown = math.max(cooldown, 9 * FRAMES)
            end

            inst.sg:SetTimeout(cooldown)
            if target ~= nil then
                inst.components.combat:BattleCry()
                if target:IsValid() then
                    inst:FacePoint(target:GetPosition())
                    inst.sg.statemem.attacktarget = target
                    inst.sg.statemem.retarget = target
                end
            end
        end,

        timeline = {
            TimeEvent(7.5 * FRAMES, function(inst)
                if inst.sg.statemem.iskatana then
                    inst:PerformBufferedAction()
                    inst.sg:RemoveStateTag("abouttoattack")
                end
            end),
            TimeEvent(10 * FRAMES, function(inst)
                if not inst.sg.statemem.iskatana then
                    inst:PerformBufferedAction()
                    inst.sg:RemoveStateTag("abouttoattack")
                end
            end),
        },

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
        end,

        events = {
            EventHandler("equip", function(inst)
                inst.sg:GoToState("idle")
            end),
            EventHandler("unequip", function(inst)
                inst.sg:GoToState("idle")
            end),
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.components.combat:SetTarget(nil)
            if inst.sg:HasStateTag("abouttoattack") then
                inst.components.combat:CancelAttack()
            end
        end,
    },

    State{
        name = "yari",
        tags = { "attack", "notalking", "abouttoattack", "autopredict" }, --

        onenter = function(inst)
            if inst.components.combat:InCooldown() then
                inst.sg:RemoveStateTag("abouttoattack")
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle", true)
                return
            end

            local buffaction = inst:GetBufferedAction()
            local target = buffaction ~= nil and buffaction.target or nil
            local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            local cooldown = inst.components.combat.min_attack_period + .5 * FRAMES

            inst.components.combat:SetTarget(target)
            inst.components.combat:StartAttack()
            inst.AnimState:OverrideSymbol("fx_lunge_streak", "player_lunge_blue", "fx_lunge_streak")
            inst.components.locomotor:Stop()

            if inst.components.rider ~= nil and inst.components.rider:IsRiding() then
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", false)
                DoMountSound(inst, inst.components.rider:GetMount(), "angry", true)
                cooldown = math.max(cooldown, 16 * FRAMES)
            elseif equip ~= nil and equip:HasTag("yari") then
                inst.sg.statemem.isyari = true
                if math.random(1, 3) == 1 then
                    inst.AnimState:PlayAnimation("spearjab_pre")
                    inst.AnimState:PushAnimation("lunge_pst", false)
                elseif math.random(2, 3) == 2 then
                    inst.AnimState:PlayAnimation("atk_pre")
                    inst.AnimState:PushAnimation("atk", false)
                else
                    inst.AnimState:PlayAnimation("spearjab_pre")
                    inst.AnimState:PushAnimation("spearjab", false)
                end
                inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe")
                cooldown = math.max(cooldown, 13 * FRAMES)
            end

            inst.sg:SetTimeout(cooldown)

            if target ~= nil then
                inst.components.combat:BattleCry()
                if target:IsValid() then
                    inst:FacePoint(target:GetPosition())
                    inst.sg.statemem.attacktarget = target
                    inst.sg.statemem.retarget = target
                end
            end
        end,

        timeline = {
            TimeEvent(8 * FRAMES, function(inst)
                if inst.sg.statemem.isyari then
                    inst:PerformBufferedAction()
                    inst.sg:RemoveStateTag("abouttoattack")
                end
            end),
            TimeEvent(10 * FRAMES, function(inst)
                if not inst.sg.statemem.isyari then
                    inst:PerformBufferedAction()
                    inst.sg:RemoveStateTag("abouttoattack")
                end
            end),
        },

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
        end,

        events = {
            EventHandler("equip", function(inst)
                inst.sg:GoToState("idle")
            end),
            EventHandler("unequip", function(inst)
                inst.sg:GoToState("idle")
            end),
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.components.combat:SetTarget(nil)
            if inst.sg:HasStateTag("abouttoattack") then
                inst.components.combat:CancelAttack()
            end
        end,
    },

    State{
        name = "mdash",
        tags = {"busy", "nopredict", "nointerrupt", "nomorph" },

        onenter = function(inst, data)
			if data ~= nil then
				local pos = data.pos:GetPosition()
				inst:ForceFacePoint(pos.x, 0, pos.z)
			end

			local x, y, z = inst.Transform:GetWorldPosition()
			local pufffx = SpawnPrefab("dirt_puff")
			pufffx.Transform:SetScale(.3, .3, .3)
			pufffx.Transform:SetPosition(x, y, z)

			SkillCollision(inst, true)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("atk_leap_pre")
			inst.Physics:SetMotorVelOverride(30,0,0)
			inst.components.locomotor:EnableGroundSpeedMultiplier(false)

			inst.last_dodge_time = GetTime()
			inst.dodgetime:set(inst.dodgetime:value() == false and true or false)
        end,

        timeline = {
			TimeEvent(0 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/jump")
            end),

			TimeEvent(6 * FRAMES, function(inst)
                inst.Physics:ClearMotorVelOverride()
            end),
        },

		events = {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
			SkillCollision(inst, false)
			inst.components.locomotor:EnableGroundSpeedMultiplier(true)
        end,
    },

    State{
        name = "mdash2",
        tags = {"busy", "nopredict", "nointerrupt", "nomorph" },

        onenter = function(inst, data)
			if data ~= nil then
				local pos = data.pos:GetPosition()
				inst:ForceFacePoint(pos.x, 0, pos.z)
			end

			local x, y, z = inst.Transform:GetWorldPosition()
			local pufffx = SpawnPrefab("dirt_puff")
			pufffx.Transform:SetScale(.3, .3, .3)
			pufffx.Transform:SetPosition(x, y, z)

			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("slide_pre")
            inst.AnimState:PushAnimation("slide_loop", false)
			SkillCollision(inst, true)
			inst.Physics:SetMotorVelOverride(20,0,0)
			inst.components.locomotor:EnableGroundSpeedMultiplier(false)

			inst.last_dodge_time = GetTime()
			inst.dodgetime:set(inst.dodgetime:value() == false and true or false)
        end,

        timeline = {
			TimeEvent(0 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/jump")
            end),

			TimeEvent(7 * FRAMES, function(inst)
                inst.Physics:ClearMotorVelOverride()
            end),
        },

		events = {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
			SkillCollision(inst, false)
			inst.components.locomotor:EnableGroundSpeedMultiplier(true)
        end,
    },
}

CommonStates.AddWalkStates(states, {
    walktimeline =
    {
        TimeEvent(0, PlayFootstep),
        TimeEvent(12 * FRAMES, PlayFootstep),
    },
})

CommonStates.AddRunStates(states, {
    runtimeline =
    {
        TimeEvent(0, PlayFootstep),
        TimeEvent(10 * FRAMES, PlayFootstep),
    },
})

return StateGraph("momo", states, events, "idle", actionhandlers)
