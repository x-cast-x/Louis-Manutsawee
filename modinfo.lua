local function en_zh(en, zh)
    return (locale == "zh" or locale == "zhr" or locale == "zht") and zh or en
end

name = "Louis Manutsawee"

folder_name = folder_name or "workshop-"
if not folder_name:find("workshop-") then
    name = name .. " - Dev"
end

version = "3.0"
changelog = ""
-- en_zh([[
-- - Added 4 skins
-- - Added some content (explore by yourself)
-- - Optimize code
-- ]], [[
-- - 添加了4款皮肤
-- - 添加了一些内容(自行探索)
-- - 添加了汉化(不全, 慢慢优化)
-- - 优化代码
-- ]])

description = en_zh("Version: ", "版本: ") .. version ..
en_zh("\n\nChanges:\n", "\n\n更新内容:\n") .. changelog .. "\n" ..
en_zh("- Original author:#ffffff", "原作者:#ffffff")

author = en_zh("Sydney", "悉尼")

forumthread = ""

api_version = 10
priority = -1

dst_compatible = true

dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = false
all_clients_require_mod = true

mod_dependencies = {
    {
        workshop = "workshop-2521851770",    -- Glassic API
        ["GlassicAPI"] = false,
        ["Glassic API - DEV"] = false,
    },
}

icon_atlas = "images/modicon.xml"
icon = "modicon.tex"

server_filter_tags = {
    "M.louis",
    "Louis",
    "Manutsawee",
}

local options_enable = {
    {description = en_zh("Disabled", "关闭"), data = false},
    {description = en_zh("Enabled", "开启"), data = true},
}

local function AddTitle(title_en, title_zh)  --hover does not work, as this item cannot be hovered
    return {name = en_zh(title_en, title_zh) , options = {{description = "", data = false}}, default = false}
end

local keys = {"TAB","KP_0","KP_1","KP_2","KP_3","KP_4","KP_5","KP_6","KP_7","KP_8","KP_9","KP_PERIOD","KP_DIVIDE","KP_MULTIPLY","KP_MINUS","KP_PLUS","KP_ENTER","KP_EQUALS","MINUS","EQUALS","SPACE","ENTER",--[["ESCAPE",]]"HOME","INSERT","DELETE","END","PAUSE","PRINT","CAPSLOCK","SCROLLOCK","RSHIFT","LSHIFT","RCTRL","LCTRL","RALT","LALT","LSUPER","RSUPER","ALT","CTRL","SHIFT","BACKSPACE","PERIOD","SLASH","SEMICOLON","LEFTBRACKET","BACKSLASH","RIGHTBRACKET","TILDE","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12","UP","DOWN","RIGHT","LEFT","PAGEUP","PAGEDOWN","0","1","2","3","4","5","6","7","8","9"}
local keylist = {}
for i = 1, #keys do
    keylist[i] = {description = keys[i], data = "KEY_"..keys[i]}
end
keylist[#keylist + 1] = {description = "Disabled", data = false}

configuration_options = {
	AddTitle("Options", "设定"),
    {
        name = "locale",
        label = en_zh("Translation", "翻译"),
        hover = en_zh("Select a translation to enable it regardless of language packs.", "选择翻译，而不是自动"),
        options =
        {
            {description = en_zh("Auto", "自动"), data = false},
            -- talk about it later
            -- {description = "Deutsch", data = "de"},
            -- {description = "Español", data = "es"},
            -- {description = "Français", data = "fr"},
            -- {description = "Italiano", data = "it"},
            -- {description = "한국어", data = "ko"},
            -- {description = "Polski", data = "pl"},
            -- {description = "Português", data = "pt"},
            -- {description = "Русский", data = "ru"},
            {description = "中文 (简体)", data = "sc"},
            {description = "中文 (繁体)", data = "tc"},
            {description = "中文 (粤语)", data = "ct"},
        },
        default = false,
    },
    {
        name = "Girl's qualities",
        label = en_zh("", ""),
        hover = en_zh("", ""),
        options = {
            { description = en_zh("普通女孩", "Ordinary Girl"), data = "Ordinary" },
            { description = en_zh("聪明女孩", "Smart Girl"), data = "Smart" },
            { description = en_zh("天才女孩", "Genius Girl"), data = "Genius" },
        },
        default = "Smart",
    },
	{
        name = "set_start_item",
        label = en_zh("Start Item", "两手空空（默认）"),
        hover = en_zh("Select item when select character", "选择你的开始物品"),
        options = {
            {description = en_zh("Nothing", "两手空空（默认）"), data = false},
			{description = "Shinai", data = "shinai"},
			{description = "Katanablade", data = "katanablade"},

            {description = "Raikiri", data = "raikiri"},
            {description = "Yasha", data = "shirasaya"},
            {description = "Sakakura", data = "koshirae"},
            {description = "hitokiri", data = "hitokiri"},

            {description = "Raikiri The Lightning Cutter", data = "true_raikiri"},
            {description = "Yasha The Demon Slayer", data = "true_shirasaya"},
            {description = "Sakakura The Giant Slayers", data = "true_koshirae"},
            {description = "Nihiru The Bloodseeker", data = "true_hitokiri"},

            {description = "Tenseiga", data = "tenseiga"},
			{description = "Mortalblade", data = "mortalblade"},
			{description = "Shusui", data = "shusui"},
			{description = "Kage", data = "kage"},
        },
        default = false,
    },
	AddTitle("Boy Scouts", "童子军"),
	{
        name = "cancrafttent",
        label = en_zh("Portable-tent Craftable", "可以制作便携式帐篷"),
        hover = en_zh("Portable-tent Craftable", "可以制作便携式帐篷"),
        options = options_enable,
        default = false,
    },
	{
        name = "canuseslingshot",
        label = en_zh("Slingshot usable", "可以使用弹弓"),
        hover = en_zh("Slingshot usable", "可以使用弹弓"),
        options = options_enable,
        default = false,
    },
    AddTitle(en_zh("Custom Kenjutsu", "自定义剑术")),
    {
        name = "set_max_mind",
        label = en_zh("Set Mind  󰀈", "设置能量点 󰀈") ,
        hover = en_zh("Set Mind when start. level max + 20", "设置起始能量点, 最大20"),
        options = {
            {description="2", data = 2},
            {description="3", data = 3},
            {description="4", data = 4},
            {description="5", data = 5},
            {description="6", data = 6},
            {description="7", data = 7},
            {description="8", data = 8},
            {description="9", data = 9},
            {description="10", data = 10},
            {description="15", data = 15},
            {description="20", data = 20},
        },
        default = 2,
    },
	{
        name = "set_mindregen_rate",
        label = en_zh("Mind  󰀈 Regen half of max / seccond ", "󰀈恢复最大的一半/秒") ,
        hover = en_zh("Mind regenaration unlock level 4.", "心灵再生解锁4级"),
        options = {
			{description="10", data = 10},
            {description="20", data = 20},
            {description="30", data = 30},
            {description="60", data = 60},
            {description="90", data = 90},
            {description="120", data = 120},
            {description="150", data = 150},
            {description="180", data = 180},
            {description="210", data = 210},
            {description="240", data = 240},
            {description="270", data = 270},
            {description="300", data = 300},
            {description="360", data = 360},
            {description="420", data = 420},
        },
        default = 300,
    },
    {
        name = "mindregen_count",
        label = en_zh("Mind  󰀈 Regen / hit", "每次攻击恢复心灵"),
        hover = en_zh("Mind regen/hit that attack with katana", "心灵恢复/用武士刀攻击该攻击"),
        options = {
            {description="4", data = 4},
            {description="6", data = 6},
            {description="8", data = 8},
            {description="10", data = 10},
            {description="12", data = 12},
            {description="14", data = 14},
            {description="16", data = 16},
            {description="18", data = 18},
            {description="20", data = 20},
        },
        default = 10,
    },
	{
        name = "set_kexpmtp",
        label = en_zh("Kenjutsu EXP Multiple", "剑术经验获取倍率"),
        hover = en_zh("fast Kenjutsu exp gain", "勤能补拙，风灵月影亦能！"),
        options = {
            {description="x1", data = 1},
            {description="x2", data = 2},
            {description="x3", data = 3},
            {description="x4", data = 4},
            {description="x5", data = 5},
        },
        default = 1,
    },
	{
        name = "is_master",
        label = en_zh("Set Kenjutsu Level", "允许设定初始剑术等级"),
        hover = en_zh("Set kenjutsu level at start", "游戏开始时设定初始剑术等级"),
        options = options_enable,
        default = false,
    },
	{
        name = "set_level_value",
        label = en_zh("Kenjutsu Level", "设置初始剑术等级"),
        hover = en_zh("Set Kenjutsu Level.", "设置初始剑术等级") ,
        options = {
            {description="1", data = 1},
            {description="2", data = 2},
            {description="3", data = 3},
            {description="4", data = 4},
            {description="5", data = 5},
            {description="6", data = 6},
            {description="7", data = 7},
            {description="8", data = 8},
            {description="9", data = 9},
            {description="10", data = 10},
        },
        default = 1,
    },
    AddTitle("Skill Keys 󰀈", "剑技按键 󰀈"),
	{
        name = "enable_skill",
        label = en_zh("Skill 󰀈", "角色技能 󰀈"),
        hover = en_zh("Turn On or Off Character Skill.", "开启或者关闭角色技能") ,
        options = options_enable,
        default = true,
	},
	{
        name = "skill1_key",
        label = en_zh("Skill1:Button", "技能1 按键"),
        hover = en_zh("Skill1", "技能1"),
        default = "R",
        options = keylist,
        is_keylist = true
    },
	{
        name = "skill2_key",
        label = en_zh("Skill2:Button", "技能2 按键"),
        hover = en_zh("Skill2", "技能2"),
        default = "C",
        options = keylist,
        is_keylist = true
    },
	{
        name = "skill3_key",
        label = en_zh("Skill3:Button", "技能3 按键"),
        hover = en_zh("Skill3", "技能3"),
        default = "T",
        options = keylist,
        is_keylist = true
    },
    {
        name = "skill4_key",
        label = en_zh("Skill4:Button", "技能4 按键"),
        hover = en_zh("Skill4", "技能4"),
        default = "H",
        options = keylist,
        is_keylist = true
    },
	{
        name = "skill_counter_atk",
        label = en_zh("Counter Attack Skill:Button", "反击技能 按键"),
        hover = en_zh("Counter Attack", "反击技能"),
        default = "Z",
        options = keylist,
        is_keylist = true
    },
	{
        name = "quick_sheath_key",
        label = en_zh("Quick Sheath Katana", "快速收拔刀 按键"),
        hover = en_zh("Quick Sheath Katana", "快速收拔刀"),
        default = "X",
        options = keylist,
        is_keylist = true
    },
	{
        name = "skill_cancel_key",
        label = en_zh("Skill Cancel", "技能取消 按键"),
        hover = en_zh("Cancel all skill", "技能取消"),
        default = "V",
        options = keylist,
        is_keylist = true
    },
	{
        name = "counter_attack_cooldown_time",
        label = en_zh("Set Skill Counter Cooldown time(s).", "设置反击技能冷却时间。"),
        hover = en_zh("Set Skill Counter Cooldown time(s).", "设置反击技能冷却时间。"),
        options = {
            {description="0.5", data = .5},
            {description="1", data = 1},
            {description="2", data = 2},
            {description="3", data = 3},
            {description="4", data = 4},
            {description="5", data = 5},
            {description="10", data = 10},
            {description="Default(20)", data = 20},
            {description="30", data = 30},
            {description="40", data = 40},
            {description="50", data = 50},
            {description="60", data = 60},
            {description="120", data = 120},
            {description="180", data = 180},
            {description="240", data = 240},
            {description="300", data = 300},
            {description="360", data = 360},
        },
        default = 20,
    },
	{
        name = "skill1_cooldown_time",
        label = en_zh("Skill 1 Cooldown time(s).", "技能1冷却时间。"),
        hover = en_zh("Skill 1 Cooldown time(s).", "技能1冷却时间。"),
        options = {
			{description="5", data = 5},
            {description="10", data = 10},
            {description="20", data = 20},
            {description="30", data = 30},
            {description="40", data = 40},
			{description="Default(45)", data = 45},
            {description="50", data = 50},
            {description="60", data = 60},
            {description="120", data = 120},
            {description="180", data = 180},
            {description="240", data = 240},
            {description="300", data = 300},
            {description="360", data = 360},
        },
        default = 45,
    },
	{
        name = "skill2_cooldown_time",
        label = en_zh("Skill 2 Cooldown time(s).", "技能2冷却时间。"),
        hover = en_zh("Skill 2 Cooldown time(s).", "技能2冷却时间。"),
        options = {
			{description="5", data = 5},
            {description="10", data = 10},
            {description="20", data = 20},
            {description="30", data = 30},
            {description="40", data = 40},
			{description="Default(45)", data = 45},
            {description="50", data = 50},
            {description="60", data = 60},
            {description="120", data = 120},
            {description="180", data = 180},
            {description="240", data = 240},
            {description="300", data = 300},
            {description="360", data = 360},
        },
        default = 45,
    },
	{
        name = "skill3_cooldown_time",
        label = en_zh("Skill 3 Cooldown time(s).", "技能3冷却时间。"),
        hover = en_zh("Skill 3 Cooldown time(s).", "技能3冷却时间。"),
        options = {
			{description="5", data = 5},
            {description="10", data = 10},
            {description="20", data = 20},
            {description="30", data = 30},
            {description="40", data = 40},
            {description="Default(45)", data = 45},
            {description="50", data = 50},
            {description="60", data = 60},
            {description="120", data = 120},
            {description="180", data = 180},
            {description="240", data = 240},
            {description="300", data = 300},
            {description="360", data = 360},
        },
        default = 45,
    },
    {
        name = "skill4_cooldown_time",
        label = en_zh("Skill 4 Cooldown time(s).", "技能4冷却时间。"),
        hover = en_zh("Skill 4 Cooldown time(s).", "技能4冷却时间。"),
        options = {
			{description="5", data = 5},
            {description="10", data = 10},
            {description="20", data = 20},
            {description="30", data = 30},
            {description="40", data = 40},
            {description="Default(45)", data = 45},
            {description="50", data = 50},
            {description="60", data = 60},
            {description="120", data = 120},
            {description="180", data = 180},
            {description="240", data = 240},
            {description="300", data = 300},
            {description="360", data = 360},
        },
        default = 45,
    },
	{
        name = "isshin_skill_cooldown_time",
        label = en_zh("Tier 2 Skill Cooldown time(s).", "2级技能冷却时间"),
        hover = en_zh("Tier 2 Skill Cooldown time(s).", "2级技能冷却时间"),
        options = {
            {description="50", data = 50},
            {description="60", data = 60},
            {description="Default(90)", data = 90},
            {description="120", data = 120},
            {description="150", data = 150},
            {description="180", data = 180},
            {description="240", data = 240},
            {description="300", data = 300},
            {description="360", data = 360},
        },
        default = 90,
    },
	{
        name = "ryusen_and_susanoo_skill_cooldown_time",
        label = en_zh("Tier 3 Skill Cooldown time(s).", "3级技能冷却时间"),
        hover = en_zh("Tier 3 Skill Cooldown time(s).", "3级技能冷却时间"),
        options = {
            {description="90", data = 90},
            {description="120", data = 120},
            {description="150", data = 150},
            {description="180", data = 180},
            {description="Default(210)", data = 210},
            {description="240", data = 240},
            {description="300", data = 300},
            {description="360", data = 360},
        },
        default = 210,
    },
    AddTitle("Other Keys 󰀮", "其它按键 󰀮"),
    {
        name = "put_glasses_key",
        label = en_zh("EyeGlasses 󰀅", "眼镜"),
        hover = en_zh("wear eyeglasses.", "戴眼镜按键"),
        default = "O",
        options = keylist,
        is_keylist = true
    },
	{
        name = "change_hairs_key",
        label = en_zh("Change Hair Style 󰀖", "改变发型"),
        hover = en_zh("This is the key to Change Hairstyle.", "改变发型按键"),
        default = "L",
        options = keylist,
        is_keylist = true
    },
	{
        name = "levelcheck",
        label = en_zh("Show Level  󰀙", "查看人物等级"),
        hover = en_zh("This is the key use to Show level.", "查看人物等级按键"),
        default = "P",
        options = keylist,
        is_keylist = true
    },
    AddTitle("Other Option", "其它选项"),
    {
        name = "idle_animation",
        label = en_zh("enable idle animation.", "开启空闲动画"),
        hover = en_zh("enable idle animation.", "开启空闲动画"),
        options = {
            {description = en_zh("Default", "默认"), data = "Default"},
            {description = en_zh("Random", "随机"), data = "Random"},
            {description = en_zh("Disable", "关闭"), data = false},
        },
        default = false,
    },
    {
        name = "dodge_enable",
        label = en_zh("enable dodge skill.", "开启滑铲技能"),
        hover = en_zh("enable dodge skill.", "开启滑铲技能"),
        options = options_enable,
        default = false,
    },
    {
        name = "dodge_cd",
        label = en_zh("Set Dodge Skill Cooldown time.", "设置滑铲技能冷却时间"),
        hover = en_zh("Set Dodge Skill Cooldown time.", "设置滑铲技能冷却时间"),
        options = {
            {description="1", data = 1},
            {description="5", data = 5},
            {description="10", data = 10},
            {description="Default(20)", data = 20},
            {description="25", data = 25},
            {description="30", data = 30},
            {description="35", data = 35},
            {description="40", data = 40},
            {description="45", data = 45},
            {description="50", data = 50},
            {description="55", data = 55},
            {description="60", data = 60},
        },
        default = 20,
    },
}
