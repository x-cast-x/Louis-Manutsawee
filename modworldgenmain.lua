local modimport = modimport
local TUNING = TUNING
GLOBAL.setfenv(1, GLOBAL)

local IsTheFrontEnd = rawget(_G, "TheFrontEnd") and rawget(_G, "IsInFrontEnd") and IsInFrontEnd()
if IsTheFrontEnd then return end

modimport("postinit/reignofgiants/map/tasks/dst_tasks_forestworld")
modimport("scripts/map/m_layouts")
modimport("scripts/map/rooms/dev_cemetery")

modimport("main/config")
-- local required_prefabs = {"chester_eyebone", "spawnpoint_master",}

-- local function DesertOnly(tasksetdata) -- DesertOnly
--     tasksetdata.numoptionaltasks = 0
--     tasksetdata.tasks = {"Desert Start","Desert King","Badlands","Lightning Bluff", "Oasis", "Quarrelious Desert"}
--     tasksetdata.optionaltasks = {}
--     tasksetdata.set_pieces = {
--             ["ResurrectionStoneWinter"] = { count=1, tasks={"Desert Start","Desert King","Badlands","Lightning Bluff", "Oasis", "Quarrelious Desert"}},
--     }
--     tasksetdata.required_setpieces = {}
--     tasksetdata.numrandom_set_pieces = 0
--     tasksetdata.ocean_prefill_setpieces = {} -- delete any ocean stuff
--     tasksetdata.ocean_population = {} -- delete any ocean stuff
--     if not tasksetdata.required_setpieces then
--         tasksetdata.required_setpieces = {}
--     end
--     --[==[
--     for _,set in pairs(GLOBAL.TUNING.TELEPORTATOMOD.teleportato_layouts["forest"]) do
--         table.insert(tasksetdata.required_setpieces,set)
--     end
--     --]==]
--     tasksetdata.random_set_pieces = {}
--     tasksetdata.add_teleportato = true -- add teleportato within teleportato mod. ypu can set up _G.TUNING.TELEPORTATOMOD.teleportato_layouts to change the setpieces of them
--     tasksetdata.required_prefabs = GLOBAL.ArrayUnion(required_prefabs,{"teleportato_base","teleportato_box","teleportato_crank","teleportato_ring","teleportato_potato"}) -- if ordered_story_setpieces is nil/empty, required_prefabs is set up in teleoprtato mod depending in settings there
--     tasksetdata.overrides={
--         wormhole_prefab = "wormhole",
--         layout_mode = "LinkNodesByKeys",
--         start_location = "desertstart",
--         roads = "never"
--     }
--     return tasksetdata
-- end

-- local function CaveOnly(tasksetdata)
--     tasksetdata.required_prefabs = ArrayUnion(required_prefabs, {"teleportato_base","teleportato_box","teleportato_crank","teleportato_ring","teleportato_potato"})
-- end

-- local function AlwaysTinyCave(tasksetdata) -- even if cave was enabled, make it always very tiny, cause we dont need it
--     tasksetdata.tasks = {"CaveExitTask1"}
--     tasksetdata.numoptionaltasks = 0
--     tasksetdata.optionaltasks = {}
--     tasksetdata.set_pieces = {}
--     tasksetdata.valid_start_tasks = {"CaveExitTask1"}
--     if tasksetdata.overrides == nil then
--         tasksetdata.overrides = {}
--     end
--     tasksetdata.overrides.world_size  =  "small"
--     tasksetdata.overrides.wormhole_prefab = "wormhole"
--     tasksetdata.overrides.layout_mode = "LinkNodesByKeys"
--     return tasksetdata
-- end

-- if TUNING.TELEPORTATOMOD ~= nil then
--     table.insert(TUNING.TELEPORTATOMOD.WORLDS, {name="The Badlands", taskdatafunctions={forest = CaveOnly, cave = AlwaysTinyCave}, defaultpositions={2,3,4,5},positions="2,3,4,5"})
-- end
