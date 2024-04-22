local SkinsPuppet = require("widgets/skinspuppet")
GLOBAL.setfenv(1, GLOBAL)

local yukata_idle = {
    fn = function(self)
        self.override_build = "player_idles_wendy"
        self.animstate:AddOverrideBuild(self.override_build)
    end,
    anim = "idle_wendy"
}

local balloon_color = {
    "blue",
    "green",
    "orange",
    "red",
    "purple",
    "yellow"
}

local M_Idle_Anim = {
    ["manutsawee"] = "idle_wilson",
    ["manutsawee_shinsengumi"] = "idle_wathgrithr",
    ["manutsawee_fuka"] = "idle_wathgrithr",
    ["manutsawee_sailor"] = "idle_walter",
    ["manutsawee_jinbei"] = "idle_wortox",
    ["manutsawee_taohuu"] = "idle_winona",
    ["manutsawee_miko"] = "emote_impatient",
    ["manutsawee_bocchi"] = "emote_impatient",
    ["manutsawee_yukatalong_purple"] = yukata_idle,
    ["manutsawee_yukatalong"] = yukata_idle,
    ["manutsawee_yukata"] = yukata_idle,

    ["manutsawee_qipao"] = {
        fn = function(self)
            self.override_build = "player_idles_wes"
            self.animstate:AddOverrideBuild(self.override_build)
            self.animstate:OverrideSymbol("balloon_red", "player_idles_wes", "balloon_" .. balloon_color[math.random(1, #balloon_color)])
        end,
        anim = "idle_wes"
    },
    ["manutsawee_maid"] = {
        fn = function(self)
            self.override_build = "player_idles_wanda"
            self.animstate:AddOverrideBuild(self.override_build)
        end,
        anim = "idle_wanda"
    },
    ["manutsawee_maid_m"] = {
        fn = function(self)
            self.override_build = "player_idles_wanda"
            self.animstate:AddOverrideBuild(self.override_build)
        end,
        anim = "idle_wanda"
    },
    ["manutsawee_uniform_black"] = {
        fn = function(self)
            self.override_build = "player_idles_wanda"
            self.animstate:AddOverrideBuild(self.override_build)
        end,
        anim = "idle_wanda"
    },
    ["manutsawee_lycoris"] = {
        fn = function(self)
            self.override_build = "player_idles_wanda"
            self.animstate:AddOverrideBuild(self.override_build)
        end,
        anim = "idle_wanda"
    },
}

-- luajit2 compatible
local _DoIdleEmote = SkinsPuppet.DoIdleEmote
function SkinsPuppet:DoIdleEmote(...)
    local r = math.random()
    if r > 0.3 then
        local skin = self.last_skins.base_skin
        local emote_anim = M_Idle_Anim[skin]
        if self.prefabname == "manutsawee" and emote_anim ~= nil then
            if checkentity(emote_anim) then
                local fn = emote_anim.fn
                emote_anim = emote_anim.anim
                fn(self)
            end

            self:DoEmote(emote_anim, false, true)
            return
        end
    end

    if _DoIdleEmote ~= nil then
        return _DoIdleEmote(self, ...)
    end
end
