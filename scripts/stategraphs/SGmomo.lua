require("stategraphs/commonstates")

local actionhandlers = {

}

local events = {
    EventHandler("admitdefeated", function(inst, data)
    end),
    EventHandler("taunt", function(inst, data)
    end),
}

local states = {
    State{
        name = "idle",
        tags = {"idle", "canrotate"},
    }
}

return StateGraph("momo", states, events, "idle")
