local AddTaskPreInit = AddTaskPreInit
GLOBAL.setfenv(1, GLOBAL)

AddTaskPreInit("Forest hunters", function(task)
    if task.room_choices ~= nil then
        task.room_choices["DevCemetery"] = 1
    end
end)
