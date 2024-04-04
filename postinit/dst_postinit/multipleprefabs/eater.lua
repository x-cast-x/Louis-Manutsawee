local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local foods = {
    "phlegm",
    "rottenegg",
    "humanmeat",
    "humanmeat_cooked",
    "humanmeat_dried",
    "spoiled_food",
    "spoiled_fish",
    "spoiled_fish_small",
    "deerclops_eyeball",
    "glommerfuel",
    "minotaurhorn",
}

for _, v in ipairs(foods) do
    AddPrefabPostInit(v, function(inst)
        inst:AddTag("terriblefood")
    end)
end
