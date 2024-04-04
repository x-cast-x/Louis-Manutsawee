local foods = {
    momo_pizza = {
		test = function(cooker, names, tags) return tags.meat and names.kyno_flour and tags.dairy and (names.tomato or names.tomato_cooked) end,
		name = "gorge_pizza",
        priority = 35,
		foodtype = FOODTYPE.MEAT,
		perishtime = TUNING.PERISH_SUPERSLOW,
		health = 40,
		hunger = 150,
		sanity = 20,
		cooktime = 2.5,
		potlevel = "med",
		floater = {"med", nil, 0.65},
	},
}

for k, v in pairs(foods) do
    v.name = k.name
    v.weight = v.weight or 1
    v.priority = v.priority or 0

    v.cookbook_category = "cookpot"
    v.overridebuild = "cook_pot_food"
end

return foods
