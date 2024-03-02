local AddSimPostInit = AddSimPostInit
local RecipesData = require("utils/recipeutil").RecipesData
GLOBAL.setfenv(1, GLOBAL)

-- local is_forest = function(world)
--     return world:HasTag("forest")
-- end

-- local is_cave = function(world)
--     return world:HasTag("cave")
-- end

local is_shipwrecked = function(world) -- 火山也是海难世界的内容
    return world:HasTag("island") or world:HasTag("volcano")
end

-- local is_volcano = function(world)
--     return world:HasTag("volcano")
-- end

-- Porkland还没有做完，先写着，之后就懒得写了😋
local is_porkland = function(world)
    return world:HasTag("porkland")
end

local function ChangeRecipe(name, ingredients, tech)
    local recipe = AllRecipes[name]
    if recipe then
        recipe.ingredients = ingredients
        if tech then
            recipe.level = tech
        end
    end
end

local sim_postinit_fn = function()
    local world = TheWorld

    if is_shipwrecked(world) then
        for k,v in pairs(RecipesData.shipwrecked_recipes) do
            ChangeRecipe(k, v.ingredients, v.tech)
        end
    end

    if is_porkland(world) then
        for k,v in pairs(RecipesData.porkland_recipes) do
            ChangeRecipe(k, v.ingredients, v.tech)
        end
    end
end

AddSimPostInit(sim_postinit_fn)
