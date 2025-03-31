if not IA_ENABLED then
    return
end

local RecipeUtil = require("utils/recipeutil").RecipeUtil
GLOBAL.setfenv(1, GLOBAL)

local recipes_data = {
    msurfboard_item = {
        ingredients = {Ingredient("boards", 1), Ingredient("seashell", 2)},
        tech = TECH.NONE,
        config = {builder_tag = "kenjutsuka"},
        filters = {"CHARACTER", "SEAFARING"},
    }
}

RecipeUtil.AddRecipes(recipes_data)

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
}

RecipeUtil.AddShipwreckedRecipes(shipwrecked_recipes_data)
