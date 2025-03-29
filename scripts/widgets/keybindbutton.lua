-- designed by Tony.
-- Personal Changed by Sydney.

local Widget = require "widgets/widget"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local PopupDialogScreen = require "screens/redux/popupdialog"

local DEFAULT_WIDTH = 220
local DEFAULT_HEIGHT = 40

local KeyBindButton = Class(Widget, function(self, width, height, valid_keys, default, initial_value, can_no_toggle_key)
    Widget._ctor(self, "KeyBindButton")

    self:SetValidKeylist(valid_keys or {})

    self.default = default
    self.initial_value = initial_value
    self.can_no_toggle_key = can_no_toggle_key

    local button_width = width or DEFAULT_WIDTH
    local button_height = height or DEFAULT_HEIGHT

    self.changed_image = self:AddChild(Image("images/global_redux.xml", "wardrobe_spinner_bg.tex"))
    self.changed_image:SetTint(1, 1, 1, 0.3)
    self.changed_image:ScaleToSize(button_width, button_height)
    self.changed_image:Hide()

    self.binding_btn = self:AddChild(ImageButton("images/global_redux.xml", "blank.tex", "spinner_focus.tex"))
    self.binding_btn:ForceImageSize(button_width, button_height)
    self.binding_btn:SetTextColour(UICOLOURS.GOLD_CLICKABLE)
    self.binding_btn:SetTextFocusColour(UICOLOURS.GOLD_FOCUS)
    self.binding_btn:SetFont(CHATFONT)
    self.binding_btn:SetTextSize(25)
    self.binding_btn:SetOnClick(function() self:MapControl() end)

    self.binding_btn:SetHelpTextMessage(STRINGS.UI.CONTROLSSCREEN.CHANGEBIND)
    self.binding_btn:SetDisabledFont(CHATFONT)

    self:SetVal(self.initial_value)

    self.focus_forward = self.binding_btn
end)

function KeyBindButton:TryConvertOption(val)
    return type(val) == "string" and rawget(_G, val) or val
end

function KeyBindButton:SetValidKeylist(keys)
    self.valid_keys = {}
    self.key_ref = {} -- Make a reference table for converting control id back to option name/glboal variable name
    for _, v in ipairs(keys) do
        local num = self:TryConvertOption(v)
        self.valid_keys[num] = true
        self.key_ref[num] = v
    end
end

function KeyBindButton:GetValDisplayName(val)
    val = self:TryConvertOption(val)
    if val == "no_toggle_key" then
        return STRINGS.UI.CONTROLSSCREEN.INPUTS[9][2]
    elseif type(val) == "string" then
        return val:len() > 0 and val or STRINGS.UI.CONTROLSSCREEN.INPUTS[9][2]
    elseif type(val) == "number" then
        return STRINGS.UI.CONTROLSSCREEN.INPUTS[1][val] or STRINGS.UI.CONTROLSSCREEN.INPUTS[9][2]
    elseif val == false then
        return STRINGS.UI.MODSSCREEN.DISABLE
    end
    return ""
end

function KeyBindButton:SetBindingText(val, raw)
    self.binding_btn:SetText(raw and val or self:GetValDisplayName(val))
end

function KeyBindButton:SetOnSetValFn(fn)
    self.setvalfn = fn
end

function KeyBindButton:SetVal(val, raw)
    if val == nil then
        val = "no_toggle_key"
    end
    self.value = val
    self:SetBindingText(val, raw)
    if val == self.initial_value then
        self.changed_image:Hide()
    else
        self.changed_image:Show()
    end
    if self.setvalfn ~= nil then
        self.setvalfn(val)
    end
end

function KeyBindButton:SetOnChangeValFn(fn)
    self.changevalfn = fn
end

function KeyBindButton:ChangeVal(val)
    if val ~= self.value then
        if self.changevalfn ~= nil then
            self.changevalfn(val, self.value)
        end
        self:SetVal(val)
    end
end

function KeyBindButton:MapControl()
    local default_text = string.format(STRINGS.UI.CONTROLSSCREEN.DEFAULT_CONTROL_TEXT, self:GetValDisplayName(self.default))
    local body_text = STRINGS.UI.CONTROLSSCREEN.CONTROL_SELECT .. "\n\n" .. default_text

    local buttons = {
        {text = STRINGS.UI.MODSSCREEN.DISABLE, cb = function() self:ChangeVal(false) TheFrontEnd:PopScreen() end},
        {text = STRINGS.UI.CONTROLSSCREEN.CANCEL, cb = function() TheFrontEnd:PopScreen() end},
    }

    if self.can_no_toggle_key then
        table.insert(buttons, 2, {text = STRINGS.UI.CONTROLSSCREEN.UNBIND, cb = function() self:ChangeVal("no_toggle_key") TheFrontEnd:PopScreen() end})
    end

    local popup = PopupDialogScreen(self.desc, body_text, buttons)

    popup.OnRawKey = function(_, key, down)
        if not down and self.valid_keys[key] then
            self:ChangeVal(self.key_ref[key])
            TheFrontEnd:PopScreen()
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
            return true
        end
    end
    for _, item in ipairs(popup.dialog.actions.items) do
        item:ClearFocusDirs()
    end
    popup.default_focus = nil
    TheFrontEnd:PushScreen(popup)
end

return KeyBindButton
