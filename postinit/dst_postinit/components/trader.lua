local Trader = require("components/trader")
GLOBAL.setfenv(1, GLOBAL)

function Trader:SetOnRefuse(fn)
    self.onrefuse = fn
end
