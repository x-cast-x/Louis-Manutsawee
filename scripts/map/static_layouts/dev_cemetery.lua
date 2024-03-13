-- STRINGS.M_EPITAPHS = {
--     "\n这位朋友我看你骨骼精奇,是万中无一的奇才.\n维护冥界和平就靠你了.\n我这里有把天生牙.\n我看与你有缘,就直接送给你了,前提是你能拿起来.",
--     "\n哇,不得了,不得了啊!\n你有道灵光从天顶盖喷出来,你知道吗?\n年纪轻轻的,就有一身清奇的骨骼.\n简直万年一见的奇才啊!\n正所谓:我不入冥界,谁入冥界.\n维护冥界和平这个任务就交给你了,好吗?\n这把天生牙,是无价之宝.\n我看与你有缘,就送给你吧,前提是你能拿起来."
-- }

STRINGS.M_EPITAPHS = {
    -- These epitaphs reference lines spoken by the beggar in Kung Fu Hustle :P
    "\nHey, my friend, I see you have extraordinary talent, you are a rare genius.\nIt's up to you to maintain the peace of the underworld.\nI have a katana here called tenseiga.\nI see that you are destined for it, so I will give it to you directly, provided you can pick it up.",
    "\nWow, incredible!\nYou have a flash of inspiration bursting out of your head, you know?\nDespite your young age, you have remarkable aptitude.\nYou are a prodigy rarely seen even once in ten thousand years!\nAs the saying goes: If I don't enter the underworld, who will?\nI'll leave the task of maintaining peace in the underworld to you. Okay?\nThis Tensaiga is a priceless treasure.\nI see that we are fated, so I shall bestow it upon you, as long as you can lift it"
}

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
                        ["data.setepitaph"] = "Sydney" .. STRINGS.M_EPITAPHS[math.random(1,2)]
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
                        ["data.setepitaph"] = "#ffffff"
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
