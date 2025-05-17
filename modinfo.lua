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

local keylist = {
    {description="TAB", data = 9},
    {description="KP_PERIOD", data = 266},
    {description="KP_DIVIDE", data = 267},
    {description="KP_MULTIPLY", data = 268},
    {description="KP_MINUS", data = 269},
    {description="KP_PLUS", data = 270},
    {description="KP_ENTER", data = 271},
    {description="KP_EQUALS", data = 272},
    {description="MINUS", data = 45},
    {description="EQUALS", data = 61},
    {description="SPACE", data = 32},
    {description="ENTER", data = 13},
    {description="ESCAPE", data = 27},
    {description="HOME", data = 278},
    {description="INSERT", data = 277},
    {description="DELETE", data = 127},
    {description="END", data   = 279},
    {description="PAUSE", data = 19},
    {description="PRINT", data = 316},
    {description="CAPSLOCK", data = 301},
    {description="SCROLLOCK", data = 302},
    {description="RSHIFT", data = 303},
    {description="LSHIFT", data = 304},
    {description="RCTRL", data = 305},
    {description="LCTRL", data = 306},
    {description="RALT", data = 307},
    {description="LALT", data = 308},
    {description="ALT", data = 400},
    {description="CTRL", data = 401},
    {description="SHIFT", data = 402},
    {description="BACKSPACE", data = 8},
    {description="PERIOD", data = 46},
    {description="SLASH", data = 47},
    {description="LEFTBRACKET", data     = 91},
    {description="BACKSLASH", data     = 92},
    {description="RIGHTBRACKET", data = 93},
    {description="TILDE", data = 96},
    {description="A", data = 97},
    {description="B", data = 98},
    {description="C", data = 99},
    {description="D", data = 100},
    {description="E", data = 101},
    {description="F", data = 102},
    {description="G", data = 103},
    {description="H", data = 104},
    {description="I", data = 105},
    {description="J", data = 106},
    {description="K", data = 107},
    {description="L", data = 108},
    {description="M", data = 109},
    {description="N", data = 110},
    {description="O", data = 111},
    {description="P", data = 112},
    {description="Q", data = 113},
    {description="R", data = 114},
    {description="S", data = 115},
    {description="T", data = 116},
    {description="U", data = 117},
    {description="V", data = 118},
    {description="W", data = 119},
    {description="X", data = 120},
    {description="Y", data = 121},
    {description="Z", data = 122},
    {description="F1", data = 282},
    {description="F2", data = 283},
    {description="F3", data = 284},
    {description="F4", data = 285},
    {description="F5", data = 286},
    {description="F6", data = 287},
    {description="F7", data = 288},
    {description="F8", data = 289},
    {description="F9", data = 290},
    {description="F10", data = 291},
    {description="F11", data = 292},
    {description="F12", data = 293},

    {description="UP", data = 273},
    {description="DOWN", data = 274},
    {description="RIGHT", data = 275},
    {description="LEFT", data = 276},
    {description="PAGEUP", data = 280},
    {description="PAGEDOWN", data = 281},

    {description="0", data = 48},
    {description="1", data = 49},
    {description="2", data = 50},
    {description="3", data = 51},
    {description="4", data = 52},
    {description="5", data = 53},
    {description="6", data = 54},
    {description="7", data = 55},
    {description="8", data = 56},
    {description="9", data = 57},
}

local AddSkillKeyOption = function()
    return {

    }
end

configuration_options = {
	AddTitle("Options", "设定"),
    {
        name = "locale",
        label = en_zh("Translation", "翻译"),
        hover = en_zh("Select a translation to enable it regardless of language packs. \n Note: Except for Chinese and English, the rest use Google Translate.", "选择翻译，而不是自动"),
        options =
        {
            {description = en_zh("Auto", "自动"), data = false},
            {description = "Deutsch", data = "de"},
            {description = "Español", data = "es"},
            {description = "Français", data = "fr"},
            {description = "Italiano", data = "it"},
            {description = "한국어", data = "ko"},
            {description = "Polski", data = "pl"},
            {description = "Português", data = "pt"},
            {description = "Русский", data = "ru"},
            {description = "中文 (简体)", data = "sc"},
            {description = "中文 (繁体)", data = "tc"},
            {description = "中文 (粤语)", data = "ct"},
        },
        default = false,
    },
	{
        name = "start_weapon",
        label = en_zh("Start Weapon", "初始武器"),
        hover = en_zh("Choose a starting weapon for your girl!", "为你的少女选择初始武器！"),
        options = {
            {description = en_zh("Nothing", "两手空空"), data = false},
			{description = en_zh("Shinai", "竹刀"), data = "shinai"},
            {description = en_zh("Raikiri", "雷切"), data = "raikiri"},
            {description = en_zh("Yasha", "夜叉"), data = "shirasaya"},
            {description = en_zh("Sakakura", "阪倉"), data = "koshirae"},
            {description = en_zh("hitokiri", "人斩"), data = "hitokiri"},

            {description = en_zh("Raikiri The Lightning Cutter", "雷切·雷光斩"), data = "true_raikiri"},
            {description = en_zh("Yasha The Demon Slayer", "夜叉·妖魔杀手"), data = "true_shirasaya"},
            {description = en_zh("Sakakura The Giant Slayers", "阪倉·巨人屠戮者"), data = "true_koshirae"},
            {description = en_zh("Nihiru The Bloodseeker", "逆流·嗜血猎手"), data = "true_hitokiri"},

			{description = en_zh("Mortal Blade", "拜泪·不死斩"), data = "mortalblade"},
			{description = en_zh("Shusui", "秋水"), data = "shusui"},
			{description = en_zh("Kage", "影"), data = "kage"},
        },
        default = false,
    },
    {
        name = "idle_animation_mode",
        label = en_zh("Idle Animation", "空闲动画"),
        hover = en_zh("Default mode: Each skin has a separate idle animation. \n Random mode: Idle animations are played randomly.", "默认模式: 每个皮肤都有单独的空闲动画 \n 随机模式: 随机播放空闲动画"),
        options = {
            {description = en_zh("Default", "默认"), data = "Default"},
            {description = en_zh("Random", "随机"), data = "Random"},
            {description = en_zh("Disable", "关闭"), data = false},
        },
        default = "Default",
    },
    {
        name = "dodge_enable",
        label = en_zh("Dodge Ability", "闪避技能"),
        hover = en_zh("Left click to dodge to the mouse direction.", "左键点击闪避到鼠标方向位置"),
        options = options_enable,
        default = false,
    },

    AddTitle(en_zh("Custom Kenjutsu", "自定义剑术")),
    {
        name = "max_mind_power",
        label = en_zh("Set Mind  󰀈", "设置能量点 󰀈") ,
        hover = en_zh("Set Mind when start. level max + 20", "设置起始能量点, 最大20。"),
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
        label = en_zh("Mind 󰀈 Regen half of max / seccond ", "󰀈恢复最大的一半/秒") ,
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
        name = "kenjutsu_exp_multiple",
        label = en_zh("Kenjutsu EXP Multiple", "剑术经验获取倍率"),
        hover = en_zh("fast Kenjutsu exp gain", "勤能补拙，风灵月影亦能！"),
        options = {
            {description="x1", data = 1},
            {description="x2", data = 2},
            {description="x3", data = 3},
            {description="x4", data = 4},
            {description="x5", data = 5},
            {description="x6", data = 6},
            {description="x7", data = 7},
            {description="x8", data = 8},
            {description="x9", data = 9},
            {description="x10", data = 10},
        },
        default = 1,
    },
	{
        name = "is_tatsujin",
        label = en_zh("Set Kenjutsu Level", "剑术大师"),
        hover = en_zh("Set kenjutsu level at start", "直接成为剑术大师！"),
        options = options_enable,
        default = false,
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
    },
	{
        name = "skill2_key",
        label = en_zh("Skill2:Button", "技能2 按键"),
        hover = en_zh("Skill2", "技能2"),
        default = "C",
        options = keylist,
    },
	{
        name = "skill3_key",
        label = en_zh("Skill3:Button", "技能3 按键"),
        hover = en_zh("Skill3", "技能3"),
        default = "T",
        options = keylist,
    },
    {
        name = "skill4_key",
        label = en_zh("Skill4:Button", "技能4 按键"),
        hover = en_zh("Skill4", "技能4"),
        default = "H",
        options = keylist,
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
        name = "counter_attkack_key",
        label = en_zh("Counter Attack Skill:Button", "反击技能 按键"),
        hover = en_zh("Counter Attack", "反击技能"),
        default = "Z",
        options = keylist,
    },
	{
        name = "quick_sheath_key",
        label = en_zh("Quick Sheath Katana", "快速收拔刀 按键"),
        hover = en_zh("Quick Sheath Katana", "快速收拔刀"),
        default = "X",
        options = keylist,
    },
	{
        name = "skill_cancel_key",
        label = en_zh("Skill Cancel", "技能取消 按键"),
        hover = en_zh("Cancel all skill", "技能取消"),
        default = "V",
        options = keylist,
    },
    {
        name = "put_glasses_key",
        label = en_zh("EyeGlasses 󰀅", "眼镜"),
        hover = en_zh("wear eyeglasses.", "戴眼镜按键"),
        default = 111,
        options = keylist,
    },
	{
        name = "change_hair_style_key",
        label = en_zh("Change Hair Style 󰀖", "改变发型"),
        hover = en_zh("Choose a beautiful hairstyle for your girl!", "为你的少女选择好看的发型！"),
        default = 108,
        options = keylist,
    },
	{
        name = "level_check_key",
        label = en_zh("Show Level  󰀙", "查看人物等级"),
        hover = en_zh("This is the key use to Show level.", "查看人物等级按键"),
        default = "P",
        options = keylist,
    },
}
