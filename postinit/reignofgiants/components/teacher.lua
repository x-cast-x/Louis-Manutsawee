local Teacher = require("components/teacher")
GLOBAL.setfenv(1, GLOBAL)

local _Teach = Teacher.Teach
function Teacher:Teach(target, ...)
    if self.recipe == "kage_blueprint" and target ~= nil and not target:HasTag("toshi") then
        target.components.talker:Say(GetString(target, "ANNOUNCE_LNCOMPREHENSIBLE"))
        self.inst:Remove()
        return false
    end
    return _Teach(self, target, ...)
end
