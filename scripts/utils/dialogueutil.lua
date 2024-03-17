local PopupDialogScreen = require("screens/redux/popupdialog")

local function PushDialogueScreen(inst, str, onconfirm, oncancel)
    local OnConfirm = function()
        if onconfirm ~= nil then
            onconfirm(inst)
        end

        TheFrontEnd:PopScreen()
    end

    local OnCANCEL = function()
        if oncancel ~= nil then
            oncancel(inst)
        end

        TheFrontEnd:PopScreen()
    end

    local confirmation = PopupDialogScreen(str.TITLE, str.BODY, {
        { text = str.OK,     cb = OnConfirm },
        { text = str.CANCEL, cb = OnCANCEL  },
    })

    TheFrontEnd:PushScreen(confirmation)
end

return {
    PushDialogueScreen = PushDialogueScreen,
}
