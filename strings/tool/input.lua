mod_path = "F:/Steam/steamapps/common/Don't Starve Together/mods/Louis-Manutsawee"

package.path = package.path .. ";../?.lua"
package.path = package.path .. ";".. mod_path .. "/strings" .. "/?.lua"

keys = {  -- copy key = over key
    ["GENERIC"] = "GENERIC",
    ["MANUTSAWEE"] = "MANUTSAWEE",
    ["ACTIONS"] = "ACTIONS",
    ["NAMES"] = "NAMES",
    ["RECIPE_DESC"] = "RECIPE_DESC",
    ["SKIN_NAMES"] = "SKIN_NAMES",
    ["SKIN_QUOTES"] = "SKIN_QUOTES",
    ["SKIN_DESCRIPTIONS"] = "SKIN_DESCRIPTIONS",
    ["CHARACTER_TITLES"] = "CHARACTER_TITLES",
    ["CHARACTER_NAMES"] = "CHARACTER_NAMES",
    ["CHARACTER_ABOUTME"] = "CHARACTER_ABOUTME",
    ["CHARACTER_DESCRIPTIONS"] = "CHARACTER_DESCRIPTIONS",
    ["CHARACTER_QUOTES"] = "CHARACTER_QUOTES",
    ["CHARACTER_SURVIVABILITY"] = "CHARACTER_SURVIVABILITY",
    ["CHARACTER_BIOS"] = "CHARACTER_BIOS",
    ["M_LOADINGTIPS"] = "M_LOADINGTIPS",
    ["SKILL"] = "SKILL",
}

for k, v in pairs(require "common") do
    keys[k] = k
end

input_strings = {
    ACTIONS = {
        MDODGE = "Dash",
        MDODGE2 = "Dodge",

        CASTSPELL = {
            PULLOUT = "Pull Out",
            INSERT = "Insert",
            SUICIDE = "Suicide",
        },
    },

    NAMES = {
        MANUTSAWEE = "Manutsawee",
        M_SCARF = "Black Scarf",
        MAID_HB = "Louis's headwear",
        M_FOXMASK = "Kitsune Mask",
        MMIKO_ARMOR = "Miko Robe",
        MFRUIT = "Louis's memory fruit",
        MINGOT = "Mysterious Ingot",
        HMINGOT = "Hot Mysterious Ingot",
        KATANABODY = "Katana shape",
        HARAKIRI = "Harakiri",
        SHINAI = "Shinai",
        MNAGINATA = "Naginata",
        YARI = "Yari",
        KATANABLADE = "Katana Blade",
        HITOKIRI = "Nihiru",
        TRUE_HITOKIRI = "Nihiru The Bloodseeker",
        KOSHIRAE = "Sakakura",
        TRUE_KOSHIRAE = "Sakakura The Giant Slayers",
        SHIRASAYA = "Yasha",
        TRUE_SHIRASAYA = "Yasha The Demon Slayer",
        RAIKIRI = "Raikiri",
        TRUE_RAIKIRI = "Raikiri The Lightning Cutter",
        MSURFBOARD_ITEM = "louis's Surf board",
        BOAT_MSURFBOARD = "Louis's Surf board",
        KUROKATANA = "Kurokatana",
        SHUSUI = "Shusui",
        MORTALBLADE = "Mortal Blade",
        TOKIJIN = "Tokijin",
    },

    RECIPE_DESC = {
        M_SCARF = "Black Scarf",
        MAID_HB = "Louis's headwear set.",
        M_FOXMASK = "Fox Mask!",
        MMIKO_ARMOR = "Miko robe for miko skin",
        MINGOT = "Bring it to fire",
        HARAKIRI = "Pay your mistake.",
        SHINAI = "Training Sword.",
        MNAGINATA = "It's Japanese Spear.",
        YARI = "It's Japanese Spear.",
        KATANABLADE = "Sharp katana blade",
        HITOKIRI = "The Bloodseeker",
        TRUE_HITOKIRI = "True Nihiru",
        KOSHIRAE = "The Giant Slayers",
        TRUE_KOSHIRAE = "True Sakakura",
        SHIRASAYA = "The Demon Slayer",
        TRUE_SHIRASAYA = "The Demon Slayer",
        RAIKIRI = "The Lightning Cutter",
        TRUE_RAIKIRI = "True Raikiri",
        MSURFBOARD_ITEM = "louis's Surf board",
        KUROKATANA = "Japanese Sword.",
        SHUSUI = "A Legendary Sword of Wano.",
        MORTALBLADE = "To cut the immortality.",
    },

    SKIN_NAMES = {
        manutsawee_none = "Louis",
        manutsawee_yukata = "Louis Kimono(M) ",
        manutsawee_yukatalong = "Louis Kimono",
        manutsawee_yukatalong_purple = "Louis Kimono(P)",
        manutsawee_fuka = "Louis Cosplay",
        manutsawee_maid = "Louis Maid",
        manutsawee_shinsengumi = "Louis Shinsengumi",
        manutsawee_jinbei = "Louis Jinbei",
        manutsawee_miko = "Louis Miko",
        manutsawee_qipao = "Louis Qipao",
        manutsawee_sailor = "Louis Sailor Uniform",
        manutsawee_taohuu = "Louis Taohuu",
    },

    SKIN_QUOTES = {
        manutsawee_none = "I hate this uniform.",
        manutsawee_yukata = "\"Shine omae! haha.'\"",
        manutsawee_yukatalong = "\"Kon ni chi wa ..?'\"",
        manutsawee_yukatalong_purple = "\"こんにちは？'\"",
        manutsawee_fuka = "\"I'm a kung-fu master now.\"",
        manutsawee_maid = "\"I'm not a maid but i like this.\"",
        manutsawee_shinsengumi = "\"One must not infringe the samurai code!\"",
        manutsawee_jinbei = "\"Relax Feeling good.\"",
        manutsawee_miko = "\"Can i fight with yokai?'\"",
        manutsawee_qipao = "\"Ni hao ..? Good Fortune'\"",
        manutsawee_sailor = "\"So so so... nothing just say so..\"",
        manutsawee_taohuu = "\"I'm cute, please give me money.\"",
    },

    SKIN_DESCRIPTIONS = {
        manutsawee_none = "Thai's school uniform",
        manutsawee_yukata = "Japan's outfit mini version.",
        manutsawee_yukatalong = "Japan's outfit.",
        manutsawee_yukatalong_purple = "Japan's outfit purple version.",
        manutsawee_fuka = "Fu hua hawk of the fog's outfit from honkai impact 3d",
        manutsawee_maid = "Maid's outfit",
        manutsawee_shinsengumi = "Laws of the Shinsengumi\nOne must not infringe the samurai code\nOne is not authorized to escape from office\nOne is not allowed to arbitrarily raise money\nOne must not arbitrarily handle litigations\nOne is not authorized to engage in personal conflicts\n",
        manutsawee_jinbei = "Japan's outfit.",
        manutsawee_miko = "Japan's shrine maiden outfit.",
        manutsawee_qipao = "China's dress",
        manutsawee_sailor = "Japan's school uniform",
        manutsawee_taohuu = "Taohuu",
    },

    CHARACTER_TITLES = {
        manutsawee = "The Red-Eyes Girl",
    },

    CHARACTER_NAMES = {
        manutsawee = "Manutsawee",
    },

    CHARACTER_ABOUTME = {
        manutsawee = "Manutsawee is too long so just louis.",
    },

    CHARACTER_DESCRIPTIONS = {
        manutsawee = "*Art of the Japanese sword\n*Brave\n*Benevolent",
    },

    CHARACTER_QUOTES = {
        manutsawee = "\"Where There's a Will, There's a Way\"",
    },

    CHARACTER_SURVIVABILITY = {
        manutsawee= "󰀕Grim",
    },

    CHARACTER_BIOS = {
        manutsawee = {
            { title = "Birthday", desc = "October 9" },
            { title = "就读学校", desc = "夏威夷什么都学技术学院" },
            { title = "Favorite Food", desc = "Unagi, Bacon and Eggs, Cooked Kelp Fronds, Durian, Roasted durian \nCaliforniaroll, Caviar \nSteamed Ham Sandwich, Tea, Ice Tea \nLiceloaf, Boomberry Pancakes" },
            { title = "Her Past...", desc = "Manutsawee."},
            -- I made it up randomly
            { title = "诅咒之剑", desc = "斗鬼神\n使用悟心鬼的獠牙制成的诅咒之剑, 充满邪气, 一般人极易被其反控制.\n原被杀生丸折断, 但Louis在一所废弃的神社发现了它..."},
        },
    },

    M_LOADINGTIPS = {
        TOKIJIN = "我无法压住它的邪气，无法驾驭斗鬼神 -L",
    },

    SKILL = {
        REFUSE_RELEASE = "I don't wanna do this.",
        -- Skill (1)
        SKILL1START = "ICHI NO KATA!\n󰀈: ",
        SKILL1ATTACK = "ICHIMONJI",

        -- Skill (2)
        SKILL2START = "NI NO KATA!\n󰀈: ",
        SKILL2ATTACK = "HABAKIRI!!",

        -- Skill (3)
        SKILL3START = "SAN NO KATA! \n󰀈: ",
        SKILL3ATTACK = "ONIKIRI!!",

        -- Skill (4)
        SKILL4START = "SHI NO KATA!\n󰀈: ",
        SKILL4ATTACK = "ISSHIN!!",

        -- Skill (5)
        SKILL5START = "GO NO KATA!\n󰀈: ",
        SKILL5ATTACK = "SHINDEN ISSEN!!",

        -- Skill (6)
        SKILL6START = "ROKU NO KATA!\n󰀈: ",
        SKILL6ATTACK = "RYUSEN!!",

        -- Skill (7)
        SKILL7START = "SHICHI NO KATA!\n󰀈: ",
        SKILL7ATTACK = "SUSANOO!!"
    },

    CHARACTERS = {
        GENERIC = require "generic",
        MANUTSAWEE = require "manutsawee",
    }
}

output_path = "../"
file_prefix = ""
output_potpath = "../../scripts/languages/"
output_popath = output_potpath .. file_prefix

-- load in order, the later will overwrite the previous
-- first param is lua table or lua table file's path, the second param is po file path(if is language, will translate), the third param is whether to overwrite the old content
POT_GENERATION = true
data = {  -- lua file path = po file path
    {
        input_strings,  -- input string
        "en",  -- input language , use Google Translate
        override = false,
    }
}
