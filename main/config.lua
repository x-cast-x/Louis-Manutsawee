local GetModConfigData = GetModConfigData
local ENV = env
GLOBAL.setfenv(1, GLOBAL)

IA_ENABLED = rawget(_G, "IA_CONFIG") ~= nil
PL_ENABLED = rawget(_G, "PL_CONFIG") ~= nil
AD_ENABLED = KnownModIndex:IsModEnabled("workshop-1847959350")
UM_ENABLED = KnownModIndex:IsModEnabled("workshop-2039181790")
HOF_ENABLED = KnownModIndex:IsModEnabled("workshop-2334209327")

M_CONFIG = {
    Locale = GetModConfigData("locale"),
    EnableSkill = GetModConfigData("enable_skill"),
    EnableDodge = GetModConfigData("dodge_enable"),
    IsTatsujin = GetModConfigData("is_tatsujin"),

    CounterAtkCooldown = GetModConfigData("counter_attack_cooldown_time"),
    Skill1Cooldown = GetModConfigData("skill1_cooldown_time"),
    Skill2Cooldown = GetModConfigData("skill2_cooldown_time"),
    Skill3Cooldown = GetModConfigData("skill3_cooldown_time"),
    Skill4Cooldown = GetModConfigData("skill4_cooldown_time"),
    IsshinCooldown = GetModConfigData("isshin_skill_cooldown_time"),
    RyusenSusanooCooldown = GetModConfigData("ryusen_and_susanoo_skill_cooldown_time"),


    Skill1Key = GetModConfigData("skill1_key"),
    Skill2Key = GetModConfigData("skill2_key"),
    Skill3Key = GetModConfigData("skill3_key"),
    Skill4Key = GetModConfigData("skill4_key"),
    LevelCheckKey = GetModConfigData("level_check_key"),
    PutGlassesKey = GetModConfigData("put_glasses_key"),
    ChangeHairStyleKey = GetModConfigData("change_hair_style_key"),
    SkillCancelKey = GetModConfigData("skill_cancel_key"),
    CounterAttackKey = GetModConfigData("counter_attkack_key"),
    QuickSheathKey = GetModConfigData("quick_sheath_key"),

    MaxMindPower = GetModConfigData("max_mind_power"),
    MindRegenCount = GetModConfigData("mindregen_count"),
    MindRegenRate = GetModConfigData("set_mindregen_rate"),
    KenjutsuExpMultiple = GetModConfigData("kenjutsu_exp_multiple"),

    StartWeapon = GetModConfigData("start_weapon"),
    IdleAnimationMode = GetModConfigData("idle_animation_mode"),
}

ENV.IA_ENABLED = IA_ENABLED
ENV.PL_ENABLED = PL_ENABLED
ENV.AD_ENABLED = AD_ENABLED
ENV.UM_ENABLED = UM_ENABLED
ENV.HOF_ENABLED = HOF_ENABLED
ENV.M_CONFIG = M_CONFIG
