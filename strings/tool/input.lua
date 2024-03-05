mod_path = "F:/Steam/steamapps/common/Don't Starve Together/mods/Louis-Manutsawee"

package.path = package.path .. ";../?.lua"
package.path = package.path .. ";".. mod_path .. "/strings" .. "/?.lua"

keys = {  -- copy key = over key
    -- ["GENERIC"] = "GENERIC",
    ["MANUTSAWEE"] = "MANUTSAWEE",
    -- ["ACTIONS"] = "ACTIONS",
    -- ["NAMES"] = "NAMES",
    -- ["RECIPE_DESC"] = "RECIPE_DESC",
    -- ["SKIN_NAMES"] = "SKIN_NAMES",
    -- ["SKIN_QUOTES"] = "SKIN_QUOTES",
    -- ["SKIN_DESCRIPTIONS"] = "SKIN_DESCRIPTIONS",
    -- ["CHARACTER_TITLES"] = "CHARACTER_TITLES",
    -- ["CHARACTER_NAMES"] = "CHARACTER_NAMES",
    -- ["CHARACTER_ABOUTME"] = "CHARACTER_ABOUTME",
    -- ["CHARACTER_DESCRIPTIONS"] = "CHARACTER_DESCRIPTIONS",
    -- ["CHARACTER_QUOTES"] = "CHARACTER_QUOTES",
    -- ["CHARACTER_SURVIVABILITY"] = "CHARACTER_SURVIVABILITY",
    -- ["CHARACTER_BIOS"] = "CHARACTER_BIOS",
    -- ["M_LOADINGTIPS"] = "M_LOADINGTIPS",
    -- ["SKILL"] = "SKILL",
}

local common = require "common"

input_strings = {
    CHARACTERS = {
        -- GENERIC = require "generic",
        MANUTSAWEE = require "um_manutsawee",
    }
}

for k, v in pairs(common) do
    input_strings[k] = v
end

output_path = "../"
file_prefix = "um_"
output_potpath = "../../postinit/um_postinit/languages/"
output_popath = output_potpath .. file_prefix

-- load in order, the later will overwrite the previous
-- first param is lua table or lua table file's path, the second param is po file path(if is language, will translate), the third param is whether to overwrite the old content
POT_GENERATION = true
data = {  -- lua file path = po file path
    {
        input_strings,  -- input string
        "zh-CN",  -- input language , use Google Translate
        override = false,
    }
}
