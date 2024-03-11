require("stategraphs/commonstates")

local actionhandlers = {
    ActionHandler(ACTIONS.GIVE, "give"),
}

local events = {
    EventHandler("admitdefeated", function(inst, data)
    end),
    EventHandler("taunt", function(inst, data)
    end),
    EventHandler("locomote", function(inst)
        if not inst.sg:HasStateTag("busy") then
            local is_moving = inst.sg:HasStateTag("moving")
            local wants_to_move = inst.components.locomotor:WantsToMoveForward()
            if not inst.sg:HasStateTag("attack") and is_moving ~= wants_to_move then
                if wants_to_move then
                    inst.sg:GoToState("run_start")
                else
                    inst.sg:GoToState("idle")
                end
            end
        end
    end),
    EventHandler("ontalk", function(inst, data)
        if inst.sg:HasStateTag("idle") and not inst.sg:HasStateTag("notalking") then
            inst.sg:GoToState("talk", data.noanim)
		elseif data.duration ~= nil and not data.noanim then
			inst.sg.mem.queuetalk_timeout = data.duration + GetTime()
		end
    end),
}

local states = {
    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst, pushanim)
			if inst.sg.lasttags and not inst.sg.lasttags["busy"] then
				inst.components.locomotor:StopMoving()
			else
				inst.components.locomotor:Stop()
				inst.components.locomotor:Clear()
			end
			inst:ClearBufferedAction()

			if inst.sg.mem.queuetalk_timeout ~= nil then
				local remaining_talk_time = inst.sg.mem.queuetalk_timeout - GetTime()
				inst.sg.mem.queuetalk_timeout = nil
				if not (pushanim) then
					if remaining_talk_time > 1 then
                        inst.sg:GoToState("talk")
                        return
					end
				end
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
    }
}

return StateGraph("momo", states, events, "idle")
