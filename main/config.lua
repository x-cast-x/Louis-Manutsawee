local GetModConfigData = GetModConfigData
local ENV = env
GLOBAL.setfenv(1, GLOBAL)

IA_ENABLED = rawget(_G, "IA_CONFIG") ~= nil
PL_ENABLED = rawget(_G, "PL_CONFIG") ~= nil
AD_ENABLED = KnownModIndex:IsModEnabled("workshop-1847959350")
UM_ENABLED = KnownModIndex:IsModEnabled("workshop-2039181790")
HOF_ENABLED = KnownModIndex:IsModEnabled("workshop-2334209327")

M_CONFIG = {
    locale = GetModConfigData("locale"),
    LEVEL_CHECK_KEY = GetModConfigData("levelcheck"),
    ENABLE_SKILL = GetModConfigData("enable_skill"),
    SKILL1_KEY = GetModConfigData("skill1_key"),
    SKILL2_KEY = GetModConfigData("skill2_key"),
    SKILL3_KEY = GetModConfigData("skill3_key"),
    SKILL4_KEY = GetModConfigData("skill4_key"),
    SKILL_COUNTER_ATK_KEY = GetModConfigData("skill_counter_atk"),
    QUICK_SHEATH_KEY = GetModConfigData("quick_sheath_key"),
    SKILL_CANCEL_KEY = GetModConfigData("skill_cancel_key"),
    MINDREGEN_COUNT = GetModConfigData("mindregen_count"),
    MINDREGEN_RATE = GetModConfigData("set_mindregen_rate"),
    COUNTER_ATK_COOLDOWN = GetModConfigData("counter_attack_cooldown_time"),
    SKILL1_COOLDOWN = GetModConfigData("skill1_cooldown_time"),
    SKILL2_COOLDOWN = GetModConfigData("skill2_cooldown_time"),
    SKILL3_COOLDOWN = GetModConfigData("skill3_cooldown_time"),
    SKILL4_COOLDOWN = GetModConfigData("skill4_cooldown_time"),
    ISSHIN_COOLDOWN = GetModConfigData("isshin_skill_cooldown_time"),
    RYUSEN_SUSANOO_COOLDOWN = GetModConfigData("ryusen_and_susanoo_skill_cooldown_time"),
    IS_MASTER = GetModConfigData("is_master"),
    LEVEL_VALUE = GetModConfigData("set_level_value"),
    PUT_GLASSES_KEY = GetModConfigData("put_glasses_key"),
    CHANGE_HAIRS_KEY = GetModConfigData("change_hairs_key"),
    HUNGER = GetModConfigData("set_hunger"),
    HEALTH = GetModConfigData("set_health"),
    SANITY = GetModConfigData("set_sanity"),
    MIND_MAX = GetModConfigData("set_max_mind"),
    HUNGER_MAX = GetModConfigData("set_max_hunger"),
    HEALTH_MAX = GetModConfigData("set_max_health"),
    SANITY_MAX = GetModConfigData("set_max_sanity"),
    KEXPMTP = GetModConfigData("set_kexpmtp"),
    START_ITEM = GetModConfigData("set_start_item"),
    CANCRAFTTENT = GetModConfigData("cancrafttent"),
    CANUSESLINGSHOT = GetModConfigData("canuseslingshot"),
    IDLE_ANIMATION = GetModConfigData("idle_animation"),
    ENABLE_DODGE = GetModConfigData("dodge_enable"),
    DODGE_CD = GetModConfigData("dodge_cd"),
}

ENV.IA_ENABLED = IA_ENABLED
ENV.PL_ENABLED = PL_ENABLED
ENV.UM_ENABLED = UM_ENABLED
ENV.HOF_ENABLED = HOF_ENABLED
ENV.M_CONFIG = M_CONFIG
