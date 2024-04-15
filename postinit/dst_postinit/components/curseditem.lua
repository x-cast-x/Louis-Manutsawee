local Curseditem = require("components/curseditem")
GLOBAL.setfenv(1, GLOBAL)

local _Given = Curseditem.Given
function Curseditem:Given(item, data)
    local player = data.owner
    if player ~= nil and player.components.cursable ~= nil and player:HasTag("naughtychild") then
        self.target = nil
        return
    end

    _Given(self, item, data)
end