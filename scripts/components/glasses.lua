AddModRPCHandler("LouisManutsawee", "PutGlasses", function(inst, skinname)
    local function CanPutGlasses(inst)
        local not_dead = not (inst.components.health ~= nil and inst.components.health:IsDead() and inst.sg:HasStateTag("dead"))
                         and not inst:HasTag("playerghost")
        local is_idle = inst.sg:HasStateTag("idle") or inst:HasTag("idle")
        local not_doing = not (inst.sg:HasStateTag("doing") or inst.components.inventory:IsHeavyLifting())
        local not_moving = not (inst.sg:HasStateTag("moving") or inst:HasTag("moving"))

        return not_dead and not_doing, not_moving, is_idle
    end

    local can_change, not_moving, is_idle = CanPutGlasses(inst)
    if can_change and not_moving and is_idle and not inst.components.timer:TimerExists("put_glasse_cd") then
        inst.components.timer:StartTimer("put_glasse_cd", 1.4)

        inst:DoTaskInTime(0.1, function()
            inst:PushEvent("putglasses")
        end)
    end
end)

return Class(function(self, inst)

    self.inst = inst

    self.status = false

    local glasses_map = {
        ["manutsawee_uniform_black"] = "sunglasses",
        ["manutsawee_bocchi"] = "starglasses",
    }

    function self:UpdateGlasses()
        local build = glasses_map[inst.AnimState:GetBuild()]
        local skinname = build ~= nil and build or "eyeglasses"
        if skinname ~= nil then
            if not self.status then
                inst.AnimState:OverrideSymbol("swap_face", skinname, "swap_face")
                self.status = true
            end
        elseif inst.AnimState:GetSymbolOverride("swap_face") ~= nil then
            inst.AnimState:ClearOverrideSymbol("swap_face")
            self.status = false
        end
    end

    function self:AddGlass(build, glass_build)
        glasses_map[build] = glass_build
    end

    function self:OnLoad(data)
        self.status = data.status

        self:UpdateGlasses()
    end

    function self:OnSave()
        return {
            status = self.status
        }
    end
end)
