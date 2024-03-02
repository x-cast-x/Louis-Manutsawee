local sound = {}

local _PlaySound = SoundEmitter.PlaySound
function SoundEmitter:PlaySound(soundname, ...)
    return _PlaySound(self, sound[soundname] or soundname, ...)
end

local function SetSound(name, alias)
    sound[name] = alias
end

return {
    SetSound = SetSound,
}
