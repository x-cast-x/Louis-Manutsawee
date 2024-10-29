local AddLoadingTip = AddLoadingTip
local STRINGS = GLOBAL.STRINGS
local SetLoadingTipCategoryWeights = SetLoadingTipCategoryWeights
GLOBAL.setfenv(1, GLOBAL)

local WEIGHT_START  = LOADING_SCREEN_TIP_CATEGORY_WEIGHTS_START
local WEIGHT_END    = LOADING_SCREEN_TIP_CATEGORY_WEIGHTS_END

for id, tip in pairs(STRINGS.M_LOADINGTIPS) do
    AddLoadingTip(STRINGS.UI.LOADING_SCREEN_OTHER_TIPS, "M_" .. id, tip)
end

SetLoadingTipCategoryWeights(WEIGHT_START, {OTHER = 4, CONTROLS = 1, SURVIVAL = 1, LORE = 1, LOADING_SCREEN = 1})
SetLoadingTipCategoryWeights(WEIGHT_END,   {OTHER = 4, CONTROLS = 1, SURVIVAL = 1, LORE = 1, LOADING_SCREEN = 1})
