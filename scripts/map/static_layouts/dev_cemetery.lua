return {
    version = "1.1",
    luaversion = "5.1",
    orientation = "orthogonal",
    width = 12,
    height = 12,
    tilewidth = 16,
    tileheight = 16,
    properties = {},
    tilesets = {
        {
            name = "tiles",
            firstgid = 1,
            tilewidth = 64,
            tileheight = 64,
            spacing = 0,
            margin = 0,
            image = "../../../../../tools/tiled/dont_starve/tiles.png",
            imagewidth = 512,
            imageheight = 384,
            properties = {},
            tiles = {}
        }
    },
    layers = {
        {
            type = "tilelayer",
            name = "BG_TILES",
            x = 0,
            y = 0,
            width = 12,
            height = 12,
            visible = true,
            opacity = 1,
            properties = {},
            encoding = "lua",
            data = {
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
            }
        },
        {
            type = "objectgroup",
            name = "FG_OBJECTS",
            visible = true,
            opacity = 1,
            properties = {},
            objects = {
                {
                    name = "Sydney",
                    type = "gravestone",
                    shape = "rectangle",
                    x = 22,
                    y = 22,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {
                        ["data.setepitaph"] = "Sydney"
                    }
                },
                {
                    name = "#ffffff",
                    type = "gravestone",
                    shape = "rectangle",
                    x = 1,
                    y = 1,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {
                        ["data.setepitaph"] = "ffffff"
                    }
                },
                {
                    name = "",
                    type = "tenseiga",
                    shape = "rectangle",
                    x = 22,
                    y = 22,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
            }
        }
    }
}
