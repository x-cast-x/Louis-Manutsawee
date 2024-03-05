local AddRoom = AddRoom
GLOBAL.setfenv(1, GLOBAL)

AddRoom("DevCemetery", {
    colour={r=.8,g=0.5,b=.6,a=.50},
    value = WORLD_TILES.FOREST,
    tags = { "RoadPoison" },
    contents = {
        countprefabs = {},
        countstaticlayouts={
            ["DevCemetery"] = 1
        },
        distributepercent = .8,
        distributeprefabs = {
        },
    }
})
