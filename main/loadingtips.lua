local AddLoadingTip = AddLoadingTip
local STRINGS = GLOBAL.STRINGS
local SetLoadingTipCategoryWeights = SetLoadingTipCategoryWeights
GLOBAL.TheLoadingTips = require("loadingtipsdata")()
local TheLoadingTips = GLOBAL.TheLoadingTips
GLOBAL.setfenv(1, GLOBAL)

local function setup_custom_loading_tips()
    for id, tip in pairs(STRINGS.M_LOADINGTIPS) do
        AddLoadingTip(STRINGS.UI.LOADING_SCREEN_OTHER_TIPS, "M_" .. id, tip)
    end

    local tipcategorystartweights =
    {
        CONTROLS = 0.2,
        SURVIVAL = 0.2,
        LORE = 0.2,
        LOADING_SCREEN = 0.2,
        OTHER = 0.2,
    }

    SetLoadingTipCategoryWeights(LOADING_SCREEN_TIP_CATEGORY_WEIGHTS_START, tipcategorystartweights)

    local tipcategoryendweights =
    {
        CONTROLS = 0,
        SURVIVAL = 0,
        LORE = 0,
        LOADING_SCREEN = 0,
        OTHER = 1,
    }
    --UM tips are guaranteed on the second tip during the loading screen.
    SetLoadingTipCategoryWeights(LOADING_SCREEN_TIP_CATEGORY_WEIGHTS_END, tipcategoryendweights)

    -- Recalculate loading tip & category weights.
    TheLoadingTips.loadingtipweights = TheLoadingTips:CalculateLoadingTipWeights()
    TheLoadingTips.categoryweights = TheLoadingTips:CalculateCategoryWeights()

    TheLoadingTips:Load()
end

-- We need to call this directly instead of in AddGamePostInit() because the loading screen appears before calling that function.
setup_custom_loading_tips()