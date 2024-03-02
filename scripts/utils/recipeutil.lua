local shipwrecked_recipes = {}

local function AddShipwreckedRecipes(recipes)
    assert(type(recipes) == "table")

    for k,v in pairs(recipes) do
        shipwrecked_recipes[k] = {
            ingredients = v.ingredients,
            tech = v.tech,
            original_recipe = v.original_recipe
        }
    end
end

local porkland_recipes = {}

local function AddPorklandRecipes(recipes)
    assert(type(recipes) == "table")

    for k,v in pairs(recipes) do
        porkland_recipes[k] = {
            ingredients = v.ingredients,
            tech = v.tech,
            original_recipe = v.original_recipe
        }
    end
end

local function AddRecipes(recipes_data)
    for k, v in pairs(recipes_data) do
        GlassicAPI.AddRecipe(k, v.ingredients, v.tech, v.config, v.filters)

        if v.sort ~= nil and v.sort.before then
            GlassicAPI.RecipeSortBefore(k, v.sort.before, v.filters[2])
        end
        if v.sort ~= nil and v.sort.after then
            GlassicAPI.RecipeSortAfter(k, v.sort.after, v.filters[2])
        end
    end
end

return {
    RecipeUtil = {
        AddRecipes = AddRecipes,
        AddShipwreckedRecipes = AddShipwreckedRecipes,
        AddPorklandRecipes = AddPorklandRecipes,
    },

    RecipesData = {
        shipwrecked_recipes = shipwrecked_recipes,
        porkland_recipes = porkland_recipes,
    },
}
