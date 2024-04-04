STRINGS.DEV_EPITAPHS = {}
STRINGS.DEV_EPITAPHS.SYDNEY = {
    -- these epitaphs reference lines spoken by the beggar in Kung Fu Hustle :P
    "\nHey, my friend, I see you have extraordinary talent, you are a rare genius.\nIt's up to you to maintain the peace of the underworld.\nI have a katana here called tenseiga.\nI see that you are destined for it, so I will give it to you directly, provided you can pick it up.",
    "\nWow, incredible!\nYou have a flash of inspiration bursting out of your head, you know?\nDespite your young age, you have remarkable aptitude.\nYou are a prodigy rarely seen even once in ten thousand years!\nAs the saying goes: If I don't enter the underworld, who will?\nI'll leave the task of maintaining peace in the underworld to you. Okay?\nThis Tensaiga is a priceless treasure.\nI see that we are fated, so I shall bestow it upon you, as long as you can lift it",
    -- these epitaphs come from 长城 of the album Belief of the Hong Kong band Beyond
    "\n\"Cover ears, Close eyes, Deceive self.\"",
    "\n\"Around the aging country, around the truth of the facts, around the vast years, around desire and ideals\"",
    -- Google's former motto
    "\n\"Don't be evil",

    -- nothing
    "\n\"This is a tombstone I built for myself.\"",
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
                        ["data.setepitaph"] = "Sydney" .. STRINGS.DEV_EPITAPHS.SYDNEY[math.random(1, #STRINGS.DEV_EPITAPHS.SYDNEY)]
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
