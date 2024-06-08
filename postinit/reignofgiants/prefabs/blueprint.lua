local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local blueprint = {
    kage = function(inst)
        inst.components.inspectable:SetDescription("It says:\n \".-- . .- .-. . -.. ..- ... - .- -. -.. ... .... .- -.. --- .-- ...\"")

        local _onteach = inst.components.teacher.onteach
        function inst.components.teacher.onteach(inst, learner)
            if learner ~= nil and learner:HasTag("kenjutsuka") then
                _onteach(inst, learner)
                learner:PushEvent("mindcontrolled")
            end
        end
    end
}

for k, v in pairs(blueprint) do
    AddPrefabPostInit(k .. "_blueprint", function(inst)
        if not TheWorld.ismastersim then
            return
        end

        if v ~= nil then
            v(inst)
        end
    end)
end
