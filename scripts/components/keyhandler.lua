local function IsHUDScreen()
	return TheFrontEnd:GetActiveScreen() and TheFrontEnd:GetActiveScreen().name and
    type(TheFrontEnd:GetActiveScreen().name) == "string" and
    TheFrontEnd:GetActiveScreen().name == "HUD"
end

local function CanCastSkill(inst)
    local self = inst.components.keyhandler
	return self.enabled and IsHUDScreen() and not inst:HasTag("time_stopped") and not inst:HasTag("sleeping") and
    self.inst.components.playercontroller:IsEnabled()
end

local function IsMouseKey(key)
	return key >= 1000 and key <= 1006
end

local function OnRawKey(self, key, down)
	local player = ThePlayer
	if player ~= nil then
  		if (key and not down) and not self.paused and not self.ignore_ then
      		player:PushEvent("keyup", {inst = self.inst, player = player, key = key})
		elseif key and down and not self.paused and not self.ignore_ then
      		player:PushEvent("keydown", {inst = self.inst, player = player, key = key})
		end
  	end
end

local function OnMouseButton(self, button, down)
	local player = ThePlayer
	if player ~= nil then
		if (button and not down) and not self.paused and not self.ignore_ then
			player:PushEvent("mousebuttonup", {inst = self.inst, player = player, key = button})
		elseif button and down and not self.paused and not self.ignore_ then
			player:PushEvent("mousebuttondown", {inst = self.inst, player = player, key = button})
		end
	end
end

local function OnGamePaused(inst, paused)
    inst.components.keyhandler.paused = paused
end

-- local function ignore(self)
-- 	self.ignore_ = not self.ignore_
-- end

local KeyHandler = Class(function(self, inst)
	self.inst = inst
	self.paused = false
	self.ignore_ = false
	-- self.ignore_event = net_event(self.inst.GUID, "ignore")
	self.handler = TheInput:AddKeyHandler(function(key, down) OnRawKey(self, key, down) end)

	self.inst:ListenForEvent("gamepaused", OnGamePaused)

	-- self.inst:ListenForEvent("ignore", function(inst)
	-- 	ignore(inst.components.keyhandler)
	-- end)
end)

-- function KeyHandler:StartIgnoring()
-- 	self.ignore_event:push()
-- end

-- function KeyHandler:StopIgnoring()
-- 	self.ignore_event:push()
-- end

function KeyHandler:SetTickTime(time)
	self.ticktime = time or self.ticktime or 0
end

function KeyHandler:AddActionListener(namespace, key, action, event)
	if event == nil then
		self.inst:ListenForEvent("keyup", function(inst, data)
			if data.inst == ThePlayer then
				if data.key == key then
                    if CanCastSkill(inst) then
                        if TheWorld.ismastersim then
                            ThePlayer:PushEvent("keyaction"..namespace..action, { Namespace = namespace, Action = action, Fn = MOD_RPC_HANDLERS[namespace][MOD_RPC[namespace][action].id]})
                        else
                            SendModRPCToServer(MOD_RPC[namespace][action])
                        end
                    end
				end
			end
		end)
	elseif event ~= nil then
		self.inst:ListenForEvent(string.lower(event), function(inst, data)
			if data.inst == ThePlayer then
				if data.key == key then
                    if CanCastSkill(inst) then
                        if TheWorld.ismastersim then
                            ThePlayer:PushEvent("keyaction".. namespace .. action, { Namespace = namespace, Action = action, Fn = MOD_RPC_HANDLERS[namespace][MOD_RPC[namespace][action].id]})
                        else
                            SendModRPCToServer(MOD_RPC[namespace][action])
                        end
                    end
				end
			end
		end)
	end

	if TheWorld.ismastersim then
		self.inst:ListenForEvent("keyaction".. namespace .. action, function(inst, data)
			if not data.Action == action and not data.Namespace == namespace then
				return
			end
            data.Fn(inst)
		end, self.inst)
	end
end

return KeyHandler
