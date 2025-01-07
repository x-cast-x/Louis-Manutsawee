local EQUIPSLOTS = GLOBAL.EQUIPSLOTS
local AddStategraphEvent = AddStategraphEvent
local AddStategraphState = AddStategraphState
local AddStategraphPostInit = AddStategraphPostInit
local AddStategraphActionHandler= AddStategraphActionHandler
GLOBAL.setfenv(1, GLOBAL)

local SkillUtil = require("utils/skillutil")

----------------------------------------------------------------------------------------------
--------------------------------------function-----------------------------------------------
----------------------------------------------------------------------------------------------

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

local function SpawnShadowFx(inst, target, fxscale)
    local wanda_attack_shadowweapon_normal_fx = SpawnPrefab("wanda_attack_shadowweapon_normal_fx")
    wanda_attack_shadowweapon_normal_fx.Transform:SetScale(fxscale, fxscale, fxscale)
    wanda_attack_shadowweapon_normal_fx.Transform:SetPosition(target:GetPosition():Get())
    inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
    inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe")
end

local katanarnd = 1

----------------------------------------------------------------------------------------------

local actionhandlers = {
}

local events = {
    EventHandler("putglasses", function(inst)
        inst.sg:GoToState("putglasses")
    end),
    EventHandler("changehair", function(inst)
        inst.sg:GoToState("changehair")
    end),
    EventHandler("heavenlystrike", function(inst)
        inst.sg:GoToState("heavenlystrike")
    end),
    EventHandler("blockparry", function(inst)
        inst.sg:GoToState("blockparry")
    end),
    EventHandler("counter_start", function(inst)
        inst.sg:GoToState("counter_start")
    end),
    EventHandler("mdash", function(inst)
        inst.sg:GoToState("mdash")
    end),
    EventHandler("mdash2", function(inst)
        inst.sg:GoToState("mdash2")
    end),
	EventHandler("redirect_locomote", function(inst, data)
        inst.sg:GoToState("mdash", data)
    end),
    EventHandler("redirect_locomote2", function(inst, data)
        inst.sg:GoToState("mdash2", data)
    end)
}

local states = {
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
        name = "putglasses",
        tags = {"busy", "nopredict", "nointerrupt", "nomorph", "doing","notalking"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("give")
            inst.AnimState:PushAnimation("give_pst",false)
        end,

       timeline = {
            TimeEvent(13 * FRAMES, function(inst)
                inst:PerformBufferedAction()
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
            inst.components.glasses:UpdateGlasses()
        end
    },

    State{
        name = "changehair",
        tags = {"busy", "nopredict", "nointerrupt", "nomorph", "doing","notalking"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "make")
            inst.AnimState:PlayAnimation("build_pre")
            inst.AnimState:PushAnimation("build_loop", true)
            inst.sg:SetTimeout(1)
        end,

        ontimeout = function(inst)
            inst:PerformBufferedAction()
            inst.AnimState:PlayAnimation("build_pst")
            inst.sg:GoToState("idle", false)
        end,

        onexit = function(inst)
            local HAIR_TYPES = inst.components.hair:GetHairTypes()
            local hair_type = inst.components.hair:GetCurrentHairType()
            local hair_length = inst.components.hair:GetHairLength()

            local current_index = 1
            for i, hair in ipairs(HAIR_TYPES) do
                if hair == hair_type then
                    current_index = i
                    break
                end
            end

            hair_type = HAIR_TYPES[(current_index % #HAIR_TYPES) + 1]

            inst.components.hair:SetHairType(hair_type)
            inst.components.hair:OnChangeHair()
            inst.SoundEmitter:KillSound("make")
        end,
    },

    State{
        name = "heavenlystrike",
        tags = {"busy", "nopredict", "nointerrupt", "nomorph", "skilling","notalking","mdashing" },

        onenter = function(inst)
            local x, y, z = inst.Transform:GetWorldPosition()
            local pufffx = SpawnPrefab("dirt_puff")
            pufffx.Transform:SetScale(.3, .3, .3)
            pufffx.Transform:SetPosition(x, y, z)

            SkillCollision(inst, true)

            inst.components.locomotor:Stop()
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
            end
            inst.components.combat:SetRange(TUNING.DEFAULT_ATTACK_RANGE)
            inst.AnimState:PlayAnimation("atk_leap_pre")
            inst.Physics:SetMotorVelOverride(30,0,0)
        end,

        timeline = {
            TimeEvent(0 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe")
            end),
            TimeEvent(6 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe")
                SkillCollision(inst, false)
            end),
            TimeEvent(11 * FRAMES, function(inst)
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
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end
        end,
    },

    State{
        name = "blockparry",
        tags = {"busy", "nopredict", "nointerrupt", "nomorph"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("atk")
            --inst.AnimState:PushAnimation("parry_pst", false)
            inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/jump")
        end,

        timeline = {
            TimeEvent(0.5*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")
                inst.Physics:SetMotorVelOverride(-0.1,0,0)
            end),

            TimeEvent(1*FRAMES, function(inst)
            local sparks = SpawnPrefab("sparks")
                inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
                sparks.Transform:SetPosition(inst:GetPosition():Get())
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
            inst.Physics:ClearMotorVelOverride()
        end,
    },

    State{
        name = "counter_start",
        tags = {"busy", "nomorph", "notalking", "nopredict", "doing"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("parry_pre")
            inst.AnimState:PushAnimation("parry_pst", false)
            inst.components.locomotor:Stop()
            inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/jump")
        end,

        timeline = {
            TimeEvent(.5 * FRAMES, function(inst)
                inst.sg:AddStateTag("counteractive")
            end),
            TimeEvent(8 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("counteractive")
                inst.sg:AddStateTag("startblockparry")
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
            inst.sg:RemoveStateTag("startblockparry")
        end,
    },

    State{
        name = "counter_attack",
        tags = {"attack", "doing", "busy", "nointerrupt" ,"nopredict","nomorph"},

        onenter = function(inst, target)
            inst.components.locomotor:Stop()

            if math.random(1, 3) > 1 then
                inst.AnimState:OverrideSymbol("fx_lunge_streak", "player_lunge_blue", "fx_lunge_streak")
                inst.AnimState:PlayAnimation("lunge_pst")
            else
                inst.AnimState:PlayAnimation("atk")
            end

            inst.inspskill = true
            inst.components.combat:SetRange(4)

            if target ~= nil and target:IsValid() then
                inst.sg.statemem.target = target
                inst:ForceFacePoint(target.Transform:GetWorldPosition())
            end
        end,

        timeline = {
            TimeEvent(3 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
                inst:PerformBufferedAction()
                inst.components.combat:DoAttack(inst.sg.statemem.target)
            end),

            TimeEvent(4 * FRAMES, function(inst)
                inst.components.combat:SetRange(TUNING.DEFAULT_ATTACK_RANGE)
            end),
        },

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
        end,

        events = {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone()
                and inst.components.health ~= nil
                and not inst.components.health:IsDead()
                and not inst.sg:HasStateTag("dead") then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.components.combat ~= nil then
                inst.components.combat:SetTarget(nil)
                inst.components.combat:SetRange(TUNING.DEFAULT_ATTACK_RANGE)
            end
            inst.inspskill = nil
        end,
    },

    State{
        name = "monemind",
        tags = {"busy", "nopredict", "nointerrupt", "nomorph", "doing","notalking","skilling"},

        onenter = function(inst, target)
            inst.components.locomotor:Stop()

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
            end

            inst.AnimState:PlayAnimation("atk")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")

            if target ~= nil and target:IsValid() then
                inst.sg.statemem.target = target
                inst:ForceFacePoint(target.Transform:GetWorldPosition())
            end
        end,

        timeline = {
            TimeEvent(3 * FRAMES, function(inst)
            inst.components.combat:DoAttack(inst.sg.statemem.target)
                local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                if equip ~= nil and equip.components.spellcaster ~= nil then
                    equip.components.spellcaster:CastSpell(inst)
                end
                inst.Physics:SetMotorVelOverride(32,0,0)
                if inst.sg.statemem.target then
                    inst:ForceFacePoint(inst.sg.statemem.target.Transform:GetWorldPosition())
                end
            end),
            TimeEvent(4 * FRAMES, function(inst)
                inst.Physics:ClearMotorVelOverride()
            end),
            TimeEvent(9 * FRAMES, function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        ontimeout = function(inst)
            inst.sg:AddStateTag("idle")
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
        name = "quicksheath",
        tags = {"busy", "nopredict", "nointerrupt", "nomorph", "doing","notalking","skilling"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("atk")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
        end,

        timeline = {
            TimeEvent(3 * FRAMES, function(inst)
                local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                if weapon ~= nil and weapon.components.spellcaster ~= nil then
                    weapon.components.spellcaster:CastSpell(inst)
                end
            end),
            TimeEvent(8 * FRAMES, function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        ontimeout = function(inst)
            inst.sg:AddStateTag("idle")
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
        name = "ryusen",
        tags = {"busy", "nopredict", "nointerrupt", "nomorph", "doing","notalking","skilling","mdashing"},

        onenter = function(inst, target)
            inst.components.locomotor:Stop()
            inst.components.combat:SetRange(10)
            inst.AnimState:PlayAnimation("atk")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
            if target ~= nil and target:IsValid() then
                inst.sg.statemem.target = target
                inst:ForceFacePoint(target.Transform:GetWorldPosition())
            end
        end,

        timeline = {
            TimeEvent(2 * FRAMES, function(inst)
                local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                if equip ~= nil and equip.components.spellcaster ~= nil then
                    equip.components.spellcaster:CastSpell(inst)
                end
                local sparks = SpawnPrefab("sparks")
                sparks.Transform:SetPosition(inst:GetPosition():Get())
            end),

            TimeEvent(3 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe")
                local wanda_attack_shadowweapon_old_fx = SpawnPrefab("wanda_attack_shadowweapon_old_fx")
                wanda_attack_shadowweapon_old_fx.entity:AddFollower()
                wanda_attack_shadowweapon_old_fx.Follower:FollowSymbol(inst.GUID, "swap_body", 0, 0, 0)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
                inst:PerformBufferedAction()

                local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                if equip ~= nil and equip.components.spellcaster ~= nil then
                    equip.components.spellcaster:CastSpell(inst)
                end
            end),

            TimeEvent(6 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe")
                local wanda_attack_shadowweapon_normal_fx = SpawnPrefab("wanda_attack_shadowweapon_normal_fx")
                wanda_attack_shadowweapon_normal_fx.entity:AddFollower()
                wanda_attack_shadowweapon_normal_fx.Follower:FollowSymbol(inst.GUID, "swap_body", 0, 0, 0)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
                inst:PerformBufferedAction()

                local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                if equip ~= nil and equip.components.spellcaster ~= nil then
                    equip.components.spellcaster:CastSpell(inst)
                end
            end),

            TimeEvent(9 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe")
                local wanda_attack_shadowweapon_old_fx = SpawnPrefab("wanda_attack_shadowweapon_old_fx")
                wanda_attack_shadowweapon_old_fx.entity:AddFollower()
                wanda_attack_shadowweapon_old_fx.Follower:FollowSymbol(inst.GUID, "swap_body", 0, 0, 0)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
                inst:PerformBufferedAction()

                local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                if equip ~= nil and equip.components.spellcaster ~= nil then
                    equip.components.spellcaster:CastSpell(inst)
                end
            end),

            TimeEvent(12 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe")
                local wanda_attack_shadowweapon_normal_fx = SpawnPrefab("wanda_attack_shadowweapon_normal_fx")
                wanda_attack_shadowweapon_normal_fx.entity:AddFollower()
                wanda_attack_shadowweapon_normal_fx.Follower:FollowSymbol(inst.GUID, "swap_body", 0, 0, 0)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
                inst:PerformBufferedAction()

                local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                if equip ~= nil and equip.components.spellcaster ~= nil then
                    equip.components.spellcaster:CastSpell(inst)
                end
            end),

            TimeEvent(13 * FRAMES, function(inst)
                inst.AnimState:PlayAnimation("atk")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
            end),

            TimeEvent(14 * FRAMES, function(inst)
                inst.Physics:SetMotorVelOverride(32,0,0)
                inst:ForceFacePoint(inst.sg.statemem.target.Transform:GetWorldPosition())
            end),

            TimeEvent(16 * FRAMES, function(inst)
                inst.Physics:ClearMotorVelOverride()
                local x, y, z = inst.Transform:GetWorldPosition()
                local fx = SpawnPrefab("groundpoundring_fx")
                fx.Transform:SetScale(.6, .6, .6)
                fx.Transform:SetPosition(x, y, z)
            end),

            TimeEvent(17 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
                inst.components.combat:DoAttack(inst.sg.statemem.target)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
                inst:PerformBufferedAction()
                inst.components.combat:SetRange(TUNING.DEFAULT_ATTACK_RANGE)
            end),
        },

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
        end,

        events = {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone()
                and inst.components.health ~= nil
                and not inst.components.health:IsDead()
                and not inst.sg:HasStateTag("dead")
                then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.components.combat ~= nil then
                inst.components.combat:SetTarget(nil)
                inst.components.combat:SetRange(TUNING.DEFAULT_ATTACK_RANGE)
            end
        end,
    },

    State{
        name = "flip",
        tags = {"busy", "nopredict", "nointerrupt", "nomorph", "doing","notalking","skilling"},

        onenter = function(inst, target)
            inst.components.locomotor:Stop()
            inst.AnimState:OverrideSymbol("fx_lunge_streak", "player_lunge_blue", "fx_lunge_streak")
            inst.components.combat:SetRange(6)
            inst.components.combat:EnableAreaDamage(true)
            inst.components.combat:SetAreaDamage(2, 1)
            inst.AnimState:SetDeltaTimeMultiplier(1.3)
            inst.inspskill = true
            inst.AnimState:PlayAnimation("lunge_pre")
            inst.AnimState:PushAnimation("lunge_pst", false)
            inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/jump")
            if target ~= nil and target:IsValid() then
                inst.sg.statemem.target = target
                inst:ForceFacePoint(target.Transform:GetWorldPosition())
            end
        end,

        timeline = {
            TimeEvent(1 * FRAMES, function(inst)
                inst.Physics:SetMotorVelOverride(32,0,0)
                inst:ForceFacePoint(inst.sg.statemem.target.Transform:GetWorldPosition())
            end),

            TimeEvent(2 * FRAMES, function(inst)
                inst.Physics:ClearMotorVelOverride()
            end),

            TimeEvent(3 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/jump")
            end),

            TimeEvent(4 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/jump")
            end),

            TimeEvent(5 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/jump")
            end),

            TimeEvent(6 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/jump")
            end),

            TimeEvent(7 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/jump")
            end),

            TimeEvent(8 * FRAMES, function(inst)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
                inst:PerformBufferedAction()
                inst.components.combat:SetRange(TUNING.DEFAULT_ATTACK_RANGE)
                inst.components.combat:SetAreaDamage(1, 1)
                inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
                inst.AnimState:SetDeltaTimeMultiplier(1)
            end),
        },

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
        end,

        events = {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.components.combat ~= nil then
                inst.components.combat:SetTarget(nil)
                inst.components.combat:SetRange(TUNING.DEFAULT_ATTACK_RANGE)
            end
            inst.inspskill = nil
            inst.components.combat:EnableAreaDamage(false)
        end,
    },

    State{
        name = "thrust",
        tags = {"busy", "nopredict", "nointerrupt", "nomorph", "doing","notalking","skilling"},

        onenter = function(inst, target)
            inst.components.locomotor:Stop()
            inst.components.combat:SetRange(6)
            inst.components.combat:EnableAreaDamage(true)
            inst.components.combat:SetAreaDamage(2, 1)
            inst.AnimState:SetDeltaTimeMultiplier(1.3)
            inst.inspskill = true
            inst.AnimState:PlayAnimation("multithrust")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
            if target ~= nil and target:IsValid() then
                inst.sg.statemem.target = target
                inst:ForceFacePoint(target.Transform:GetWorldPosition())
            end
        end,

        timeline = {
            TimeEvent(1 * FRAMES, function(inst)
                inst.Physics:SetMotorVelOverride(32,0,0)
                inst:ForceFacePoint(inst.sg.statemem.target.Transform:GetWorldPosition())
            end),

            TimeEvent(2 * FRAMES, function(inst)
                inst.Physics:ClearMotorVelOverride()
            end),

            TimeEvent(8 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_nightsword")
            end),

            TimeEvent(9 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe")
                inst.components.combat:DoAttack(inst.sg.statemem.target)
                inst:PerformBufferedAction()
            end),

            TimeEvent(10 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_nightsword")
                inst.components.combat:DoAttack(inst.sg.statemem.target)
                inst:PerformBufferedAction()
            end),

            TimeEvent(12 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe")
                inst.components.combat:DoAttack(inst.sg.statemem.target)
                inst:PerformBufferedAction()
            end),

            TimeEvent(14 * FRAMES, function(inst)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
                inst:PerformBufferedAction()
                inst.components.combat:SetRange(TUNING.DEFAULT_ATTACK_RANGE)
                inst.components.combat:SetAreaDamage(1, 1)
                inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
                inst.AnimState:SetDeltaTimeMultiplier(1)
            end),
        },

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
        end,

        events = {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.components.combat ~= nil then
                inst.components.combat:SetTarget(nil)
                inst.components.combat:SetRange(TUNING.DEFAULT_ATTACK_RANGE)
                inst.components.combat:EnableAreaDamage(false)
            end
            inst.inspskill = nil
        end,
    },

    State{
        name = "ichimonji",
        tags = {"busy", "nopredict", "nointerrupt", "nomorph", "doing","notalking","skilling"},

        onenter = function(inst, target)
            inst.inspskill = true
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("atk_prop_pre")
            inst.AnimState:PushAnimation("atk_prop_lag", false)
            inst.AnimState:PushAnimation("atk", false)
            inst.components.combat:EnableAreaDamage(true)
            inst.components.combat:SetAreaDamage(2, 1)
            inst.AnimState:SetDeltaTimeMultiplier(2.5)
            inst.components.combat:SetRange(6)
            if target ~= nil and target:IsValid() then
                inst.sg.statemem.target = target
                inst:ForceFacePoint(target.Transform:GetWorldPosition())
            end
        end,

        timeline = {
            TimeEvent(8 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe")
                SkillUtil.AddFollowerFx(inst, "electrichitsparks")
                SkillUtil.GroundPoundFx(inst, 0.5)
            end),

            TimeEvent(9 * FRAMES, function(inst)
                inst.AnimState:SetDeltaTimeMultiplier(1)
                inst.Physics:SetMotorVelOverride(32,0,0)
                inst:ForceFacePoint(inst.sg.statemem.target.Transform:GetWorldPosition())
            end),

            TimeEvent(10 * FRAMES, function(inst)
                inst.Physics:ClearMotorVelOverride()
                local x, y, z = inst.Transform:GetWorldPosition()
                local pufffx = SpawnPrefab("dirt_puff")
                pufffx.Transform:SetScale(.6, .6, .6)
                pufffx.Transform:SetPosition(x, y, z)
            end),

            TimeEvent(17 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")
                inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
                inst:ForceFacePoint(inst.sg.statemem.target.Transform:GetWorldPosition())
                inst.components.combat:DoAttack(inst.sg.statemem.target)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
                inst.components.combat:DoAttack(inst.sg.statemem.target)

                --if not inst.doubleichimonji then inst.components.combat:DoAttack(inst.sg.statemem.target) end
                inst:PerformBufferedAction()
                inst.components.combat:SetRange(TUNING.DEFAULT_ATTACK_RANGE)
                inst.components.combat:SetAreaDamage(1, 1)
            end),
        },

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
        end,

        events = {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.components.combat ~= nil then
                inst.components.combat:SetTarget(nil)
                inst.components.combat:SetRange(TUNING.DEFAULT_ATTACK_RANGE)
                inst.components.combat:EnableAreaDamage(false)
            end
            inst.inspskill = nil
            if inst.doubleichimonji ~= nil then
                inst.doubleichimonji = nil
                inst.components.talker:Say(STRINGS.SKILL.SKILL1ATTACK, 2, true)
            end
            if inst.doubleichimonjistart then
                inst.doubleichimonjistart = nil
                inst.doubleichimonji = true
            end
        end,
    },

    State{
        name = "habakiri",
        tags = {"busy", "nopredict", "nointerrupt", "nomorph", "doing","notalking","skilling","mdashing"},

        onenter = function(inst, target)
            inst.components.locomotor:Stop()
            inst.AnimState:OverrideSymbol("fx_lunge_streak", "player_lunge_blue", "fx_lunge_streak")
            inst.components.combat:SetRange(12)
            inst.components.combat:EnableAreaDamage(true)
            inst.components.combat:SetAreaDamage(2, 1)
            inst.inspskill = true
            inst.AnimState:PlayAnimation("atk")
            inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/jump")
            if target ~= nil and target:IsValid() then
                inst.sg.statemem.target = target
                inst:ForceFacePoint(target.Transform:GetWorldPosition())
            end
        end,

        timeline = {
            TimeEvent(1 * FRAMES, function(inst)
                inst:ForceFacePoint(inst.sg.statemem.target.Transform:GetWorldPosition())
                inst.Physics:SetMotorVelOverride(-.25,0,10)
            end),

            TimeEvent(3 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/jump")
            end),

            TimeEvent(4 * FRAMES, function(inst)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
                SpawnShadowFx(inst, inst.sg.statemem.target, 3)
                inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
                inst:PerformBufferedAction()
                inst.Physics:ClearMotorVelOverride()
            end),

            TimeEvent(5 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/jump")
                inst.AnimState:PlayAnimation("lunge_pst")
                inst:ForceFacePoint(inst.sg.statemem.target.Transform:GetWorldPosition())
                inst.Physics:SetMotorVelOverride(-.5,0,-20)
            end),

            TimeEvent(8* FRAMES, function(inst)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
                SpawnShadowFx(inst, inst.sg.statemem.target, 2)
                inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
                inst:PerformBufferedAction()
                inst.Physics:ClearMotorVelOverride()
            end),

            TimeEvent(9 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/jump")
                inst.AnimState:PlayAnimation("atk")
                inst:ForceFacePoint(inst.sg.statemem.target.Transform:GetWorldPosition())
                inst.Physics:SetMotorVelOverride(-.5,0,20)
            end),

            TimeEvent(12* FRAMES, function(inst)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
                SpawnShadowFx(inst, inst.sg.statemem.target, 2)
                inst:PerformBufferedAction()
                inst.components.combat:SetRange(TUNING.DEFAULT_ATTACK_RANGE)
                inst.components.combat:SetAreaDamage(1, 1)
                inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
                inst.Physics:ClearMotorVelOverride()
                inst.Physics:SetMotorVelOverride(-.5,0,-10)
            end),

            TimeEvent(15* FRAMES, function(inst)
                local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                if weapon ~= nil and weapon.components.spellcaster ~= nil then
                    weapon.components.spellcaster:CastSpell(inst)
                end
                inst.Physics:ClearMotorVelOverride()
                local sparks = SpawnPrefab("sparks")
                sparks.Transform:SetPosition(inst:GetPosition():Get())
            end),

            TimeEvent(20 * FRAMES, function(inst)
                inst.components.talker:Say(STRINGS.SKILL.SKILL2ATTACK, 2, true)
            end),
        },

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
        end,

        events = {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.components.combat ~= nil then
                inst.components.combat:SetTarget(nil)
                inst.components.combat:SetRange(TUNING.DEFAULT_ATTACK_RANGE)
            end
            inst.inspskill = nil
            inst.components.combat:EnableAreaDamage(false)
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

    State{
        name = "idle_bocchi",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_bocchi_loop")
            inst.sg:SetTimeout(1)
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },
}

for _, event in ipairs(events) do
    AddStategraphEvent("wilson", event)
end

for _, state in ipairs(states) do
    AddStategraphState("wilson", state)
end

for _, actionhandler in ipairs(actionhandlers) do
    AddStategraphActionHandler("wilson", actionhandler)
end

local function fn(sg)
    local attack_actionhandler = sg.actionhandlers[ACTIONS.ATTACK].deststate
    sg.actionhandlers[ACTIONS.ATTACK].deststate = function(inst, action, ...)
        inst.sg.mem.localchainattack = not action.forced or nil
        local playercontroller = inst.components.playercontroller
        local attack_tag =
            playercontroller ~= nil and
            playercontroller.remote_authority and
            playercontroller.remote_predicting and
            "abouttoattack" or
            "attack"
        if not (inst.sg:HasStateTag(attack_tag) and action.target == inst.sg.statemem.attacktarget or inst.components.health:IsDead()) then
            local weapon = inst.components.combat ~= nil and inst.components.combat:GetWeapon() or nil
            if weapon ~= nil then
                if weapon:HasTag("mkatana") then
                    return "mkatana"
                elseif weapon:HasTag("iai") then
                    return "iai"
                elseif weapon:HasTag("yari") then
                    return "yari"
                end
            end
        end

        if attack_actionhandler ~= nil then
            return attack_actionhandler(inst, action, ...)
        end
    end

    -- Why does Klei make it but not use it?????
    local _wes_funnyidle_onenter = sg.states["wes_funnyidle"].onenter
    sg.states["wes_funnyidle"].onenter = function(inst, ...)
        local balloon_color = {
            "blue",
            "green",
            "orange",
            "red",
            "purple",
            "yellow"
        }
        inst.AnimState:OverrideSymbol("balloon_red", "player_idles_wes", "balloon_" .. balloon_color[math.random(1, #balloon_color)])

        if _wes_funnyidle_onenter ~= nil then
            _wes_funnyidle_onenter(inst, ...)
        end
    end
end

AddStategraphPostInit("wilson", fn)
