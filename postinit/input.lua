require "events"
GLOBAL.setfenv(1, GLOBAL)

--[[

其中包含了多个按键方案

方案一: 按键组合 (同时按下)
是否同时按住了两个特定的按键。
KEY_A + KEY_B

方案二: 按键序列 (快速连按)
是否在松开一个按键后，快速地按下了另一个特定的按键。
KEY_A ==> KEY_B

方案三: 长按按键 (长按不动)
按住某个按键 超过指定时间。
KEY_A -pressed_time->

方案四: 连击按键 (重复连击)
在短时间内连续按同一个键。
KEY_A ==> KEY_A ==> KEY_A

方案五: 多键组合
同时按下多个按键。
KEY_A + KEY_B + KEY_C

方案六: 多键序列
依次按下多个按键。
KEY_A ==> KEY_B ==> KEY_C

]]

local TheInput = TheInput

TheInput.special_keys = {}
TheInput.onspecialkey = EventProcessor()

TheInput.pressed_keys = {}
TheInput.key_combinations = {}
TheInput.onkeycombo = EventProcessor()

TheInput.last_key_released = nil
TheInput.last_key_release_time = 0
TheInput.sequence_timeout = 0.5
TheInput.onkeysequence = EventProcessor()

local _OnRawKey = TheInput.OnRawKey
function TheInput:OnRawKey(key, down)
    local current_time = GetTime()
    local sequence_handled = false
    local combo_handled = false
    local special_handled = false

    if down then
        if self.last_key_released ~= nil and (current_time - self.last_key_release_time <= self.sequence_timeout) then
            local event_name = "seq_" .. tostring(self.last_key_released) .. "_" .. tostring(key)
            sequence_handled = self.onkeysequence:HandleEvent(event_name, key, self.last_key_released) or false
        end

        self.last_key_released = nil
        self.last_key_release_time = 0

        self.pressed_keys[key] = true

        for pressed_key, _ in pairs(self.pressed_keys) do
            if pressed_key ~= key then
                local keys = { key, pressed_key }
                table.sort(keys)
                local event = keys[1] .. "_" .. keys[2]

                if self.key_combinations[event] then
                    combo_handled = self.onkeycombo:HandleEvent(event, key, pressed_key) or false
                    if combo_handled then break end
                end
            end
        end
    else
        self.last_key_released = key
        self.last_key_release_time = current_time

        self.pressed_keys[key] = nil
    end

    special_handled = self.onspecialkey:HandleEvent("onspecialkey", key, down) or false

    if not sequence_handled and not combo_handled and not special_handled then
        if _OnRawKey ~= nil then
            return _OnRawKey(self, key, down)
        end
    end
end

function TheInput:AddSpecialKeyHandler(key, fn, action)
    self.special_keys[key] = true
    return self.onspecialkey:AddEventHandler("onspecialkey", fn)
end

function TheInput:AddCombinationKeyHandler(key1, key2, fn)
    local keys = { key1, key2 }
    table.sort(keys)
    local event = keys[1] .. "_" .. keys[2]
    self.key_combinations[event] = true
    return self.onkeycombo:AddEventHandler(event, fn)
end

function TheInput:AddSequentialKeyHandler(key, _key, fn)
    local event_name = "seq_" .. tostring(key) .. "_" .. tostring(_key)
    return self.onkeysequence:AddEventHandler(event_name, fn)
end

function TheInput:SetSequenceTimeout(timeout)
    self.sequence_timeout = timeout or 1 -- 默认0.5
end

