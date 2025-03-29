if not PL_ENABLED then
    return
end

local RecipeUtil = require("utils/recipeutil").RecipeUtil
GLOBAL.setfenv(1, GLOBAL)

local recipes_data = {
}

RecipeUtil.AddRecipes(recipes_data)

local porkland_recipes_data = {}

RecipeUtil.AddPorklandRecipes(porkland_recipes_data)
