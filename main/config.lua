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
    LevelCheckKey = GetModConfigData("levelcheck"),
    EnableSkill = GetModConfigData("enable_skill"),
    Skill1Key = GetModConfigData("skill1_key"),
    Skill2Key = GetModConfigData("skill2_key"),
    Skill3Key = GetModConfigData("skill3_key"),
    Skill4Key = GetModConfigData("skill4_key"),
    SkillCounterAtkKey = GetModConfigData("skill_counter_atk"),
    QuickSheathKey = GetModConfigData("quick_sheath_key"),
    SkillCancelKey = GetModConfigData("skill_cancel_key"),
    MindRegenCount = GetModConfigData("mindregen_count"),
    MindRegenRate = GetModConfigData("set_mindregen_rate"),
    CounterAtkCooldown = GetModConfigData("counter_attack_cooldown_time"),
    Skill1Cooldown = GetModConfigData("skill1_cooldown_time"),
    Skill2Cooldown = GetModConfigData("skill2_cooldown_time"),
    Skill3Cooldown = GetModConfigData("skill3_cooldown_time"),
    Skill4Cooldown = GetModConfigData("skill4_cooldown_time"),
    IsshinCooldown = GetModConfigData("isshin_skill_cooldown_time"),
    RyusenSusanooCooldown = GetModConfigData("ryusen_and_susanoo_skill_cooldown_time"),
    IsMaster = GetModConfigData("is_master"),
    LevelValue = GetModConfigData("set_level_value"),
    PutGlassesKey = GetModConfigData("put_glasses_key"),
    ChangeHairStyleKey = GetModConfigData("change_hair_style_key"),
    MindMax = GetModConfigData("set_max_mind"),
    KExpMtp = GetModConfigData("set_kexpmtp"),
    StartWeapon = GetModConfigData("start_weapon"),
    IsGirlScouts = GetModConfigData("is_girl_scouts"),
    IsDexterityMake = GetModConfigData("is_dexterity_make"),
    IdleAnimationMode = GetModConfigData("idle_animation_mode"),
    EnableDodge = GetModConfigData("dodge_enable"),
    DodgeCooldown = GetModConfigData("dodge_cd"),
    GirlQualities = GetModConfigData("Girl's qualities")
}

ENV.IA_ENABLED = IA_ENABLED
ENV.PL_ENABLED = PL_ENABLED
ENV.AD_ENABLED = AD_ENABLED
ENV.UM_ENABLED = UM_ENABLED
ENV.HOF_ENABLED = HOF_ENABLED
ENV.M_CONFIG = M_CONFIG
