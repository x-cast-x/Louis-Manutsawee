return Class(function(self, inst)

    self.inst = inst

    local idle_anim_mode = M_CONFIG.IDLE_ANIMATION
    local Idle_Anim = nil
    local Funny_Idle_Anim = nil

    local function CustomIdleAnimFn(inst)
        if idle_anim_mode == "Random" then
            return Idle_Anim ~= nil and Idle_Anim[math.random(1, #Idle_Anim)]
        elseif idle_anim_mode == "Default" then
            local build = inst.AnimState:GetBuild()
            local idle_anim = Idle_Anim ~= nil and Idle_Anim[build]
            local item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

            return (build == "manutsawee" and item ~= nil and item.prefab == "bernie_inactive" and "idle_willow" or "idle_wilson") or (idle_anim ~= nil and idle_anim) or nil
        end
    end

    local function CustomIdleStateFn(inst)
        if idle_anim_mode == "Random" then
            return Funny_Idle_Anim ~= nil and Funny_Idle_Anim[math.random(1, #Funny_Idle_Anim)]
        elseif idle_anim_mode == "Default" then
            local build = inst.AnimState:GetBuild()
            local funny_idle_anim = Funny_Idle_Anim ~= nil and Funny_Idle_Anim[build]
            return funny_idle_anim ~= nil and funny_idle_anim or nil
        end
    end

    function self:SetIdleAnim(idle_anim, funny_idle_anim)
        if idle_anim ~= nil and type(idle_anim) == "table" then
            Idle_Anim = idle_anim
        end
        if funny_idle_anim ~= nil and type(funny_idle_anim) == "table" then
            Funny_Idle_Anim = funny_idle_anim
        end
    end

    if not idle_anim_mode then
        return
    end

    inst.customidleanim = CustomIdleAnimFn
    inst.customidlestate = CustomIdleStateFn
end)
