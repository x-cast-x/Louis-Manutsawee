local Idle_Anim = {
    ["manutsawee_yukatalong"] = "idle_wendy",
    ["manutsawee_yukata"] = "idle_wendy",
    ["manutsawee_shinsengumi"] = "idle_wathgrithr",
    ["manutsawee_fuka"] = "idle_wathgrithr",
    ["manutsawee_sailor"] = "idle_walter",
    ["manutsawee_jinbei"] = "idle_wortox",
    ["manutsawee_maid"] = "idle_wanda",
    ["manutsawee_maid_m"] = "idle_wanda",
    ["manutsawee_lycoris"] = "idle_wanda",
    ["manutsawee_uniform_black"] = "idle_wanda",
    ["manutsawee_taohuu"] = "idle_winona",
    ["manutsawee_miko"] = "emote_impatient",
}

local Funny_Idle_Anim = {
    ["manutsawee_qipao"] = "wes_funnyidle",
    ["manutsawee_bocchi"] = "idle_bocchi",
}

return Class(function(self, inst)
    self.inst = inst

    local idle_anim_mode = M_CONFIG.IDLE_ANIMATION

    local function CustomIdleAnimFn(inst)
        if idle_anim_mode == "Random" then
            return Idle_Anim[math.random(1, #Idle_Anim)]
        elseif idle_anim_mode == "Default" then
            local build = inst.AnimState:GetBuild()
            local idle_anim = Idle_Anim[build]

            if build == "manutsawee" then
                local item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                return item ~= nil and item.prefab == "bernie_inactive" and "idle_willow" or "idle_wilson"
            else
                return idle_anim ~= nil and idle_anim or nil
            end
        end
    end

    local function CustomIdleStateFn(inst)
        if idle_anim_mode == "Random" then
            return Funny_Idle_Anim[math.random(1, #Funny_Idle_Anim)]
        elseif idle_anim_mode == "Default" then
            local build = inst.AnimState:GetBuild()
            local funny_idle_anim = Funny_Idle_Anim[build]
            return funny_idle_anim ~= nil and funny_idle_anim or nil
        end
    end

    function self:SetUp()
        inst.customidleanim = CustomIdleAnimFn
        inst.customidlestate = CustomIdleStateFn
    end

end)
