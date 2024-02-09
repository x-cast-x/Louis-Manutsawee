local AddRecipe2 = AddRecipe2
local TECH = GLOBAL.TECH
local Ingredient = GLOBAL.Ingredient
GLOBAL.setfenv(1, GLOBAL)

local recipes_data = {
    mingot = {
        -- ingredients = {Ingredient("moonrocknugget", 8), Ingredient("moonglass", 8), Ingredient("thulecite", 4)},
        ingredients = {Ingredient("flint", 8), Ingredient("cutstone", 2), Ingredient("goldnugget", 4)},
        tech = TECH.SCIENCE_TWO,
        config = {builder_tag = "manutsaweecraft"},
        filters = {"CHARACTER", "REFINE"},
    },
    maid_hb = {
        ingredients = {Ingredient("silk", 4)},
        tech = TECH.SCIENCE_ONE,
        config = {builder_tag = "manutsaweecraft"},
        filters = {"CHARACTER", "CLOTHING"},
    },
    m_foxmask = {
        ingredients = {Ingredient("silk", 4)},
        tech = TECH.SCIENCE_ONE,
        config = {builder_tag = "manutsaweecraft"},
        filters = {"CHARACTER", "CLOTHING"},
    },
    m_scarf = {
        ingredients = {Ingredient("silk", 4), Ingredient("beefalowool", 4)},
        tech = TECH.SCIENCE_TWO,
        config = {builder_tag = "manutsaweecraft"},
        filters = {"CHARACTER", "CLOTHING", "WINTER"},
    },

    harakiri = {
        ingredients = {Ingredient("flint", 2), Ingredient("log", 2)},
        tech = TECH.SCIENCE_ONE,
        config = {builder_tag = "manutsaweecraft"},
        filters = {"CHARACTER", "WEAPONS"},
        sort = {after = "slingshot"}
    },
    mmiko_armor = {
        ingredients = {Ingredient("silk", 4), Ingredient("boards", 2), Ingredient("rope", 2)},
        tech = TECH.SCIENCE_TWO,
        config = {builder_tag = "manutsaweecraft"},
        filters = {"CHARACTER", "ARMOUR", "CLOTHING", "WINTER"},
        sort = {after = "armormarble"}
    },

    shinai = {
        ingredients = {Ingredient("rope", 1), Ingredient("boards", 1)},
        tech = TECH.SCIENCE_ONE,
        config = {builder_tag = "manutsaweecraft"},
        filters = {"CHARACTER", "WEAPONS"},
        sort = {after = "spear"}
    },
    mkatana = {
        ingredients = {Ingredient("flint", 6), Ingredient("rope", 2), Ingredient("log", 2)},
        tech = TECH.SCIENCE_ONE,
        config = {builder_tag = "manutsaweecraft"},
        filters = {"CHARACTER", "WEAPONS"},
        sort = {after = "boomerang"}
    },

    yari = {
        ingredients = {Ingredient("spear", 1), Ingredient("goldnugget", 2)},
        tech = TECH.SCIENCE_TWO,
        config = {builder_tag = "manutsaweecraft2"},
        filters = {"CHARACTER", "WEAPONS"},
        sort = {after = "fence_rotator"}
    },
    mnaginata = {
        ingredients = {Ingredient("spear", 1),Ingredient("goldnugget", 2)},
        tech = TECH.SCIENCE_TWO,
        config = {builder_tag = "manutsaweecraft2"},
        filters = {"CHARACTER", "WEAPONS"},
        sort = {after = "yari"}
    },

    -- kurokatana = {
    --     ingredients = {Ingredient("katanablade", 1), Ingredient("cane", 1), Ingredient("goldnugget", 2)},
    --     tech = TECH.SCIENCE_TWO,
    --     config = {builder_tag = "manutsaweecraft"},
    --     filters = {"CHARACTER", "WEAPONS"},
    --     sort = {after = "mnaginata"}
    -- },
    katanablade = {
        ingredients = {Ingredient("rope", 1), Ingredient("katanabody", 1), Ingredient("cutstone", 1)},
        tech = TECH.SCIENCE_TWO,
        config = {builder_tag = "manutsaweecraft"},
        filters = {"CHARACTER", "WEAPONS"},
        sort = {before = "kurokatana"}
    },


    shirasaya = {
        ingredients = {Ingredient("cane", 1), Ingredient("katanablade", 1), Ingredient("rope", 2), Ingredient("goldnugget", 2)},
        tech = TECH.SCIENCE_TWO,
        config = {builder_tag = "manutsaweecraft"},
        filters = {"CHARACTER", "WEAPONS"},
        sort = {after = "katanablade"}
    },
    -- koshirae = {
    --     ingredients = {Ingredient("cane", 1), Ingredient("katanablade", 1), Ingredient("rope", 2), Ingredient("goldnugget", 2)},
    --     tech = TECH.SCIENCE_TWO,
    --     config = {builder_tag = "manutsaweecraft"},
    --     filters = {"CHARACTER", "WEAPONS"},
    --     sort = {after = "shirasaya"}
    -- },
    -- hitokiri = {
    --     ingredients = {Ingredient("cane", 1), Ingredient("katanablade", 1), Ingredient("rope", 2), Ingredient("goldnugget", 2)},
    --     tech = TECH.SCIENCE_TWO,
    --     config = {builder_tag = "manutsaweecraft"},
    --     filters = {"CHARACTER", "WEAPONS"},
    --     sort = {after = "koshirae"}
    -- },
    -- raikiri = {
    --     ingredients = {Ingredient("cane", 1), Ingredient("katanablade", 1), Ingredient("rope", 2), Ingredient("goldnugget", 2)},
    --     tech = TECH.SCIENCE_TWO,
    --     config = {builder_tag = "manutsaweecraft"},
    --     filters = {"CHARACTER", "WEAPONS"},
    --     sort = {after = "hitokiri"}
    -- },

    -- true_shirasaya = {
    --     ingredients = {Ingredient("thulecite", 40), Ingredient("nightmarefuel", 80), Ingredient("shadowheart", 6), Ingredient("shirasaya", 1)},
    --     tech = TECH.SCIENCE_TWO,
    --     config = {builder_tag = "manutsaweecraft2"},
    --     filters = {"CHARACTER", "WEAPONS"},
    --     sort = {after = "raikiri"}
    -- },
    -- true_koshirae = {
    --     ingredients = {Ingredient("thulecite", 40), Ingredient("nightmarefuel", 80), Ingredient("opalpreciousgem", 6), Ingredient("koshirae", 1)},
    --     tech = TECH.SCIENCE_TWO,
    --     config = {builder_tag = "manutsaweecraft2"},
    --     filters = {"CHARACTER", "WEAPONS"},
    --     sort = {after = "true_shirasaya"}
    -- },
    -- true_hitokiri = {
    --     ingredients = {Ingredient("thulecite", 40), Ingredient("nightmarefuel", 80), Ingredient("minotaurhorn", 4), Ingredient("hitokiri", 1)},
    --     tech = TECH.SCIENCE_TWO,
    --     config = {builder_tag = "manutsaweecraft2"},
    --     filters = {"CHARACTER", "WEAPONS"},
    --     sort = {after = "true_koshirae"}
    -- },
    -- true_raikiri = {
    --     ingredients = {Ingredient("thulecite", 40), Ingredient("nightmarefuel", 80), Ingredient("lightninggoathorn", 12), Ingredient("raikiri", 1)},
    --     tech = TECH.SCIENCE_TWO,
    --     config = {builder_tag = "manutsaweecraft2"},
    --     filters = {"CHARACTER", "WEAPONS"},
    --     sort = {after = "true_hitokiri"}
    -- },

    shusui = {
        ingredients = {Ingredient("katanablade", 1), Ingredient("cane", 1), Ingredient("thulecite", 20), Ingredient("nightmarefuel", 20)},
        -- ingredients = {Ingredient("katanablade", 1), Ingredient("cane", 1), Ingredient("livinglog", 6), Ingredient("nightmarefuel", 5)},
        -- tech = TECH.ANCIENT_FOUR,
        tech = TECH.SCIENCE_TWO,
        config = {builder_tag = "manutsaweecraft"},
        filters = {"CHARACTER", "MAGIC"},
        sort = {after = "nightsword"}
    },

    -- Not required
    -- mortalblade = {
    --     ingredients = {Ingredient("shusui", 1), Ingredient("thulecite", 20), Ingredient("nightmarefuel", 40)},
    --     tech = TECH.ANCIENT_FOUR,
    --     config = {builder_tag = "manutsaweecraft2"},
    --     filters = {"CHARACTER", "MAGIC"},
    -- },
}

if IA_ENABLED then
    recipes_data.msurfboard_item = {
        ingredients = {Ingredient("boards", 1), Ingredient("seashell", 2)},
        tech = TECH.NONE,
        config = {builder_tag = "manutsaweecraft"},
        filters = {"CHARACTER", "SEAFARING"},
    }
end

for k, v in pairs(recipes_data) do
    if v.sort ~= nil and v.sort.before then
        GlassicAPI.RecipeSortBefore(k, v.sort.before, v.filters[2])
    end
    if v.sort ~= nil and v.sort.after then
        GlassicAPI.RecipeSortAfter(k, v.sort.after, v.filters[2])
    end
end

-- for i = 1 ,#recipes_data  do
--     GlassicAPI.RecipeSortAfter(recipes_data[i], recipes_data[i + 1], "CHARACTER")
-- end

for k, v in pairs(recipes_data) do
    AddRecipe2(k, v.ingredients, v.tech, v.config, v.filters)
end

if IA_ENABLED then
    local shipwrecked_recipes_data = {
        mingot = {
            ingredients = {Ingredient("obsidian", 8), Ingredient("flint", 4), Ingredient("goldnugget", 4)},
            original_recipe = {ingredients = recipes_data.mingot.ingredients}
        },
        true_shirasaya = {
            ingredients = {Ingredient("shirasaya", 1), Ingredient("obsidian", 40), Ingredient("nightmarefuel", 80), Ingredient("shadowheart", 6)},
            original_recipe = {ingredients = recipes_data.true_shirasaya.ingredients}
        },
        true_koshirae = {
            ingredients = {Ingredient("koshirae", 1), Ingredient("obsidian", 40), Ingredient("nightmarefuel", 80), Ingredient("opalpreciousgem", 6)},
            original_recipe = {ingredients = recipes_data.true_koshirae.ingredients}
        },
        true_hitokiri = {
            ingredients = {Ingredient("koshirae", 1), Ingredient("obsidian", 40), Ingredient("nightmarefuel", 80), Ingredient("tigereye", 6)},
            original_recipe = {ingredients = recipes_data.true_hitokiri.ingredients}
        },
        true_raikiri = {
            ingredients = {Ingredient("raikiri", 1), Ingredient("obsidian", 40), Ingredient("nightmarefuel", 80), Ingredient("jellyfish", 10)},
            original_recipe = {ingredients = recipes_data.true_raikiri.ingredients}
        },
        shusui = {
            ingredients = {Ingredient("katanablade", 1), Ingredient("cane", 1), Ingredient("obsidian", 20), Ingredient("nightmarefuel", 20)},
            original_recipe = {ingredients = recipes_data.shusui.ingredients, tech = TECH.OBSIDIAN_TWO}
        },
        -- mortalblade = {
        --     ingredients = {Ingredient("shusui", 1), Ingredient("obsidian", 20), Ingredient("nightmarefuel", 40)},
        --     original_recipe = {ingredients = recipes_data.mortalblade.ingredients, tech = TECH.OBSIDIAN_TWO}
        -- },
    }

    M_Util.AddShipwreckedRecipes(shipwrecked_recipes_data, recipes_data)
end


-- if PL_ENABLED then
--     local porkland_recipes_data = {}

--     M_Util.AddPorklandRecipes(porkland_recipes_data, recipes_data)
-- end
