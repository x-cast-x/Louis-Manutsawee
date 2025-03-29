require "events"
GLOBAL.setfenv(1, GLOBAL)

local TheInput = TheInput

--[[
分析这个lua脚本的功能以及逻辑，我的需求如下
我需要给它添加一个组合键的功能，每个键和组合键按下都会触发不同结果
现在有A B C三个键
逻辑为当按下键A键时会触发A键注册的函数结果，不论是按下或抬起时按下B键会触发A+B键注册的函数结果, C键以此类推
使用hooking的方式添加这个功能，请考虑各个方面函数使用 变量 判断(除了类似判断TheInput是否存在的问题)

帮我实现一个组合键(只有两个键)的功能，使用hook的方式添加到TheInput中,以下帮我完善


规则: 专注于功能的实现，不需要太多注释 判断或者例子 不要判断TheInput 是否已存在 不要做过多的修饰
不需要移除组合键处理
最后请使用中文回答
]]

TheInput.pressed_keys = {}
TheInput.key_combinations = {}
TheInput.onkeycombo = EventProcessor()

local _OnRawKey = TheInput.OnRawKey
function TheInput:OnRawKey(key, down)
    if down then
        -- 将按下的键添加到 pressed_keys
        self.pressed_keys[key] = true

        -- 检查是否有已按下的键与当前键组成已注册的组合
        for pressed_key, _ in pairs(self.pressed_keys) do
            if pressed_key ~= key then
                -- 生成组合键的唯一ID（排序以确保顺序无关）
                local keys = { key, pressed_key }
                table.sort(keys)
                local event = keys[1] .. "_" .. keys[2]

                -- 如果这个组合键ID被注册过
                if self.key_combinations[event] then
                    -- 触发组合键事件
                    -- 注意：这里传递组合ID和原始按键顺序（如果需要的话）
                    -- 或者只传递组合ID，让回调函数自行处理
                    -- 为简单起见，我们传递组合ID和两个键
                    self.onkeycombo:HandleEvent(event, key, pressed_key)
                     -- 或者 self.onkeycombo:HandleEvent(combo_id, keys[1], keys[2])
                end
            end
        end
    else
        self.pressed_keys[key] = nil
    end

    if _OnRawKey ~= nil then
        _OnRawKey(self, key, down)
    end
end

function TheInput:AddCombinationKeyHandler(key1, key2, fn)
    -- 生成组合键的唯一ID（排序以确保顺序无关）
    local keys = { key1, key2 }
    table.sort(keys)
    local event = keys[1] .. "_" .. keys[2]

    -- 标记这个组合键ID已被注册
    self.key_combinations[event] = true

    -- 使用 onkeycombo EventProcessor 来注册回调函数
    -- 当 HandleEvent(combo_id, ...) 被调用时，fn 将被执行
    return self.onkeycombo:AddEventHandler(event, fn)
end

-- 方案二: 按键序列检测
-- 在识别到特定序列时触发事件处理器。例如，可以检测“A→B” 这样的按键顺序，并执行对应的回调函数。

TheInput.last_key_released = nil          -- 记录上一个释放的按键
TheInput.last_key_release_time = 0        -- 记录上一个按键释放的时间
TheInput.sequence_timeout = 0.5           -- 允许的按键序列时间间隔（秒）
TheInput.onkeysequence = EventProcessor()

function TheInput:AddSequentialKeyHandler(key, _key, fn)
    local event_name = "seq_"..tostring(key).."_"..tostring(_key)
    return self.onkeysequence:AddEventHandler(event_name, fn)
end

local _OnRawKey = TheInput.OnRawKey
-- b. 定义一个新的函数来替换 self.OnRawKey
--    这个新函数会包含我们的序列检测逻辑，并调用原始函数
function TheInput:OnRawKey(key, down) -- self 在被调用时就是 self
    local current_time = GetTime()

    if down then
        -- === 按键按下 (Key Down) 逻辑 ===
        local sequence_detected = false
        -- 检查：是否存在上一个释放的键，并且时间未超时？
        if self.last_key_released ~= nil and (current_time - self.last_key_release_time <= self.sequence_timeout) then
            -- 构造序列事件名称 (上一个释放的键 -> 当前按下的键)
            local event_name = "seq_"..tostring(self.last_key_released).."_"..tostring(key)
            -- 触发序列事件处理器。HandleEvent 返回 true 如果有处理器被执行
            sequence_detected = self.onkeysequence:HandleEvent(event_name)
            -- (可选) 调试输出
            -- print("Sequence check:", event_name, "Time diff:", current_time - self.last_key_release_time, "Detected:", sequence_detected)
        end

        -- **重要**：在按键按下事件发生后（无论是否检测到序列），
        -- 都需要重置序列状态，防止错误的连续触发 (例如 A -> C -> B 触发 A -> B)
        self.last_key_released = nil
        self.last_key_release_time = 0
    else
        -- === 按键抬起 (Key Up) 逻辑 ===
        -- 记录这个按键的释放，作为潜在序列的开始
        self.last_key_released = key
        self.last_key_release_time = current_time
    end

    _OnRawKey(self, key, down)
end

-- (可选) 添加一个函数来允许外部修改超时时间
function self:SetSequenceTimeout(timeout)
    self.sequence_timeout = timeout or 0.5 -- 提供默认值
end

