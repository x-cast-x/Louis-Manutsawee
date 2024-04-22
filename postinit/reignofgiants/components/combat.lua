local Combat = require("components/combat")
GLOBAL.setfenv(1, GLOBAL)

local _DoAttack = Combat.DoAttack
function Combat:DoAttack(targ, weapon, projectile, stimuli, instancemult, instrangeoverride, instpos, ...)
    if weapon ~= nil and weapon:HasTag("tenseiga") then
        return
    end
    return _DoAttack(self, targ, weapon, projectile, stimuli, instancemult, instrangeoverride, instpos, ...)
end
