--[[
    Most of the code comes from SGwilson
]]

require("stategraphs/commonstates")

local ATTACK_PROP_MUST_TAGS = { "_combat" }
local ATTACK_PROP_CANT_TAGS = { "flying", "shadow", "ghost", "FX", "NOCLICK", "DECOR", "INLIMBO", "playerghost" }

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
    inst.SoundEmitter:PlaySound((inst.talker_path_override or "dontstarve/characters/")..(inst.soundsname or inst.prefab).."/talk_LP", "talk")
end

local function DoHurtSound(inst)
    inst.SoundEmitter:PlaySound((inst.talker_path_override or "dontstarve/characters/")..(inst.soundsname or inst.prefab).."/hurt", nil, inst.hurtsoundvolume)
end

local function DoYawnSound(inst)
    inst.SoundEmitter:PlaySound((inst.talker_path_override or "dontstarve/characters/")..(inst.soundsname or inst.prefab).."/yawn")
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
    else
        inst.Physics:CollidesWith(COLLISION.WORLD)
        inst.Physics:CollidesWith(COLLISION.OBSTACLES)
        inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
        inst.Physics:CollidesWith(COLLISION.CHARACTERS)
        inst.Physics:CollidesWith(COLLISION.GIANTS)
    end
end

local function GetUnequipState(inst, data)
    return (data.eslot ~= EQUIPSLOTS.HANDS and "item_hat")
        or (not data.slip and "item_in"), data.item
end

local function StartTeleporting(inst)
    inst.sg.statemem.isteleporting = true

    inst.components.health:SetInvincible(true)
    if inst.components.playercontroller ~= nil then
        inst.components.playercontroller:Enable(false)
    end
    inst:Hide()
    inst.DynamicShadow:Enable(false)
end

local function DoneTeleporting(inst)
    inst.sg.statemem.isteleporting = false

    inst.components.health:SetInvincible(false)
    if inst.components.playercontroller ~= nil then
        inst.components.playercontroller:Enable(true)
    end
    inst:Show()
    inst.DynamicShadow:Enable(true)
end

local NOTENTCHECK_CANT_TAGS = { "FX", "INLIMBO" }

local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end

local function NoEntCheckFn(pt)
    return NoHoles(pt) and #TheSim:FindEntities(pt.x, pt.y, pt.z, 1, nil, NOTENTCHECK_CANT_TAGS) == 0
end

local function SpawnPortalEntrance(inst)
    local pt = inst:GetPosition()
    local offset = FindWalkableOffset(pt, math.random() * 2 * PI, 3 + math.random(), 16, false, true, NoEntCheckFn, true, true)
                    or FindWalkableOffset(pt, math.random() * 2 * PI, 5 + math.random(), 16, false, true, NoEntCheckFn, true, true)
                    or FindWalkableOffset(pt, math.random() * 2 * PI, 7 + math.random(), 16, false, true, NoEntCheckFn, true, true)
    if offset ~= nil then
        pt = pt + offset
    end

    local portal = SpawnPrefab("pocketwatch_portal_entrance")
    portal.Transform:SetPosition(pt:Get())
    inst.SoundEmitter:PlaySound("wanda1/wanda/portal_entrance_pre")
    return portal
end

local function OnRemoveCleanupTargetFX(inst)
    if inst.sg.statemem.targetfx.KillFX ~= nil then
        inst.sg.statemem.targetfx:RemoveEventCallback("onremove", OnRemoveCleanupTargetFX, inst)
        inst.sg.statemem.targetfx:KillFX()
    else
        inst.sg.statemem.targetfx:Remove()
    end
end

local katanarnd = 1

local actionhandlers =
{
    ActionHandler(ACTIONS.HAMMER, function(inst)
        return not inst.sg:HasStateTag("prehammer")
            and (inst.sg:HasStateTag("hammering") and
                "hammer" or
                "hammer_start")
            or nil
    end),
    ActionHandler(ACTIONS.CHOP, function(inst)
        return not inst.sg:HasStateTag("prechop")
        and (inst.sg:HasStateTag("chopping") and
            "chop" or
            "chop_start")
        or nil
    end),
    ActionHandler(ACTIONS.MINE, function(inst)
        return not inst.sg:HasStateTag("premine")
        and (inst.sg:HasStateTag("mining") and
            "mine" or
            "mine_start")
        or nil
    end),
    -- ActionHandler(ACTIONS.HACK, function(inst)
    --     return not inst.sg:HasStateTag("prehack")
    --     and (inst.sg:HasStateTag("hacking") and
    --         "hack" or
    --         "hack_start")
    --     or nil
    -- end),
    ActionHandler(ACTIONS.DIG, function(inst)
        return not inst.sg:HasStateTag("predig")
        and (inst.sg:HasStateTag("digging") and
            "dig" or
            "dig_start")
        or nil
    end),
    ActionHandler(ACTIONS.POUR_WATER, function(inst, action)
        return action.invobject ~= nil
            and (action.invobject:HasTag("wateringcan") and "pour")
            or "dolongaction"
    end),

    ActionHandler(ACTIONS.READ, function(inst, action)
        return (action.invobject ~= nil and action.invobject.components.simplebook ~= nil and "cookbook_open")
            or (inst.components.reader ~= nil and inst.components.reader:IsAspiringBookworm() and "book_peruse")
            or "book"
    end),

    ActionHandler(ACTIONS.FERTILIZE, function(inst, action)
        return (((action.target ~= nil and action.target ~= inst) or action:GetActionPoint() ~= nil) and "doshortaction")
            or (action.invobject ~= nil and action.invobject:HasTag("slowfertilize") and "fertilize")
            or "fertilize_short"
    end),

    ActionHandler(ACTIONS.TILL, "till_start"),
    ActionHandler(ACTIONS.PICKUP, "pickup"),
    ActionHandler(ACTIONS.PICK, "pickup"),
    ActionHandler(ACTIONS.GIVE, "give"),
}

local events = {
    CommonHandlers.OnLocomote(true, false),
    CommonHandlers.OnAttacked(),
    EventHandler("ontalk", function(inst, data)
        if inst.sg:HasStateTag("idle") and not inst.sg:HasStateTag("notalking") then
            inst.sg:GoToState("talk", data.noanim)
        end
    end),
    EventHandler("use_portal_jumpin", function(inst, data)
        inst.sg:GoToState("portal_jumpin_pre", data)
    end),
    EventHandler("use_pocketwatch", function(inst, data)
        if data ~= nil then
            local watch = data.watch
            if watch ~= nil then
                inst.sg:GoToState((watch:HasTag("pocketwatch_warp_casting" and "pocketwatch_warpback_pre")
                or "pocketwatch_cast"), watch)
            end
        end
    end),
    EventHandler("use_pocketwatch_portal", function(inst, data)
        inst.sg:GoToState("pocketwatch_openportal", data)
    end),
    EventHandler("releaselight", function(inst, data)
        inst.sg:GoToState("releaselight", data)
    end),
    EventHandler("dance", function(inst)
        if not inst.sg:HasStateTag("busy") and (not inst.sg:HasStateTag("dancing")) then
            inst.sg:GoToState("dance")
        end
    end),

    EventHandler("equip", function(inst, data)
        if inst.sg:HasStateTag("acting") then
            return
        end
        if (inst.sg:HasStateTag("idle") or inst.sg:HasStateTag("channeling")) and not inst:HasTag("wereplayer") then
            inst.sg:GoToState(
                (data.item ~= nil and data.item.projectileowner ~= nil and "catch_equip") or
                (data.eslot == EQUIPSLOTS.HANDS and "item_out") or
                "item_hat"
            )
        end
    end),

    EventHandler("unequip", function(inst, data)
        if inst.sg:HasStateTag("acting") then
            return
        end
        if inst.sg:HasStateTag("idle") or inst.sg:HasStateTag("channeling") then
            inst.sg:GoToState(GetUnequipState(inst, data))
        end
    end),

    EventHandler("yawn", function(inst, data)
        if not (inst.components.health:IsDead() or
                inst.sg:HasStateTag("sleeping") or
                (inst.components.freezable ~= nil and inst.components.freezable:IsFrozen())) then
            inst.sg:GoToState("yawn", data)
        end
    end),
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
                inst.AnimState:PlayAnimation("dial_loop", true)
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
        name = "pocketwatch_openportal",
        tags = { "doing", "busy", "canrotate" },

        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("useitem_pre")
            inst.AnimState:PushAnimation("pocketwatch_portal", false)
            inst.AnimState:PushAnimation("useitem_pst", false)

            if data.target_pos ~= nil then
                inst.sg.statemem.target_pos = data.target_pos
            end

            inst.components.locomotor:Stop()
            inst.AnimState:OverrideSymbol("watchprop", "pocketwatch_portal", "watchprop")
        end,

        timeline =
        {
            TimeEvent(18 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
                local portal = SpawnPortalEntrance(inst)
                inst.sg.statemem.portal = portal
            end),
            TimeEvent(37 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst:ForceFacePoint(inst.sg.statemem.portal:GetPosition():Get())
                    if inst.sg.statemem.portal ~= nil then
                        inst.sg:GoToState("jumpin_pre", {teleporter = inst.sg.statemem.portal, target_pos = inst.sg.statemem.target_pos})
                    end
                end
            end),
        },

        onexit = function(inst)
            inst.AnimState:ClearOverrideSymbol("watchprop")
        end,
    },

    State{
        name = "pocketwatch_cast",
        tags = { "busy", "doing" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("useitem_pre") -- 8 frames
            inst.AnimState:PushAnimation("pocketwatch_cast", false)
            inst.AnimState:PushAnimation("useitem_pst", false)

            local buffaction = inst:GetBufferedAction()
            if buffaction ~= nil then
                inst.AnimState:OverrideSymbol("watchprop", buffaction.invobject.AnimState:GetBuild(), "watchprop")
                inst.sg.statemem.castfxcolour = buffaction.invobject.castfxcolour
                inst.sg.statemem.pocketwatch = buffaction.invobject
                inst.sg.statemem.target = buffaction.target
            end
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst)
                local pocketwatch = inst.sg.statemem.pocketwatch
                if pocketwatch ~= nil and pocketwatch:IsValid() and pocketwatch.components.pocketwatch:CanCast(inst, inst.sg.statemem.target) then
                    inst.sg.statemem.stafffx = SpawnPrefab("pocketwatch_cast_fx")
                    inst.sg.statemem.stafffx.entity:SetParent(inst.entity)
                    inst.sg.statemem.stafffx:SetUp(inst.sg.statemem.castfxcolour or { 1, 1, 1 })

                    inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/heal")
                end
            end),
            TimeEvent(16 * FRAMES, function(inst)
                if inst.sg.statemem.stafffx ~= nil then
                    inst.sg.statemem.stafflight = SpawnPrefab("staff_castinglight_small")
                    inst.sg.statemem.stafflight.Transform:SetPosition(inst.Transform:GetWorldPosition())
                    inst.sg.statemem.stafflight:SetUp(inst.sg.statemem.castfxcolour or { 1, 1, 1 }, 0.75, 0)
                end
            end),
            TimeEvent(25 * FRAMES, function(inst)
                if not inst:PerformBufferedAction() then
                    inst.sg.statemem.action_failed = true
                end
            end),

            --success timeline
            TimeEvent(40 * FRAMES, function(inst)
                if not inst.sg.statemem.action_failed then
                    inst.sg:RemoveStateTag("busy")
                end
            end),

            --failed timeline
            TimeEvent(28 * FRAMES, function(inst)
                if inst.sg.statemem.action_failed then
                    inst.AnimState:SetFrame(34)
                    if inst.sg.statemem.stafffx ~= nil then
                        inst.sg.statemem.stafffx:Remove()
                        inst.sg.statemem.stafffx = nil
                    end
                    if inst.sg.statemem.stafflight ~= nil then
                        inst.sg.statemem.stafflight:Remove()
                        inst.sg.statemem.stafflight = nil
                    end
                end
            end),
            TimeEvent(41 * FRAMES, function(inst)
                if inst.sg.statemem.action_failed then
                    inst.sg:RemoveStateTag("busy")
                end
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
            if inst.sg.statemem.stafffx ~= nil and inst.sg.statemem.stafffx:IsValid() then
                inst.sg.statemem.stafffx:Remove()
            end
            if inst.sg.statemem.stafflight ~= nil and inst.sg.statemem.stafflight:IsValid() then
                inst.sg.statemem.stafflight:Remove()
            end
        end,
    },

    State{
        name = "pocketwatch_warpback_pre",
        tags = { "busy" },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("pocketwatch_warp_pre")

            inst.sg.statemem.dest_pos = data.dest_pos
            inst.AnimState:OverrideSymbol("watchprop", "pocketwatch_recall", "watchprop")
        end,

        timeline=
        {
            TimeEvent(1*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/warp")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    local dest_pos = inst.sg.statemem.dest_pos
                    inst.sg.statemem.portaljumping = true
                    inst.sg:GoToState("pocketwatch_warpback", {dest_pos = dest_pos})
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.portaljumping then
                inst.AnimState:ClearOverrideSymbol("watchprop")
            end
        end,
    },

    State{
        name = "pocketwatch_warpback",
        tags = { "busy", "pausepredict", "nodangle", "nomorph", "jumping" },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("pocketwatch_warp")

            inst.sg.statemem.dest_pos = data.dest_pos

            inst.sg.statemem.stafffx = SpawnPrefab("pocketwatch_warpback_fx")
            inst.sg.statemem.stafffx.entity:SetParent(inst.entity)
            inst.sg.statemem.stafffx:SetUp({ 1, 1, 1 })
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                inst.sg:AddStateTag("noattack")
                inst.components.health:SetInvincible(true)
                inst.DynamicShadow:Enable(false)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.sg.statemem.stafffx ~= nil then
                        -- detach fx
                        inst.sg.statemem.stafffx.entity:SetParent(nil)
                        inst.sg.statemem.stafffx.Transform:SetPosition(inst.Transform:GetWorldPosition())
                        inst.sg.statemem.stafffx = nil
                    end

                    local dest_pos = inst.sg.statemem.dest_pos
                    inst.sg.statemem.portaljumping = true
                    inst.sg:GoToState("pocketwatch_warpback_pst", {dest_pos = dest_pos})
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.stafffx ~= nil and inst.sg.statemem.stafffx:IsValid() then
                inst.sg.statemem.stafffx:Remove()
            end
            if not inst.sg.statemem.portaljumping then
                inst.AnimState:ClearOverrideSymbol("watchprop")
                inst.components.health:SetInvincible(false)
                inst.DynamicShadow:Enable(true)
            end
        end,
    },

    State{
        name = "pocketwatch_warpback_pst",
        tags = { "busy", "nopredict", "nomorph", "noattack", "nointerrupt", "jumping" },

        onenter = function(inst, data)
            ToggleOffPhysics(inst)
            inst.components.locomotor:Stop()
            inst.DynamicShadow:Enable(false)
            inst.components.health:SetInvincible(true)

            inst.AnimState:PlayAnimation("pocketwatch_warp_pst")

            local dest_x, dest_y, dest_z
            local dest_pos = data.dest_pos

            if dest_pos == nil then
                dest_x, dest_y, dest_z = inst.Transform:GetWorldPosition()
            else
                dest_pos = inst:CalculateLandPoint(dest_pos)
                dest_x, dest_y, dest_z = dest_pos.x, dest_pos.y, dest_pos.z
            end

            inst.Physics:Teleport(dest_x, dest_y, dest_z)

            local fx = SpawnPrefab("pocketwatch_warpbackout_fx")
            fx.Transform:SetPosition(dest_x, dest_y, dest_z)
            fx:SetUp({ 1, 1, 1 })
        end,

        timeline =
        {
            TimeEvent(1*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/recall")
            end),

            TimeEvent(3 * FRAMES, function(inst)
                inst.DynamicShadow:Enable(true)
                ToggleOnPhysics(inst)
            end),
            TimeEvent(4 * FRAMES, function(inst)
                inst.components.health:SetInvincible(false)
                inst.sg:RemoveStateTag("jumping")
                inst.sg:RemoveStateTag("nomorph")
                inst.sg:RemoveStateTag("nointerrupt")
                inst.sg:RemoveStateTag("noattack")
                inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
            end),
            TimeEvent(9 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nopredict")
                inst.sg:AddStateTag("idle")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.AnimState:ClearOverrideSymbol("watchprop")
            inst.components.health:SetInvincible(false)
            inst.DynamicShadow:Enable(true)
            if inst.sg.statemem.isphysicstoggle then
                ToggleOnPhysics(inst)
            end
        end,
    },

    State{
        name = "pocketwatch_portal_land",
        tags = { "busy", "nopredict", "nomorph", "nodangle", "jumping", "noattack" },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()
            StartTeleporting(inst)

            inst.AnimState:PlayAnimation("jumpportal_out")

            local x, y, z = inst.Transform:GetWorldPosition()
            local fx = SpawnPrefab("pocketwatch_portal_exit_fx")
            fx.Transform:SetPosition(x, 4, z)
        end,

        timeline =
        {
            TimeEvent(16 * FRAMES, function(inst)
                inst:Show() -- hidden by StartTeleporting
            end),

            TimeEvent(17 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("wanda1/wanda/jump_whoosh")
            end),

            TimeEvent(20 * FRAMES, function(inst)
                inst.DynamicShadow:Enable(true)
            end),

            TimeEvent(22 * FRAMES, function(inst)
                PlayFootstep(inst)
            end),

            TimeEvent(28 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("jumping")
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nomorph")
                inst.sg:RemoveStateTag("noattack")

                DoneTeleporting(inst)
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
            if inst.sg.statemem.isteleporting then
                DoneTeleporting(inst)
            end
        end,
    },

    State{
        name = "portal_jumpin_pre",
        tags = { "busy" },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("wortox_portal_jumpin_pre")

            local buffaction = inst:GetBufferedAction()
            if buffaction ~= nil and buffaction.pos ~= nil then
                inst:ForceFacePoint(buffaction:GetActionPoint():Get())
            end
            if data ~= nil and data.pos ~= nil then
                inst.sg.statemem.dest_pos = data.pos
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() and not inst:PerformBufferedAction() then
                    inst.sg:GoToState("portal_jumpin", {dest = inst.sg.statemem.dest_pos})
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
            local dest = data and data.dest or nil
            if dest ~= nil then
                inst.sg.statemem.dest = dest
                inst:ForceFacePoint(dest:Get())
            else
                inst.sg.statemem.dest = Vector3(x, y, z)
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
            inst.sg:GoToState("portal_jumpout", {dest = inst.sg.statemem.dest})
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
        name = "attack",
        tags = { "attack", "notalking", "abouttoattack", "autopredict" },

        onenter = function(inst)
            local target = inst:TheHoney()
            local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            local cooldown = inst.components.combat.min_attack_period + .5 * FRAMES

            inst.AnimState:OverrideSymbol("fx_lunge_streak", "player_lunge_blue", "fx_lunge_streak")
            inst.components.combat:SetTarget(target)
            inst.components.combat:StartAttack()
            inst.components.locomotor:Stop()

            if equip ~= nil then
                inst.sg.statemem.iskatana = true
                inst.AnimState:SetDeltaTimeMultiplier(1.2)

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
                inst.components.combat:DoAttack()
                if inst.sg.statemem.iskatana and inst.sg:HasStateTag("mkatanaatk") then
                    inst.AnimState:PlayAnimation("lunge_pst")
                    inst.sg:RemoveStateTag("mkatanaatk")
                end
            end),

            TimeEvent(8 * FRAMES, function(inst)
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
        name = "mdash",
        tags = {"busy", "nopredict", "nointerrupt", "nomorph" },

        onenter = function(inst, data)
            if data ~= nil then
                local pos
                if data.pos ~= nil then
                    pos = data.pos:GetPosition()
                else
                    pos = inst:GetPosition()
                end

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
                local pos
                if data.pos ~= nil then
                    pos = data.pos:GetPosition()
                else
                    pos = inst:GetPosition()
                end

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

    State{
        name = "releaselight",
        tags = { "doing", "busy", "nodangle" },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("wendy_recall")
            inst.AnimState:PushAnimation("wendy_recall_pst", false)

            if data ~= nil then
                if data.phase == "night" then
                    inst.components.talker:Say(STRINGS.MOMO.ONNIGHT.FORHONEY)
                end
            end
        end,

        timeline =
        {
            TimeEvent(6*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/summon_pre")
            end),
            TimeEvent(30 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/recall")
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
            if inst.sg.statemem.isnight then
                inst.components.talker:Say(STRINGS.MOMO.ONNIGHT.FORSELF)
            end
        end
    },

    State{
        name = "dance",
        tags = {"idle", "dancing"},

        onenter = function(inst)
            inst.components.locomotor:Stop()

            local ignoreplay = inst.AnimState:IsCurrentAnimation("run_pst")
            -- NOTES(JBK): No dance data do default dance.
            if ignoreplay then
                inst.AnimState:PushAnimation("emoteXL_pre_dance0")
            else
                inst.AnimState:PlayAnimation("emoteXL_pre_dance0")
            end
            inst.AnimState:PushAnimation("emoteXL_loop_dance0", true)
        end,
    },

    State{
        name = "hit",
        tags = { "busy", "pausepredict"},

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("hit")

            DoHurtSound(inst)

            --V2C: some of the woodie's were-transforms have shorter hit anims
            local stun_frames = math.min(inst.AnimState:GetCurrentAnimationNumFrames(), 6)
            inst.sg:SetTimeout(stun_frames * FRAMES)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        events =
        {
            EventHandler("animover", function(inst)
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
        name = "item_out",
        tags = { "idle", "nodangle", "keepchannelcasting" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("item_out")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "item_in",
        tags = { "idle", "nodangle", "keepchannelcasting" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("item_in")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "item_hat",
        tags = { "idle", "keepchannelcasting" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("item_hat")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "catch_equip",
        tags = { "idle" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("catch_pre")
            inst.AnimState:PushAnimation("catch", false)
        end,

        timeline =
        {
            TimeEvent(9 * FRAMES, function(inst)
                inst.sg.statemem.playedfx = true
                SpawnPrefab("lucy_transform_fx").entity:AddFollower():FollowSymbol(inst.GUID, "swap_object", 50, -25, 0)
            end),
            TimeEvent(13 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/boomerang_catch")
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
            if not inst.sg.statemem.playedfx then
                SpawnPrefab("lucy_transform_fx").entity:AddFollower():FollowSymbol(inst.GUID, "swap_object", 50, -25, 0)
            end
        end,
    },

    State{
        name = "jumpin_pre",
        tags = { "doing", "busy", "canrotate" },

        onenter = function(inst, data)
            inst.sg.statemem.portal = data.teleporter

            if data.target_pos ~= nil then
                inst.sg.statemem.target_pos = data.target_pos
            end

            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("jump_pre", false)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("jumpin", {teleporter = inst.sg.statemem.portal, target_pos = inst.sg.statemem.target_pos})
                end
            end),
        },
    },

    State{
        name = "jumpin",
        tags = { "doing", "busy", "canrotate", "nopredict", "nomorph" },

        onenter = function(inst, data)
            ToggleOffPhysics(inst)
            inst.components.locomotor:Stop()

            inst.sg.statemem.portal = data.teleporter

            if data ~= nil then
                inst.sg.statemem.target_pos = data.target_pos
            end

            inst.AnimState:PlayAnimation("jump")

            local pos = data ~= nil and data.teleporter and data.teleporter:GetPosition() or nil

            local MAX_JUMPIN_DIST = 3
            local MAX_JUMPIN_DIST_SQ = MAX_JUMPIN_DIST * MAX_JUMPIN_DIST
            local MAX_JUMPIN_SPEED = 6

            local dist
            if pos ~= nil then
                local distsq = inst:GetDistanceSqToPoint(pos:Get())
                if distsq <= .25 * .25 then
                    dist = 0
                    inst.sg.statemem.speed = 0
                elseif distsq >= MAX_JUMPIN_DIST_SQ then
                    dist = MAX_JUMPIN_DIST
                    inst.sg.statemem.speed = MAX_JUMPIN_SPEED
                else
                    dist = math.sqrt(distsq)
                    inst.sg.statemem.speed = MAX_JUMPIN_SPEED * dist / MAX_JUMPIN_DIST
                end
            else
                inst.sg.statemem.speed = 0
                dist = 0
            end

            inst.Physics:SetMotorVel(inst.sg.statemem.speed * .5, 0, 0)
        end,

        timeline =
        {
            TimeEvent(.5 * FRAMES, function(inst)
                inst.Physics:SetMotorVel(inst.sg.statemem.speed * .75, 0, 0)
            end),
            TimeEvent(1 * FRAMES, function(inst)
                inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
            end),
            TimeEvent(15 * FRAMES, function(inst)
                inst.Physics:Stop()
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    local target_pos = inst.sg.statemem.target_pos
                    local x, y, z
                    if target_pos ~= nil then
                        target_pos = inst:CalculateLandPoint(target_pos)
                        x, y, z = target_pos.x, target_pos.y, target_pos.z
                    else
                        local pt = inst:GetPosition()
                        if pt ~= nil then
                            local pos = inst:CalculateLandPoint(inst:GetPosition(), 4)
                            x, y, z = pos.x, pos.y, pos.z
                        end
                    end
                    if x ~= nil and y ~= nil and z ~= nil then
                        inst.Physics:Teleport(x, y, z)
                    end
                    inst.sg:GoToState("pocketwatch_portal_land")
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.isphysicstoggle then
                ToggleOnPhysics(inst)
            end
            inst.Physics:Stop()

            if inst.sg.statemem.isteleporting then
                inst.components.health:SetInvincible(false)
                inst:Show()
                inst.DynamicShadow:Enable(true)
            end
        end,
    },

    State{
        name = "bedroll",
        tags = { "bedroll", "busy", "nomorph" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.AnimState:OverrideSymbol("swap_bedroll", "swap_bedroll_furry", "bedroll_furry")

            inst.AnimState:PlayAnimation("action_uniqueitem_pre")
            inst.AnimState:PushAnimation("bedroll", false)
            inst:OnSleepIn()

            if inst._sleepinghandsitem ~= nil then
                inst.AnimState:Show("ARM_carry")
                inst.AnimState:Hide("ARM_normal")
            end
        end,

        timeline =
        {
            TimeEvent(20 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/use_bedroll")
            end),
        },

        events =
        {
            EventHandler("firedamage", function(inst)
                if inst.sg:HasStateTag("sleeping") then
                    inst.sg.statemem.iswaking = true
                    inst.sg:GoToState("wakeup")
                end
            end),
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    if TheWorld.state.isday then
                        inst.sg.statemem.iswaking = true
                        inst.sg:GoToState("wakeup")
                    elseif inst.AnimState:IsCurrentAnimation("bedroll") or inst.AnimState:IsCurrentAnimation("bedroll_sleep_loop") then
                        inst.sg:AddStateTag("sleeping")
                        inst.sg:AddStateTag("silentmorph")
                        inst.sg:RemoveStateTag("nomorph")
                        inst.sg:RemoveStateTag("busy")
                        inst.AnimState:PlayAnimation("bedroll_sleep_loop", true)
                    end
                end
            end),
        },

        onexit = function(inst)
            if not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
                inst.AnimState:Hide("ARM_carry")
                inst.AnimState:Show("ARM_normal")
            end

            if not inst.sg.statemem.iswaking then
                inst:OnWakeUp()
            end
        end,
    },

    State{
        name = "wakeup",
        tags = { "busy", "waking", "nomorph", "nodangle" },

        onenter = function(inst, data)
            if inst.AnimState:IsCurrentAnimation("bedroll") or
                inst.AnimState:IsCurrentAnimation("bedroll_sleep_loop") then
                inst.AnimState:PlayAnimation("bedroll_wakeup")
            elseif not (inst.AnimState:IsCurrentAnimation("bedroll_wakeup") or
                        inst.AnimState:IsCurrentAnimation("wakeup")) then
                inst.AnimState:PlayAnimation("wakeup")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst:OnWakeUp()
            inst.components.talker:Say(STRINGS.MOMO.COZY_SLEEP)
        end,
    },

    -- 浇水
    State{
        name = "pour",
        tags = { "doing", "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("water_pre")
            inst.AnimState:PushAnimation("water", false)

            inst.AnimState:Show("water")

            inst.sg.statemem.action = inst:GetBufferedAction()

            if inst.sg.statemem.action ~= nil then
                local pt = inst.sg.statemem.action:GetActionPoint()
                if pt ~= nil then
                    local tx, ty, tz = TheWorld.Map:GetTileCenterPoint(pt.x, 0, pt.z)
                    inst.Transform:SetRotation(inst:GetAngleToPoint(tx, ty, tz))
                end

                local invobject = inst.sg.statemem.action.invobject
                if invobject.components.finiteuses ~= nil and invobject.components.finiteuses:GetUses() <= 0 then
                    inst.AnimState:Hide("water")
                    inst.sg.statemem.nosound = true
                end
            end

            inst.sg:SetTimeout(26 * FRAMES)
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
            TimeEvent(5 * FRAMES, function(inst)
                if not inst.sg.statemem.nosound then
                    inst.SoundEmitter:PlaySound("farming/common/watering_can/use")
                end
            end),
            TimeEvent(24 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action then
                inst:ClearBufferedAction()
            end
        end,
    },

    State{
        name = "startconstruct",

        onenter = function(inst)
            inst.sg:GoToState("construct", .5)
        end,
    },

    State{
        name = "construct",
        tags = { "doing", "busy", "nodangle" },

        onenter = function(inst, timeout)
            inst.components.locomotor:Stop()
            inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "make")
            if timeout ~= nil then
                inst.sg:SetTimeout(timeout)
                inst.sg.statemem.delayed = true
                inst.AnimState:PlayAnimation("build_pre")
                inst.AnimState:PushAnimation("build_loop", true)
            else
                inst.sg:SetTimeout(.7)
                inst.AnimState:PlayAnimation("construct_pre")
                inst.AnimState:PushAnimation("construct_loop", true)
            end
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                if inst.sg.statemem.delayed then
                    inst.sg:RemoveStateTag("busy")
                end
            end),
            TimeEvent(9 * FRAMES, function(inst)
                if not (inst.sg.statemem.delayed or inst:PerformBufferedAction()) then
                    inst.sg:RemoveStateTag("busy")
                end
            end),
        },

        ontimeout = function(inst)
            if not inst.sg.statemem.delayed then
                inst.SoundEmitter:KillSound("make")
                inst.AnimState:PlayAnimation("construct_pst")
            elseif not inst:PerformBufferedAction() then
                inst.SoundEmitter:KillSound("make")
                inst.AnimState:PlayAnimation("build_pst")
            end
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.constructing then
                inst.SoundEmitter:KillSound("make")
            end
        end,
    },

    State{
        name = "constructing",
        tags = { "doing", "busy", "nodangle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            if not inst.SoundEmitter:PlayingSound("make") then
                inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "make")
            end
            if not inst.AnimState:IsCurrentAnimation("construct_loop") then
                if inst.AnimState:IsCurrentAnimation("build_loop") then
                    inst.AnimState:PlayAnimation("build_pst")
                    inst.AnimState:PushAnimation("construct_loop", true)
                else
                    inst.AnimState:PlayAnimation("construct_loop", true)
                end
            end
        end,

        timeline =
        {
            TimeEvent(FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },

        onupdate = function(inst)
            if not CanEntitySeeTarget(inst, inst) then
                inst.AnimState:PlayAnimation("construct_pst")
                inst.sg:GoToState("idle", true)
            end
        end,

        events =
        {
            EventHandler("stopconstruction", function(inst)
                inst.AnimState:PlayAnimation("construct_pst")
                inst.sg:GoToState("idle", true)
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.constructing then
                inst.SoundEmitter:KillSound("make")
                inst.components.constructionbuilder:StopConstruction()
            end
        end,
    },

    State{
        name = "construct_pst",
        tags = { "doing", "busy", "nodangle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            if not inst.SoundEmitter:PlayingSound("make") then
                inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "make")
            end
            inst.AnimState:PlayAnimation("build_pre")
            inst.AnimState:PushAnimation("build_loop", true)
            inst.sg:SetTimeout(inst:HasTag("fastbuilder") and .5 or 1)
        end,

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("busy")
            inst.AnimState:PlayAnimation("build_pst")
            -- inst.sg.statemem.finished = true
            -- inst.components.constructionbuilder:OnFinishConstruction()
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("make")
            if not inst.sg.statemem.finished then
                inst.components.constructionbuilder:StopConstruction()
            end
        end,
    },

    State{
        name = "yawn",
        tags = { "busy", "yawn", "pausepredict" },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:PlayAnimation("yawn")
        end,

        timeline =
        {
            TimeEvent(15 * FRAMES, function(inst)
                DoYawnSound(inst)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:RemoveStateTag("yawn")
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "book",
        tags = { "doing", "busy" },

        onenter = function(inst, repeatcast)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("action_uniqueitem_pre")

            local book = inst.bufferedaction ~= nil and (inst.bufferedaction.target or inst.bufferedaction.invobject) or nil
            if book ~= nil then
                inst.components.inventory:ReturnActiveActionItem(book)

                if book.components.spellbook ~= nil and book.components.spellbook:HasSpellFn() then
                    --inst.sg:AddStateTag("busy")
                elseif book.components.aoetargeting ~= nil then
                    --inst.sg:AddStateTag("busy")
                    inst.sg.statemem.targetfx = book.components.aoetargeting:SpawnTargetFXAt(inst.bufferedaction:GetDynamicActionPoint())
                    if inst.sg.statemem.targetfx ~= nil then
                        inst.sg.statemem.targetfx:ListenForEvent("onremove", OnRemoveCleanupTargetFX, inst)
                    end
                end
            end

            local fxname = book ~= nil and book:HasTag("shadowmagic") and "waxwell_book_fx" or "book_fx"
            if inst.components.rider:IsRiding() then
                fxname = fxname.."_mount"
            end
            inst.sg.statemem.book_fx = SpawnPrefab(fxname)
            inst.sg.statemem.book_fx.entity:SetParent(inst.entity)

            if repeatcast then
                local t = inst.AnimState:GetCurrentAnimationNumFrames()
                inst.sg.statemem.book_fx.AnimState:SetFrame(t + 6)
                inst.sg.statemem.not_interrupted = true
                inst.sg:GoToState("book2", {
                    book_fx = inst.sg.statemem.book_fx,
                    targetfx = inst.sg.statemem.targetfx,
                    repeatcast = true,
                })
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.not_interrupted = true
                    inst.sg:GoToState("book2", {
                        book_fx = inst.sg.statemem.book_fx,
                        targetfx = inst.sg.statemem.targetfx,
                    })
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.not_interrupted then
                if inst.sg.statemem.book_fx ~= nil and inst.sg.statemem.book_fx:IsValid() then
                    inst.sg.statemem.book_fx:Remove()
                end
                if inst.sg.statemem.targetfx ~= nil and inst.sg.statemem.targetfx:IsValid() then
                    OnRemoveCleanupTargetFX(inst)
                end
            end
        end,
    },

    State{
        name = "book2",
        tags = { "doing", "busy" },

        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("book")

            --V2C: NOTE that these are now used in onexit to clear skinned symbols
            --Moved to player_common because these symbols are never cleared
            --inst.AnimState:OverrideSymbol("book_open", "player_actions_uniqueitem", "book_open")
            --inst.AnimState:OverrideSymbol("book_closed", "player_actions_uniqueitem", "book_closed")

            local frameskip = 0
            if data ~= nil then
                inst.sg.statemem.book_fx = data.book_fx
                inst.sg.statemem.targetfx = data.targetfx
                if data.repeatcast then
                    inst.sg.statemem.repeatcast = true
                    frameskip = 6
                    inst.AnimState:SetFrame(frameskip)
                end
            end

            local book = inst.bufferedaction ~= nil and (inst.bufferedaction.target or inst.bufferedaction.invobject) or nil
            if book ~= nil then
                local suffix = inst.components.rider:IsRiding() and "_mount" or ""

                if book.def ~= nil then
                    if book.def.fx_over_prefab ~= nil then
                        inst.sg.statemem.fx_over = SpawnPrefab(book.def.fx_over_prefab..suffix)
                        inst.sg.statemem.fx_over.entity:SetParent(inst.entity)
                        inst.sg.statemem.fx_over.Follower:FollowSymbol(inst.GUID, "swap_book_fx_over", 0, 0, 0, true)
                        inst.sg.statemem.fx_over.AnimState:SetFrame(frameskip)
                    end
                    if book.def.fx_under_prefab ~= nil then
                        inst.sg.statemem.fx_under = SpawnPrefab(book.def.fx_under_prefab..suffix)
                        inst.sg.statemem.fx_under.entity:SetParent(inst.entity)
                        inst.sg.statemem.fx_under.Follower:FollowSymbol(inst.GUID, "swap_book_fx_under", 0, 0, 0, true)
                        inst.sg.statemem.fx_under.AnimState:SetFrame(frameskip)
                    end

                    if book.def.layer_sound ~= nil then
                        --track and manage via soundtask and sound name (even though it is not a loop)
                        --so we can handle interruptions to this state
                        local frame = book.def.layer_sound.frame or 0
                        if frame > 0 then
                            inst.sg.statemem.soundtask = inst:DoTaskInTime((frame - frameskip) * FRAMES, function(inst)
                                inst.sg.statemem.soundtask = nil
                                inst.SoundEmitter:KillSound("book_layer_sound")
                                inst.SoundEmitter:PlaySound(book.def.layer_sound.sound, "book_layer_sound")
                            end)
                        else
                            inst.SoundEmitter:KillSound("book_layer_sound")
                            inst.SoundEmitter:PlaySound(book.def.layer_sound.sound, "book_layer_sound")
                        end
                    end
                end

                if book:HasTag("shadowmagic") then
                    inst.sg.statemem.fx_shadow = SpawnPrefab("waxwell_shadow_book_fx"..suffix)
                    inst.sg.statemem.fx_shadow.entity:SetParent(inst.entity)
                    inst.sg.statemem.fx_shadow.AnimState:SetFrame(frameskip)
                end

                local swap_build = book.swap_build
                local swap_prefix = book.swap_prefix or "book"
                local skin_build = book:GetSkinBuild()
                if skin_build ~= nil then
                    inst.AnimState:OverrideItemSkinSymbol("book_open", skin_build, "book_open", book.GUID, swap_build or "player_actions_uniqueitem", swap_prefix.."_open")
                    inst.AnimState:OverrideItemSkinSymbol("book_closed", skin_build, "book_closed", book.GUID, swap_build or "player_actions_uniqueitem", swap_prefix.."_closed")
                    inst.sg.statemem.symbolsoverridden = true
                elseif swap_build ~= nil then
                    inst.AnimState:OverrideSymbol("book_open", swap_build, swap_prefix.."_open")
                    inst.AnimState:OverrideSymbol("book_closed", swap_build, swap_prefix.."_closed")
                    inst.sg.statemem.symbolsoverridden = true
                end

                if book.components.spellbook ~= nil and book.components.spellbook:HasSpellFn() then
                    --inst.sg:AddStateTag("busy")
                elseif book.components.aoetargeting ~= nil then
                    inst.sg.statemem.earlycast = true
                    inst.sg.statemem.canrepeatcast = book.components.aoetargeting:CanRepeatCast()
                    --inst.sg:AddStateTag("busy")
                end
            end

            inst.sg.statemem.castsound = book ~= nil and book.castsound or "dontstarve/common/book_spell"
        end,

        timeline =
        {
            --
            TimeEvent(13 * FRAMES, function(inst)
                local function fn19()
                    inst.SoundEmitter:PlaySound("dontstarve/common/use_book_light")

                    if inst.sg.statemem.earlycast then
                        if inst.sg.statemem.fx_shadow ~= nil then
                            if inst.sg.statemem.fx_shadow:IsValid() then
                                local x, y, z = inst.sg.statemem.fx_shadow.Transform:GetWorldPosition()
                                inst.sg.statemem.fx_shadow.entity:SetParent(nil)
                                inst.sg.statemem.fx_shadow.Transform:SetPosition(x, y, z)
                                inst.sg.statemem.fx_shadow.Transform:SetRotation(inst.Transform:GetRotation())
                            end
                            inst.sg.statemem.fx_shadow = nil --Don't cancel anymore
                        end
                        inst.SoundEmitter:PlaySound(inst.sg.statemem.castsound)
                        if not inst:PerformBufferedAction() then
                            inst.sg.statemem.canrepeatcast = false
                            inst:RemoveTag("canrepeatcast")
                        end
                    end
                end
                if inst.sg.statemem.repeatcast then
                    fn19()
                else
                    inst.sg.statemem.fn19 = fn19
                end
            end),
            TimeEvent(19 * FRAMES, function(inst)
                if inst.sg.statemem.fn19 ~= nil then
                    inst.sg.statemem.fn19()
                    inst.sg.statemem.fn19 = nil
                end
            end),
            --
            TimeEvent(18 * FRAMES, function(inst)
                if inst.sg.statemem.repeatcast and inst.sg.statemem.canrepeatcast then
                    inst:AddTag("canrepeatcast")
                end
            end),
            TimeEvent(24 * FRAMES, function(inst)
                if not inst.sg.statemem.repeatcast and inst.sg.statemem.canrepeatcast then
                    inst:AddTag("canrepeatcast")
                end
            end),
            --
            TimeEvent(24 * FRAMES, function(inst)
                local function fn30()
                    if inst.sg.statemem.fx_shadow ~= nil then
                        if inst.sg.statemem.fx_shadow:IsValid() then
                            local x, y, z = inst.sg.statemem.fx_shadow.Transform:GetWorldPosition()
                            inst.sg.statemem.fx_shadow.entity:SetParent(nil)
                            inst.sg.statemem.fx_shadow.Transform:SetPosition(x, y, z)
                            inst.sg.statemem.fx_shadow.Transform:SetRotation(inst.Transform:GetRotation())
                        end
                        inst.sg.statemem.fx_shadow = nil --Don't cancel anymore
                    end
                end
                if inst.sg.statemem.repeatcast then
                    fn30()
                else
                    inst.sg.statemem.fn30 = fn30
                end
            end),
            TimeEvent(30 * FRAMES, function(inst)
                if inst.sg.statemem.fn30 ~= nil then
                    inst.sg.statemem.fn30()
                    inst.sg.statemem.fn30 = nil
                end
            end),
            --
            TimeEvent(44 * FRAMES, function(inst)
                local function fn50()
                    if inst.sg.statemem.targetfx ~= nil then
                        if inst.sg.statemem.targetfx:IsValid() then
                            OnRemoveCleanupTargetFX(inst)
                        end
                        inst.sg.statemem.targetfx = nil
                    end

                    local book_fx = inst.sg.statemem.book_fx
                    if book_fx ~= nil then
                        if book_fx:IsValid() then
                            local x, y, z = book_fx.Transform:GetWorldPosition()
                            book_fx.entity:SetParent(nil)
                            book_fx.Transform:SetPosition(x, y, z)
                            book_fx.Transform:SetRotation(inst.Transform:GetRotation())
                        else
                            book_fx = nil
                        end
                        inst.sg.statemem.book_fx = nil --Don't cancel anymore
                    end

                    if not inst.sg.statemem.earlycast then
                        inst.SoundEmitter:PlaySound(inst.sg.statemem.castsound)
                        inst.sg:RemoveStateTag("busy")
                        if not inst:PerformBufferedAction() then
                            if book_fx ~= nil then
                                book_fx:PushEvent("fail_fx", inst)
                            end
                            inst.sg.statemem.canrepeatcast = false
                            inst:RemoveTag("canrepeatcast")
                        end
                    end
                end
                if inst.sg.statemem.repeatcast then
                    fn50()
                else
                    inst.sg.statemem.fn50 = fn50
                end
            end),
            TimeEvent(50 * FRAMES, function(inst)
                if inst.sg.statemem.fn50 ~= nil then
                    inst.sg.statemem.fn50()
                    inst.sg.statemem.fn50 = nil
                end
            end),
            --
            TimeEvent(45 * FRAMES, function(inst)
                if inst.sg.statemem.repeatcast then
                    inst.SoundEmitter:PlaySound("dontstarve/common/use_book_close")
                end
            end),
            TimeEvent(51 * FRAMES, function(inst)
                if not inst.sg.statemem.repeatcast then
                    inst.SoundEmitter:PlaySound("dontstarve/common/use_book_close")
                end
            end),
            --
            TimeEvent(46 * FRAMES, function(inst)
                if inst.sg.statemem.repeatcast then
                    inst.sg:RemoveStateTag("busy")
                    inst:RemoveTag("canrepeatcast")
                end
            end),
            TimeEvent(52 * FRAMES, function(inst)
                if not inst.sg.statemem.repeatcast then
                    inst.sg:RemoveStateTag("busy")
                    inst:RemoveTag("canrepeatcast")
                end
            end),
            --
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.symbolsoverridden then
                inst.AnimState:OverrideSymbol("book_open", "player_actions_uniqueitem", "book_open")
                inst.AnimState:OverrideSymbol("book_closed", "player_actions_uniqueitem", "book_closed")
            end
            if inst.sg.statemem.book_fx ~= nil and inst.sg.statemem.book_fx:IsValid() then
                inst.sg.statemem.book_fx:Remove()
            end
            if inst.sg.statemem.fx_shadow ~= nil and inst.sg.statemem.fx_shadow:IsValid() then
                inst.sg.statemem.fx_shadow:Remove()
            end
            if inst.sg.statemem.fx_over ~= nil and inst.sg.statemem.fx_over:IsValid() then
                inst.sg.statemem.fx_over:Remove()
            end
            if inst.sg.statemem.fx_under ~= nil and inst.sg.statemem.fx_under:IsValid() then
                inst.sg.statemem.fx_under:Remove()
            end
            if inst.sg.statemem.targetfx ~= nil and inst.sg.statemem.targetfx:IsValid() then
                OnRemoveCleanupTargetFX(inst)
            end
            if inst.sg.statemem.soundtask ~= nil then
                inst.sg.statemem.soundtask:Cancel()
            elseif inst.SoundEmitter:PlayingSound("book_layer_sound") then
                inst.SoundEmitter:SetVolume("book_layer_sound", .5)
            end
            inst:RemoveTag("canrepeatcast")
        end,
    },

    State{
        name = "play_strum",
        tags = { "doing", "busy", "playing", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("strum_pre")
            inst.AnimState:PushAnimation("strum", false)

            inst.AnimState:OverrideSymbol("swap_trident", "swap_trident", "swap_trident")
        end,

        timeline =
        {
            TimeEvent(23 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/characters/trident_attack") end),
            TimeEvent(28 * FRAMES, function(inst)
                local instrument = inst.bufferedaction ~= nil and inst.bufferedaction.invobject or nil
                if instrument ~= nil and instrument.playsound ~= nil then
                    inst.SoundEmitter:PlaySound(instrument.playsound)
                end
                if not inst:PerformBufferedAction() then
                    inst.sg.statemem.action_failed = true
                end
            end),
            TimeEvent(30 * FRAMES, function(inst)
                if inst.sg.statemem.action_failed then
                    inst.AnimState:SetFrame(41)
                end
            end),
            TimeEvent(32 * FRAMES, function(inst)
                if inst.sg.statemem.action_failed then
                    inst.sg:RemoveStateTag("busy")
                end
            end),
            TimeEvent(41 * FRAMES, function(inst)
                if not inst.sg.statemem.action_failed then
                    inst.sg:RemoveStateTag("busy")
                end
            end),
        },

        events =
        {
            EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "attack_pillow_pre",
        tags = { "doing", "busy", "notalking" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("atk_pillow_pre")
            inst.AnimState:PushAnimation("atk_pillow_hold", true)

            local buffaction = inst:GetBufferedAction()
            if buffaction and buffaction.target and buffaction.target:IsValid() then
                inst:ForceFacePoint(buffaction.target.Transform:GetWorldPosition())
            end

            local pillow = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            inst.sg:SetTimeout((pillow and pillow._laglength) or 1.0)
        end,

        events =
        {
            EventHandler("unequip", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("attack_pillow")
        end,
    },

    State{
        name = "attack_pillow",
        tags = { "doing", "busy", "notalking", "pausepredict" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("atk_pillow")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
        end,
        timeline =
        {
            TimeEvent(FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
            TimeEvent(13 * FRAMES, function(inst)
                inst.sg:GoToState("idle", true)
            end),
        },

        events =
        {
            EventHandler("unequip", function(inst)
                inst.sg:GoToState("idle")
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "attack_prop_pre",
        tags = { "propattack", "doing", "busy", "notalking" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("atk_prop_pre")

            local buffaction = inst:GetBufferedAction()
            local target = buffaction ~= nil and buffaction.target or nil
            if target ~= nil and target:IsValid() then
                inst:ForceFacePoint(target.Transform:GetWorldPosition())
            end
        end,

        events =
        {
            EventHandler("unequip", function(inst)
                inst.sg:GoToState("idle")
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("attack_prop")
                end
            end),
        },
    },

    State{
        name = "attack_prop",
        tags = { "propattack", "doing", "busy", "notalking", "pausepredict" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("atk_prop")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
        end,
        timeline =
        {
            TimeEvent(FRAMES, function(inst)
                inst:PerformBufferedAction()
                local dist = .8
                local radius = 1.7
                inst.components.combat.ignorehitrange = true
                local x0, y0, z0 = inst.Transform:GetWorldPosition()
                local angle = (inst.Transform:GetRotation() + 90) * DEGREES
                local sinangle = math.sin(angle)
                local cosangle = math.cos(angle)
                local x = x0 + dist * sinangle
                local z = z0 + dist * cosangle
                for i, v in ipairs(TheSim:FindEntities(x, y0, z, radius + 3, ATTACK_PROP_MUST_TAGS, ATTACK_PROP_CANT_TAGS)) do
                    if v:IsValid() and not v:IsInLimbo() and
                        not (v.components.health ~= nil and v.components.health:IsDead()) then
                        local range = radius + v:GetPhysicsRadius(.5)
                        if v:GetDistanceSqToPoint(x, y0, z) < range * range and inst.components.combat:CanTarget(v) then
                            --dummy redirected so that players don't get red blood flash
                            v:PushEvent("attacked", { attacker = inst, damage = 0, redirected = v })
                            v:PushEvent("knockback", { knocker = inst, radius = radius + dist, propsmashed = true })
                            inst.sg.statemem.smashed = true
                        end
                    end
                end
                inst.components.combat.ignorehitrange = false
                if inst.sg.statemem.smashed then
                    local prop = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                    if prop ~= nil then
                        dist = dist + radius - .5
                        inst.sg.statemem.smashed = { prop = prop, pos = Vector3(x0 + dist * sinangle, y0, z0 + dist * cosangle) }
                    else
                        inst.sg.statemem.smashed = nil
                    end
                end
            end),
            TimeEvent(2 * FRAMES, function(inst)
                if inst.sg.statemem.smashed ~= nil then
                    local smashed = inst.sg.statemem.smashed
                    inst.sg.statemem.smashed = false
                    smashed.prop:PushEvent("propsmashed", smashed.pos)
                end
            end),
            TimeEvent(13 * FRAMES, function(inst)
                inst.sg:GoToState("idle", true)
            end),
        },

        events =
        {
            EventHandler("unequip", function(inst)
                if inst.sg.statemem.smashed == nil then
                    inst.sg:GoToState("idle")
                end
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.smashed then --could be false, so don't nil check
                inst.sg.statemem.smashed.prop:PushEvent("propsmashed", inst.sg.statemem.smashed.pos)
            end
        end,
    },

    State{
        name = "use_fan",
        tags = { "doing" },

        onenter = function(inst)
            local invobject = nil
            if inst.bufferedaction ~= nil then
                invobject = inst.bufferedaction.invobject
                if invobject ~= nil and invobject.components.fan ~= nil and invobject.components.fan:IsChanneling() then
                    inst.sg.statemem.item = invobject
                    inst.sg.statemem.target = inst.bufferedaction.target or inst.bufferedaction.doer
                    inst.sg:AddStateTag("busy")
                end
            end
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("action_uniqueitem_pre")
            inst.AnimState:PushAnimation("fan", false)
            local skin_build = invobject:GetSkinBuild()
            local src_symbol = invobject ~= nil and invobject.components.fan ~= nil and invobject.components.fan.overridesymbol or "swap_fan"
            if skin_build ~= nil then
                inst.AnimState:OverrideItemSkinSymbol( "fan01", skin_build, src_symbol, invobject.GUID, "fan" )
            else
                inst.AnimState:OverrideSymbol( "fan01", "fan", src_symbol )
            end
            inst.components.inventory:ReturnActiveActionItem(invobject)
        end,

        timeline =
        {
            TimeEvent(30 * FRAMES, function(inst)
                if inst.sg.statemem.item ~= nil and
                    inst.sg.statemem.item:IsValid() and
                    inst.sg.statemem.item.components.fan ~= nil then
                    inst.sg.statemem.item.components.fan:Channel(inst.sg.statemem.target ~= nil and inst.sg.statemem.target:IsValid() and inst.sg.statemem.target or inst)
                end
            end),
            TimeEvent(50 * FRAMES, function(inst)
                if inst.sg.statemem.item ~= nil and
                    inst.sg.statemem.item:IsValid() and
                    inst.sg.statemem.item.components.fan ~= nil then
                    inst.sg.statemem.item.components.fan:Channel(inst.sg.statemem.target ~= nil and inst.sg.statemem.target:IsValid() and inst.sg.statemem.target or inst)
                end
            end),
            TimeEvent(70 * FRAMES, function(inst)
                if inst.sg.statemem.item ~= nil then
                    inst.sg:RemoveStateTag("busy")
                end
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
        name = "repelled",
        tags = { "busy", "nopredict", "nomorph" },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            --V2C: in case mount or woodie's were-transforms have shorter hit anims
            local stun_frames = 9
            inst.AnimState:PlayAnimation("distress_pre")
            inst.AnimState:PushAnimation("distress_pst", false)

            DoHurtSound(inst)

            if data ~= nil then
                if data.knocker ~= nil then
                    inst.sg:AddStateTag("nointerrupt")
                end
                if data.radius ~= nil and data.repeller ~= nil and data.repeller:IsValid() then
                    local x, y, z = data.repeller.Transform:GetWorldPosition()
                    local distsq = inst:GetDistanceSqToPoint(x, y, z)
                    local rangesq = data.radius * data.radius
                    if distsq < rangesq then
                        if distsq > 0 then
                            inst:ForceFacePoint(x, y, z)
                        end
                        local k = .5 * distsq / rangesq - 1
                        inst.sg.statemem.speed = (data.strengthmult or 1) * 25 * k
                        inst.sg.statemem.dspeed = 2
                        inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
                    end
                end
            end

            inst.sg:SetTimeout(stun_frames * FRAMES)
        end,

        onupdate = function(inst)
            if inst.sg.statemem.speed ~= nil then
                inst.sg.statemem.speed = inst.sg.statemem.speed + inst.sg.statemem.dspeed
                if inst.sg.statemem.speed < 0 then
                    inst.sg.statemem.dspeed = inst.sg.statemem.dspeed + .25
                    inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
                else
                    inst.sg.statemem.speed = nil
                    inst.sg.statemem.dspeed = nil
                    inst.Physics:Stop()
                end
            end
        end,

        timeline =
        {
            FrameEvent(4, function(inst)
                inst.sg:RemoveStateTag("nointerrupt")
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            if inst.sg.statemem.speed ~= nil then
                inst.Physics:Stop()
            end
        end,
    },

    State{
        name = "castspellmind",
        tags = { "doing", "busy", "canrotate" },

        onenter = function(inst)
            inst.SoundEmitter:PlaySound("meta3/willow/pyrokinetic_activate")

            inst.AnimState:PlayAnimation("pyrocast_pre")
            inst.AnimState:PushAnimation("pyrocast", false)
            inst.components.locomotor:Stop()
        end,

        timeline =
        {
            TimeEvent(15 * FRAMES, function(inst)
                if inst:PerformBufferedAction() then
                    inst.sg:GoToState("idle")
                end
            end),
            TimeEvent(20 * FRAMES, function(inst)
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
    },

    State{
        name = "combat_lunge_start",
        tags = { "aoe", "doing", "busy", "nointerrupt", "nomorph" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("lunge_pre")
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/twirl", nil, nil, true)
            end),
        },

        events =
        {
            EventHandler("combat_lunge", function(inst, data)
                inst.sg:GoToState("combat_lunge", data)
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.AnimState:IsCurrentAnimation("lunge_pre") then
                        inst.AnimState:PlayAnimation("lunge_lag")
                        inst:PerformBufferedAction()
                    else
                        inst.sg:GoToState("idle")
                    end
                end
            end),
        },
    },

    State{
        name = "combat_lunge",
        tags = { "aoe", "doing", "busy", "nopredict", "nomorph" },

        onenter = function(inst, data)
            if data ~= nil and
                data.targetpos ~= nil and
                data.weapon ~= nil and
                data.weapon.components.aoeweapon_lunge ~= nil and
                inst.AnimState:IsCurrentAnimation("lunge_lag") then
                inst.AnimState:PlayAnimation("lunge_pst")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
                local pos = inst:GetPosition()
                local dir
                if pos.x ~= data.targetpos.x or pos.z ~= data.targetpos.z then
                    dir = inst:GetAngleToPoint(data.targetpos)
                    inst.Transform:SetRotation(dir)
                end
                if data.weapon.components.aoeweapon_lunge:DoLunge(inst, pos, data.targetpos) then
                    inst.SoundEmitter:PlaySound(data.weapon.components.aoeweapon_lunge.sound or "dontstarve/common/lava_arena/fireball")

                    --Make sure we don't land directly on world boundary, where
                    --physics may end up popping in the wrong direction to void
                    local x, z = data.targetpos.x, data.targetpos.z
                    if dir then
                        local theta = dir * DEGREES
                        local cos_theta = math.cos(theta)
                        local sin_theta = math.sin(theta)
                        local x1, z1
                        local map = TheWorld.Map
                        if not map:IsPassableAtPoint(x, 0, z) then
                            --scan for nearby land in case we were slightly off
                            --adjust position slightly toward valid ground
                            if map:IsPassableAtPoint(x + 0.1 * cos_theta, 0, z - 0.1 * sin_theta) then
                                x1 = x + 0.5 * cos_theta
                                z1 = z - 0.5 * sin_theta
                            elseif map:IsPassableAtPoint(x - 0.1 * cos_theta, 0, z + 0.1 * sin_theta) then
                                x1 = x - 0.5 * cos_theta
                                z1 = z + 0.5 * sin_theta
                            end
                        else
                            --scan to make sure we're not just on the edge of land, could result in popping to the wrong side
                            --adjust position slightly away from invalid ground
                            if not map:IsPassableAtPoint(x + 0.1 * cos_theta, 0, z - 0.1 * sin_theta) then
                                x1 = x - 0.4 * cos_theta
                                z1 = z + 0.4 * sin_theta
                            elseif not map:IsPassableAtPoint(x - 0.1 * cos_theta, 0, z + 0.1 * sin_theta) then
                                x1 = x + 0.4 * cos_theta
                                z1 = z - 0.4 * sin_theta
                            end
                        end

                        if x1 and map:IsPassableAtPoint(x1, 0, z1) then
                            x, z = x1, z1
                        end
                    end

                    --V2C: -physics doesn't resolve correctly if we teleport from
                    --      one point colliding with world to another point still
                    --      colliding with world.
                    --     -#HACK use mass change to force physics refresh.
                    local mass = inst.Physics:GetMass()
                    if mass > 0 then
                        inst.sg.statemem.restoremass = mass
                        inst.Physics:SetMass(mass + 1)
                    end
                    inst.Physics:Teleport(x, 0, z)

                    -- aoeweapon_lunge:DoLunge can get us out of the state!
                    -- And then, if onexit is run before this: bugs!
                    if not data.skipflash and inst.sg.currentstate == "combat_lunge" then
                        inst.components.bloomer:PushBloom("lunge", "shaders/anim.ksh", -2)
                        inst.components.colouradder:PushColour("lunge", 1, 1, 0, 0)
                        inst.sg.statemem.flash = 1
                    end
                    return
                end
            end
            --Failed
            inst.sg:GoToState("idle", true)
        end,

        onupdate = function(inst)
            if inst.sg.statemem.flash and inst.sg.statemem.flash > 0 then
                inst.sg.statemem.flash = math.max(0, inst.sg.statemem.flash - .1)
                inst.components.colouradder:PushColour("lunge", inst.sg.statemem.flash, inst.sg.statemem.flash, 0, 0)
            end
        end,

        timeline =
        {
            FrameEvent(8, function(inst)
                if inst.sg.statemem.restoremass ~= nil then
                    inst.Physics:SetMass(inst.sg.statemem.restoremass)
                    inst.sg.statemem.restoremass = nil
                end
            end),
            TimeEvent(12 * FRAMES, function(inst)
                inst.components.bloomer:PopBloom("lunge")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.restoremass ~= nil then
                inst.Physics:SetMass(inst.sg.statemem.restoremass)
            end
            inst.components.bloomer:PopBloom("lunge")
            inst.components.colouradder:PopColour("lunge")
        end,
    },

    State{
        name = "combat_superjump_start",
        tags = { "aoe", "doing", "busy", "nointerrupt", "nomorph" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("superjump_pre")

            local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if weapon ~= nil and weapon.components.aoetargeting ~= nil then
                local buffaction = inst:GetBufferedAction()
                if buffaction ~= nil then
                    inst.sg.statemem.targetfx = weapon.components.aoetargeting:SpawnTargetFXAt(buffaction:GetDynamicActionPoint())
                    if inst.sg.statemem.targetfx ~= nil then
                        inst.sg.statemem.targetfx:ListenForEvent("onremove", OnRemoveCleanupTargetFX, inst)
                    end
                end
            end
        end,

        events =
        {
            EventHandler("combat_superjump", function(inst, data)
                inst.sg.statemem.superjump = true
                inst.sg:GoToState("combat_superjump", {
                    targetfx = inst.sg.statemem.targetfx,
                    data = data,
                })
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.AnimState:IsCurrentAnimation("superjump_pre") then
                        inst.AnimState:PlayAnimation("superjump_lag")
                        inst:PerformBufferedAction()
                    else
                        inst.sg:GoToState("idle")
                    end
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.superjump and inst.sg.statemem.targetfx ~= nil and inst.sg.statemem.targetfx:IsValid() then
                OnRemoveCleanupTargetFX(inst)
            end
        end,
    },

    State{
        name = "combat_superjump",
        tags = { "aoe", "doing", "busy", "nointerrupt", "nopredict", "nomorph" },

        onenter = function(inst, data)
            if data ~= nil then
                inst.sg.statemem.targetfx = data.targetfx
                inst.sg.statemem.data = data
                data = data.data
                if data ~= nil and
                    data.targetpos ~= nil and
                    data.weapon ~= nil and
                    data.weapon.components.aoeweapon_leap ~= nil and
                    inst.AnimState:IsCurrentAnimation("superjump_lag") then
                    ToggleOffPhysics(inst)
                    inst.AnimState:PlayAnimation("superjump")
                    inst.AnimState:SetMultColour(.8, .8, .8, 1)
                    inst.components.colouradder:PushColour("superjump", .1, .1, .1, 0)
                    inst.sg.statemem.data.startingpos = inst:GetPosition()
                    inst.sg.statemem.weapon = data.weapon
                    if inst.sg.statemem.data.startingpos.x ~= data.targetpos.x or inst.sg.statemem.data.startingpos.z ~= data.targetpos.z then
                        inst:ForceFacePoint(data.targetpos:Get())
                    end
                    inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt", nil, .4)
                    inst.SoundEmitter:PlaySound("dontstarve/common/deathpoof")
                    inst.sg:SetTimeout(1)
                    return
                end
            end
            --Failed
            inst.sg:GoToState("idle", true)
        end,

        onupdate = function(inst)
            if inst.sg.statemem.dalpha ~= nil and inst.sg.statemem.alpha > 0 then
                inst.sg.statemem.dalpha = math.max(.1, inst.sg.statemem.dalpha - .1)
                inst.sg.statemem.alpha = math.max(0, inst.sg.statemem.alpha - inst.sg.statemem.dalpha)
                inst.AnimState:SetMultColour(0, 0, 0, inst.sg.statemem.alpha)
            end
        end,

        timeline =
        {
            TimeEvent(FRAMES, function(inst)
                inst.DynamicShadow:Enable(false)
                inst.sg:AddStateTag("noattack")
                inst.components.health:SetInvincible(true)
                inst.AnimState:SetMultColour(.5, .5, .5, 1)
                inst.components.colouradder:PushColour("superjump", .3, .3, .2, 0)
                inst:PushEvent("dropallaggro")
                if inst.sg.statemem.weapon ~= nil and inst.sg.statemem.weapon:IsValid() then
                    inst.sg.statemem.weapon:PushEvent("superjumpstarted", inst)
                end
            end),
            TimeEvent(2 * FRAMES, function(inst)
                inst.AnimState:SetMultColour(0, 0, 0, 1)
                inst.components.colouradder:PushColour("superjump", .6, .6, .4, 0)
            end),
            TimeEvent(3 * FRAMES, function(inst)
                inst.sg.statemem.alpha = 1
                inst.sg.statemem.dalpha = .5
            end),
            TimeEvent(1 - 7 * FRAMES, function(inst)
                if inst.sg.statemem.targetfx ~= nil then
                    if inst.sg.statemem.targetfx:IsValid() then
                        OnRemoveCleanupTargetFX(inst)
                    end
                    inst.sg.statemem.targetfx = nil
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst:Hide()
                    inst.Physics:Teleport(inst.sg.statemem.data.data.targetpos.x, 0, inst.sg.statemem.data.data.targetpos.z)
                end
            end),
        },

        ontimeout = function(inst)
            inst.sg.statemem.superjump = true
            inst.sg.statemem.data.isphysicstoggle = inst.sg.statemem.data.isphysicstoggle
            inst.sg.statemem.data.targetfx = nil
            inst.sg:GoToState("combat_superjump_pst", inst.sg.statemem.data)
        end,

        onexit = function(inst)
            if not inst.sg.statemem.superjump then
                inst.components.health:SetInvincible(false)
                if inst.sg.statemem.isphysicstoggle then
                    ToggleOnPhysics(inst)
                end
                inst.components.colouradder:PopColour("superjump")
                inst.AnimState:SetMultColour(1, 1, 1, 1)
                inst.DynamicShadow:Enable(true)
                if inst.sg.statemem.weapon ~= nil and inst.sg.statemem.weapon:IsValid() then
                    inst.sg.statemem.weapon:PushEvent("superjumpcancelled", inst)
                end
            end
            if inst.sg.statemem.targetfx ~= nil and inst.sg.statemem.targetfx:IsValid() then
                OnRemoveCleanupTargetFX(inst)
            end
            inst:Show()
        end,
    },

    State{
        name = "combat_superjump_pst",
        tags = { "aoe", "doing", "busy", "noattack", "nopredict", "nomorph" },

        onenter = function(inst, data)
            if data ~= nil and data.data ~= nil then
                inst.sg.statemem.startingpos = data.startingpos
                inst.sg.statemem.isphysicstoggle = data.isphysicstoggle
                data = data.data
                inst.sg.statemem.weapon = data.weapon
                if inst.sg.statemem.startingpos ~= nil and
                    data.targetpos ~= nil and
                    data.weapon ~= nil and
                    data.weapon.components.aoeweapon_leap ~= nil and
                    inst.AnimState:IsCurrentAnimation("superjump") then
                    inst.AnimState:PlayAnimation("superjump_land")
                    inst.AnimState:SetMultColour(1, 1, 1, .4)
                    inst.sg.statemem.targetpos = data.targetpos
                    if not data.skipflash then
                        inst.sg.statemem.flash = 0
                    end
                    if not inst.sg.statemem.isphysicstoggle then
                        ToggleOffPhysics(inst)
                    end
                    inst.Physics:Teleport(data.targetpos.x, 0, data.targetpos.z)
                    inst.components.health:SetInvincible(true)
                    inst.sg:SetTimeout(22 * FRAMES)
                    return
                end
            end
            --Failed
            inst.sg:GoToState("idle", true)
        end,

        onupdate = function(inst)
            if inst.sg.statemem.flash and inst.sg.statemem.flash > 0 then
                inst.sg.statemem.flash = math.max(0, inst.sg.statemem.flash - .1)
                local c = math.min(1, inst.sg.statemem.flash)
                inst.components.colouradder:PushColour("superjump", c, c, 0, 0)
            end
        end,

        timeline =
        {
            TimeEvent(FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
                inst.AnimState:SetMultColour(1, 1, 1, .7)
                inst.components.colouradder:PushColour("superjump", .1, .1, 0, 0)
            end),
            TimeEvent(2 * FRAMES, function(inst)
                inst.AnimState:SetMultColour(1, 1, 1, .9)
                inst.components.colouradder:PushColour("superjump", .2, .2, 0, 0)
            end),
            TimeEvent(3 * FRAMES, function(inst)
                inst.AnimState:SetMultColour(1, 1, 1, 1)
                inst.components.colouradder:PushColour("superjump", .4, .4, 0, 0)
                inst.DynamicShadow:Enable(true)
            end),
            TimeEvent(4 * FRAMES, function(inst)
                inst.components.colouradder:PushColour("superjump", 1, 1, 0, 0)
                inst.components.bloomer:PushBloom("superjump", "shaders/anim.ksh", -2)
                ToggleOnPhysics(inst)
                ShakeAllCameras(CAMERASHAKE.VERTICAL, .7, .015, .8, inst, 20)
                if inst.sg.statemem.flash then
                    inst.sg.statemem.flash = 1.3
                end
                inst.sg:RemoveStateTag("noattack")
                inst.components.health:SetInvincible(false)
                if inst.sg.statemem.weapon:IsValid() then
                    if inst.sg.statemem.weapon.components.aoeweapon_leap ~= nil then
                        inst.sg.statemem.weapon.components.aoeweapon_leap:DoLeap(inst, inst.sg.statemem.startingpos, inst.sg.statemem.targetpos)
                        inst.sg.statemem.weapon = nil
                    end
                end
            end),
            TimeEvent(8 * FRAMES, function(inst)
                inst.components.bloomer:PopBloom("superjump")
            end),
            TimeEvent(19 * FRAMES, PlayFootstep),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.isphysicstoggle then
                ToggleOnPhysics(inst)
            end
            inst.AnimState:SetMultColour(1, 1, 1, 1)
            inst.DynamicShadow:Enable(true)
            inst.components.health:SetInvincible(false)
            inst.components.bloomer:PopBloom("superjump")
            inst.components.colouradder:PopColour("superjump")
            if inst.sg.statemem.weapon ~= nil and inst.sg.statemem.weapon:IsValid() then
                inst.sg.statemem.weapon:PushEvent("superjumpcancelled", inst)
            end
        end,
    },

    State{
        name = "emote",
        tags = { "busy", "pausepredict" },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()

            local dancedata = nil
            if data.tags ~= nil then
                for i, v in ipairs(data.tags) do
                    inst.sg:AddStateTag(v)
                    if v == "dancing" then
                        dancedata = dancedata or {}
                        TheWorld:PushEvent("dancingplayer", inst)
                        local hat = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
                        if hat ~= nil and hat.OnStartDancing ~= nil then
                            local newdata = hat:OnStartDancing(inst, data)
                            if newdata ~= nil then
                                inst.sg.statemem.dancinghat = hat
                                data = newdata
                            end
                        end
                    end
                end
                if inst.sg.statemem.dancinghat ~= nil and data.tags ~= nil then
                    for i, v in ipairs(data.tags) do
                        if not inst.sg:HasStateTag(v) then
                            inst.sg:AddStateTag(v)
                        end
                    end
                end
            end

            local anim = data.anim
            local animtype = type(anim)
            if data.randomanim and animtype == "table" then
                anim = anim[math.random(#anim)]
                animtype = type(anim)
            end
            if animtype == "table" and #anim <= 1 then
                anim = anim[1]
                animtype = type(anim)
            end

            if animtype == "string" then
                inst.AnimState:PlayAnimation(anim, data.loop)
                if dancedata ~= nil then
                    table.insert(dancedata, {play = true, anim = anim, loop = data.loop,})
                end
            elseif animtype == "table" then
                local maxanim = #anim
                -- NOTES(JBK): Keep these in sync with the data replication in `dancedata` below.
                inst.AnimState:PlayAnimation(anim[1])
                for i = 2, maxanim - 1 do
                    inst.AnimState:PushAnimation(anim[i])
                end
                inst.AnimState:PushAnimation(anim[maxanim], data.loop == true)

                if dancedata ~= nil then
                    table.insert(dancedata, {play = true, anim = anim[1]})
                    for i = 2, maxanim - 1 do
                        table.insert(dancedata, {anim = anim[i]})
                    end
                    table.insert(dancedata, {anim = anim[maxanim], loop = data.loop == true,})
                end
            end
            if dancedata ~= nil then
                TheWorld:PushEvent("dancingplayerdata", {inst = inst, dancedata = dancedata,})
            end

            if data.fx then --fx might be a boolean, so don't do ~= nil
                if data.fxdelay == nil or data.fxdelay == 0 then
                    DoEmoteFX(inst, data.fx)
                else
                    inst.sg.statemem.emotefxtask = inst:DoTaskInTime(data.fxdelay, DoEmoteFX, data.fx)
                end
            elseif data.fx ~= false then
                DoEmoteFX(inst, "emote_fx")
            end

            if data.sound then --sound might be a boolean, so don't do ~= nil
                if (data.sounddelay or 0) <= 0 then
                    inst.SoundEmitter:PlaySound(data.sound)
                else
                    inst.sg.statemem.emotesoundtask = inst:DoTaskInTime(data.sounddelay, DoForcedEmoteSound, data.sound)
                end
            elseif data.sound ~= false then
                if (data.sounddelay or 0) <= 0 then
                    DoEmoteSound(inst, data.soundoverride, data.soundlooped)
                else
                    inst.sg.statemem.emotesoundtask = inst:DoTaskInTime(data.sounddelay, DoEmoteSound, data.soundoverride, data.soundlooped)
                end
            end

            if data.mountsound ~= nil then
                local mount = inst.components.rider:GetMount()
                if mount ~= nil and mount.sounds ~= nil and mount.sounds[data.mountsound] ~= nil then
                    if (data.mountsoundperiod or 0) <= 0 then
                        if (data.mountsounddelay or 0) <= 0 then
                            inst.SoundEmitter:PlaySound(mount.sounds[data.mountsound])
                        else
                            inst.sg.statemem.emotemountsoundtask = inst:DoTaskInTime(data.mountsounddelay, DoForcedEmoteSound, mount.sounds[data.mountsound])
                        end
                    elseif (data.mountsounddelay or 0) <= 0 then
                        inst.sg.statemem.emotemountsoundtask = inst:DoPeriodicTask(data.mountsoundperiod, DoForcedEmoteSound, nil, mount.sounds[data.mountsound])
                        inst.SoundEmitter:PlaySound(mount.sounds[data.mountsound])
                    else
                        inst.sg.statemem.emotemountsoundtask = inst:DoPeriodicTask(data.mountsoundperiod, DoForcedEmoteSound, data.mountsounddelay, mount.sounds[data.mountsound])
                    end
                end
            end

            if data.mountsound2 ~= nil then
                local mount = inst.components.rider:GetMount()
                if mount ~= nil and mount.sounds ~= nil and mount.sounds[data.mountsound2] ~= nil then
                    if (data.mountsound2period or 0) <= 0 then
                        if (data.mountsound2delay or 0) <= 0 then
                            inst.SoundEmitter:PlaySound(mount.sounds[data.mountsound2])
                        else
                            inst.sg.statemem.emotemountsound2task = inst:DoTaskInTime(data.mountsound2delay, DoForcedEmoteSound, mount.sounds[data.mountsound2])
                        end
                    elseif (data.mountsound2delay or 0) <= 0 then
                        inst.sg.statemem.emotemountsound2task = inst:DoPeriodicTask(data.mountsound2period, DoForcedEmoteSound, nil, mount.sounds[data.mountsound2])
                        inst.SoundEmitter:PlaySound(mount.sounds[data.mountsound2])
                    else
                        inst.sg.statemem.emotemountsound2task = inst:DoPeriodicTask(data.mountsound2period, DoForcedEmoteSound, data.mountsound2delay, mount.sounds[data.mountsound2])
                    end
                end
            end

            if data.zoom ~= nil then
                inst.sg.statemem.iszoomed = true
                inst:SetCameraZoomed(true)
                inst:ShowHUD(false)
            end

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end
        end,

        timeline =
        {
            TimeEvent(.5, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("pausepredict")
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
            if inst.sg.statemem.emotefxtask ~= nil then
                inst.sg.statemem.emotefxtask:Cancel()
                inst.sg.statemem.emotefxtask = nil
            end
            if inst.sg.statemem.emotesoundtask ~= nil then
                inst.sg.statemem.emotesoundtask:Cancel()
                inst.sg.statemem.emotesoundtask = nil
            end
            if inst.sg.statemem.emotemountsoundtask ~= nil then
                inst.sg.statemem.emotemountsoundtask:Cancel()
                inst.sg.statemem.emotemountsoundtask = nil
            end
            if inst.sg.statemem.emotemountsound2task ~= nil then
                inst.sg.statemem.emotemountsound2task:Cancel()
                inst.sg.statemem.emotemountsound2task = nil
            end
            if inst.SoundEmitter:PlayingSound("emotesoundloop") then
                inst.SoundEmitter:KillSound("emotesoundloop")
            end
            if inst.sg.statemem.iszoomed then
                inst:SetCameraZoomed(false)
                inst:ShowHUD(true)
            end
            if inst.sg.statemem.dancinghat ~= nil and
                inst.sg.statemem.dancinghat == inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) and
                inst.sg.statemem.dancinghat.OnStopDancing ~= nil then
                inst.sg.statemem.dancinghat:OnStopDancing(inst)
            end

        end,
    },

    State{
        name = "frozen",
        tags = { "busy", "frozen", "nopredict", "nodangle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")
            inst.AnimState:PlayAnimation("frozen")
            inst.SoundEmitter:PlaySound("dontstarve/common/freezecreature")

            --V2C: cuz... freezable component and SG need to match state,
            --     but messages to SG are queued, so it is not great when
            --     when freezable component tries to change state several
            --     times within one frame...
            if inst.components.freezable == nil then
                inst.sg:GoToState("hit", true)
            elseif inst.components.freezable:IsThawing() then
                inst.sg:GoToState("thaw")
            elseif not inst.components.freezable:IsFrozen() then
                inst.sg:GoToState("hit", true)
            end
        end,

        events =
        {
            EventHandler("onthaw", function(inst)
                inst.sg:GoToState("thaw")
            end),
            EventHandler("unfreeze", function(inst)
                inst.sg:GoToState("hit", true)
            end),
        },

        onexit = function(inst)
            inst.AnimState:ClearOverrideSymbol("swap_frozen")
        end,
    },

    State{
        name = "thaw",
        tags = { "busy", "thawing", "nopredict", "nodangle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")
            inst.AnimState:PlayAnimation("frozen_loop_pst", true)
            inst.SoundEmitter:PlaySound("dontstarve/common/freezethaw", "thawing")
        end,

        events =
        {
            EventHandler("unfreeze", function(inst)
                inst.sg:GoToState("hit", true)
            end),
        },

        onexit = function(inst)
            inst.components.inventory:Show()
            inst.SoundEmitter:KillSound("thawing")
            inst.AnimState:ClearOverrideSymbol("swap_frozen")
        end,
    },

    State{
        name = "pinned_pre",
        tags = { "busy", "pinned", "nopredict" },

        onenter = function(inst)
            if inst.components.freezable ~= nil and inst.components.freezable:IsFrozen() then
                inst.components.freezable:Unfreeze()
            end

            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:OverrideSymbol("swap_goosplat", "goo", "swap_goosplat")
            inst.AnimState:PlayAnimation("hit")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("pinned")
                end
            end),
        },

        onexit = function(inst)
            inst.AnimState:ClearOverrideSymbol("swap_goosplat")
        end,
    },

    State{
        name = "pinned",
        tags = { "busy", "pinned", "nopredict" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:PlayAnimation("distress_loop", true)
            -- TODO: struggle sound
            inst.SoundEmitter:PlaySound("dontstarve/creatures/spat/spit_playerstruggle", "struggling")
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("struggling")
        end,
    },

    State{
        name = "chop_start",
        tags = { "prechop", "working" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("chop_pre")
            inst:AddTag("prechop")
        end,

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.chopping = true
                    inst.sg:GoToState("chop")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.chopping then
                inst:RemoveTag("prechop")
            end
        end,
    },

    State{
        name = "chop",
        tags = { "prechop", "chopping", "working" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("chop_loop")
            inst:AddTag("prechop")
        end,

        timeline =
        {
            TimeEvent(9 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("prechop")
                inst:RemoveTag("prechop")
            end),

            TimeEvent(16 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("chopping")
            end),
        },

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    --We don't have a chop_pst animation
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst:RemoveTag("prechop")
        end,
    },

    State{
        name = "mine_start",
        tags = { "premine", "working" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("pickaxe_pre")
            inst:AddTag("premine")
        end,

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.mining = true
                    inst.sg:GoToState("mine")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.mining then
                inst:RemoveTag("premine")
            end
        end,
    },

    State{
        name = "mine",
        tags = { "premine", "mining", "working" },

        onenter = function(inst)
            inst.sg.statemem.action = inst:GetBufferedAction()
            inst.AnimState:PlayAnimation("pickaxe_loop")
            inst:AddTag("premine")
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                if inst.sg.statemem.action ~= nil then
                    PlayMiningFX(inst, inst.sg.statemem.action.target)
                end
                inst.sg.statemem.recoilstate = "mine_recoil"
                inst:PerformBufferedAction()
            end),

            TimeEvent(9 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("premine")
                inst:RemoveTag("premine")
            end),
        },

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.AnimState:PlayAnimation("pickaxe_pst")
                    inst.sg:GoToState("idle", true)
                end
            end),
        },

        onexit = function(inst)
            inst:RemoveTag("premine")
        end,
    },

    State{
        name = "mine_recoil",
        tags = { "busy", "nopredict", "nomorph" },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("pickaxe_recoil")
            if data ~= nil and data.target ~= nil and data.target:IsValid() then
                SpawnPrefab("impact").Transform:SetPosition(data.target.Transform:GetWorldPosition())
            end
            inst.Physics:SetMotorVel(-6, 0, 0)
        end,

        onupdate = function(inst)
            if inst.sg.statemem.speed ~= nil then
                inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
                inst.sg.statemem.speed = inst.sg.statemem.speed * 0.75
            end
        end,

        timeline =
        {
            FrameEvent(4, function(inst)
                inst.sg.statemem.speed = -3
            end),
            FrameEvent(17, function(inst)
                inst.sg.statemem.speed = nil
                inst.Physics:Stop()
            end),
            FrameEvent(23, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nopredict")
                inst.sg:RemoveStateTag("nomorph")
            end),
            FrameEvent(30, function(inst)
                inst.sg:GoToState("idle", true)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.Physics:Stop()
        end,
    },

    State{
        name = "hammer_start",
        tags = { "prehammer", "working" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("pickaxe_pre")
            inst:AddTag("prehammer")
        end,

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.hammering = true
                    inst.sg:GoToState("hammer")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.hammering then
                inst:RemoveTag("prehammer")
            end
        end,
    },

    State{
        name = "hammer",
        tags = { "prehammer", "hammering", "working" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("pickaxe_loop")
            inst:AddTag("prehammer")
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")
                inst.sg.statemem.recoilstate = "mine_recoil"
                inst:PerformBufferedAction()
            end),

            TimeEvent(9 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("prehammer")
                inst:RemoveTag("prehammer")
            end),
        },

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.AnimState:PlayAnimation("pickaxe_pst")
                    inst.sg:GoToState("idle", true)
                end
            end),
        },

        onexit = function(inst)
            inst:RemoveTag("prehammer")
        end,
    },

    State{
        name = "wes_funnyidle",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            local balloon_color = {
                "blue",
                "green",
                "orange",
                "red",
                "purple",
                "yellow"
            }
            inst.AnimState:OverrideSymbol("balloon_red", "player_idles_wes", "balloon_" .. balloon_color[math.random(1, #balloon_color)])

            inst.AnimState:PlayAnimation("idle_wes")
        end,

        timeline =
        {
            TimeEvent(9 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("wes/characters/wes/breath_idle")
            end),
            TimeEvent(26 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("wes/characters/wes/blow_idle")
            end),
            TimeEvent(42 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("wes/characters/wes/breath_idle")
            end),
            TimeEvent(58 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("wes/characters/wes/blow_idle")
            end),
            TimeEvent(73 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("wes/characters/wes/pop_idle")
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
        name = "till_start",
        tags = { "doing", "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
			local equippedTool = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
			if equippedTool ~= nil and equippedTool.components.tool ~= nil and equippedTool.components.tool:CanDoAction(ACTIONS.DIG) then
				--upside down tool build
				inst.AnimState:PlayAnimation("till2_pre")
			else
				inst.AnimState:PlayAnimation("till_pre")
			end
        end,

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("till")
                end
            end),
        },
    },

    State{
        name = "till",
        tags = { "doing", "busy" },

        onenter = function(inst)
			local equippedTool = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
			if equippedTool ~= nil and equippedTool.components.tool ~= nil and equippedTool.components.tool:CanDoAction(ACTIONS.DIG) then
				--upside down tool build
				inst.sg.statemem.fliptool = true
				inst.AnimState:PlayAnimation("till2_loop")
			else
				inst.AnimState:PlayAnimation("till_loop")
			end
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/wilson/dig") end),
            TimeEvent(11 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
            TimeEvent(12 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/emerge") end),
            TimeEvent(22 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
					inst.AnimState:PlayAnimation(inst.sg.statemem.fliptool and "till2_pst" or "till_pst")
                    inst.sg:GoToState("idle", true)
                end
            end),
        },
    },

    State{
        name = "dig_start",
        tags = { "predig", "working" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("shovel_pre")
			inst:AddTag("predig")
        end,

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
					inst.sg.statemem.digging = true
                    inst.sg:GoToState("dig")
                end
            end),
        },

		onexit = function(inst)
			if not inst.sg.statemem.digging then
				inst:RemoveTag("predig")
			end
		end,
    },

    State{
        name = "dig",
        tags = { "predig", "digging", "working" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("shovel_loop")
			inst:AddTag("predig")
        end,

        timeline =
        {
            TimeEvent(15 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("predig")
				inst:RemoveTag("predig")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/dig")
				inst:PerformBufferedAction()
            end),
        },

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.AnimState:PlayAnimation("shovel_pst")
                    inst.sg:GoToState("idle", true)
                end
            end),
        },

		onexit = function(inst)
			inst:RemoveTag("predig")
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
