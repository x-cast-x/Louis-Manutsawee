local TECH = GLOBAL.TECH
local Ingredient = GLOBAL.Ingredient
local RecipeUtil = require("utils/recipeutil").RecipeUtil
local modimport = modimport
GLOBAL.setfenv(1, GLOBAL)

local recipes_data = {
    mingot = {
        ingredients = {Ingredient("moonrocknugget", 8), Ingredient("moonglass", 8), Ingredient("thulecite", 4)},
        tech = TECH.SCIENCE_TWO,
        config = {builder_tag = "bladesmith"},
        filters = {"REFINE"},
    },
    maid_hb = {
        ingredients = {Ingredient("silk", 4)},
        tech = TECH.SCIENCE_ONE,
        config = {builder_tag = "bladesmith"},
        filters = {"CHARACTER", "CLOTHING"},
    },
    m_foxmask = {
        ingredients = {Ingredient("silk", 4)},
        tech = TECH.SCIENCE_ONE,
        config = {builder_tag = "bladesmith"},
        filters = {"CHARACTER", "CLOTHING"},
    },
    m_scarf = {
        ingredients = {Ingredient("silk", 4), Ingredient("beefalowool", 4)},
        tech = TECH.SCIENCE_TWO,
        config = {builder_tag = "bladesmith"},
        filters = {"CHARACTER", "CLOTHING", "WINTER"},
    },

    harakiri = {
        ingredients = {Ingredient("flint", 2), Ingredient("log", 2)},
        tech = TECH.SCIENCE_ONE,
        config = {builder_tag = "bladesmith"},
        filters = {"CHARACTER", "WEAPONS"},
        sort = {after = "gunpowder"}
    },
    mmiko_armor = {
        ingredients = {Ingredient("silk", 4), Ingredient("boards", 2), Ingredient("rope", 2)},
        tech = TECH.SCIENCE_TWO,
        config = {builder_tag = "bladesmith"},
        filters = {"CHARACTER", "ARMOUR", "CLOTHING"},
        sort = {after = "armormarble"}
    },

    shinai = {
        ingredients = {Ingredient("rope", 1), Ingredient("boards", 1)},
        tech = TECH.SCIENCE_ONE,
        config = {builder_tag = "bladesmith"},
        filters = {"CHARACTER", "WEAPONS"},
        sort = {after = "spear"}
    },

    yari = {
        ingredients = {Ingredient("spear", 1), Ingredient("goldnugget", 2)},
        tech = TECH.SCIENCE_TWO,
        config = {builder_tag = "katanakaji"},
        filters = {"CHARACTER", "WEAPONS"},
        sort = {after = "spear_wathgrithr_lightning"}
    },
    mnaginata = {
        ingredients = {Ingredient("spear", 1),Ingredient("goldnugget", 2)},
        tech = TECH.SCIENCE_TWO,
        config = {builder_tag = "katanakaji"},
        filters = {"CHARACTER", "WEAPONS"},
        sort = {after = "spear_wathgrithr_lightning"}
    },

    katanablade = {
        ingredients = {Ingredient("rope", 1), Ingredient("katanabody", 1), Ingredient("cutstone", 1)},
        tech = TECH.SCIENCE_TWO,
        config = {builder_tag = "bladesmith"},
        filters = {"CHARACTER", "WEAPONS"},
        sort = {before = "nightsword"}
    },

    shirasaya = {
        ingredients = {Ingredient("cane", 1), Ingredient("katanablade", 1), Ingredient("rope", 2), Ingredient("goldnugget", 2)},
        tech = TECH.SCIENCE_TWO,
        config = {builder_tag = "bladesmith"},
        filters = {"CHARACTER", "WEAPONS"},
        sort = {after = "nightsword"}
    },
    koshirae = {
        ingredients = {Ingredient("cane", 1), Ingredient("katanablade", 1), Ingredient("rope", 2), Ingredient("goldnugget", 2)},
        tech = TECH.SCIENCE_TWO,
        config = {builder_tag = "bladesmith"},
        filters = {"CHARACTER", "WEAPONS"},
        sort = {after = "nightsword"}
    },
    hitokiri = {
        ingredients = {Ingredient("cane", 1), Ingredient("katanablade", 1), Ingredient("rope", 2), Ingredient("goldnugget", 2)},
        tech = TECH.SCIENCE_TWO,
        config = {builder_tag = "bladesmith"},
        filters = {"CHARACTER", "WEAPONS"},
        sort = {after = "nightsword"}
    },
    raikiri = {
        ingredients = {Ingredient("cane", 1), Ingredient("katanablade", 1), Ingredient("rope", 2), Ingredient("goldnugget", 2)},
        tech = TECH.SCIENCE_TWO,
        config = {builder_tag = "bladesmith"},
        filters = {"CHARACTER", "WEAPONS"},
        sort = {after = "nightsword"}
    },

    shusui = {
        ingredients = {Ingredient("katanablade", 1), Ingredient("cane", 1), Ingredient("thulecite", 20), Ingredient("nightmarefuel", 20)},
        tech = TECH.ANCIENT_FOUR,
        config = {builder_tag = "bladesmith"},
        filters = {"CHARACTER", "WEAPONS"},
        sort = {after = "nightstick"}
    },

    true_shirasaya = {
        ingredients = {Ingredient("thulecite", 40), Ingredient("nightmarefuel", 80), Ingredient("shadowheart", 6), Ingredient("shirasaya", 1)},
        tech = TECH.SCIENCE_TWO,
        config = {builder_tag = "katanakaji"},
        filters = {"CHARACTER", "WEAPONS"},
        sort = {after = "fence_rotator"}
    },
    true_koshirae = {
        ingredients = {Ingredient("thulecite", 40), Ingredient("nightmarefuel", 80), Ingredient("opalpreciousgem", 6), Ingredient("koshirae", 1)},
        tech = TECH.SCIENCE_TWO,
        config = {builder_tag = "katanakaji"},
        filters = {"CHARACTER", "WEAPONS"},
        sort = {after = "fence_rotator"}
    },
    true_hitokiri = {
        ingredients = {Ingredient("thulecite", 40), Ingredient("nightmarefuel", 80), Ingredient("minotaurhorn", 4), Ingredient("hitokiri", 1)},
        tech = TECH.SCIENCE_TWO,
        config = {builder_tag = "katanakaji"},
        filters = {"CHARACTER", "WEAPONS"},
        sort = {after = "fence_rotator"}
    },
    true_raikiri = {
        ingredients = {Ingredient("thulecite", 40), Ingredient("nightmarefuel", 80), Ingredient("lightninggoathorn", 12), Ingredient("raikiri", 1)},
        tech = TECH.SCIENCE_TWO,
        config = {builder_tag = "katanakaji"},
        filters = {"CHARACTER", "WEAPONS"},
        sort = {after = "fence_rotator"}
    },
}

RecipeUtil.AddRecipes(recipes_data)

modimport("postinit/dst_postinit/modules/ia_recipes")
modimport("postinit/dst_postinit/modules/pl_recipes")
