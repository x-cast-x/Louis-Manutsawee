local ENV = env
local RegisterInventoryItemAtlas = RegisterInventoryItemAtlas
local AddMinimapAtlas = AddMinimapAtlas
local resolvefilepath = GLOBAL.resolvefilepath
local AddSimPostInit = AddSimPostInit
local TechTree = require("techtree")
GLOBAL.setfenv(1, GLOBAL)

M_Util = {}
ENV.M_Util = M_Util

function M_Util.RegisterImageAtlas(atlas_path)
    local atlas = resolvefilepath(atlas_path)

    local file = io.open(atlas, "r")
    local data = file:read("*all")
    file:close()

    local str = string.gsub(data, "%s+", "")
    local _, _, elements = string.find(str, "<Elements>(.-)</Elements>")

    for s in string.gmatch(elements, "<Element(.-)/>") do
        local _, _, image = string.find(s, "name=\"(.-)\"")
        if image ~= nil then
            RegisterInventoryItemAtlas(atlas, image)
            RegisterInventoryItemAtlas(atlas, hash(image))  -- for client
        end
    end
end

function M_Util.AddMinimapAtlas(atlas_path, assets_table)
    local file_path = "images/map_icons/"..atlas_path
    if assets_table then
        table.insert(assets_table, Asset("ATLAS", file_path .. ".xml"))
        table.insert(assets_table, Asset("IMAGE", file_path .. ".tex"))
    end
    AddMinimapAtlas(file_path .. ".xml")
end

-- local sound = {}

-- local _PlaySound = SoundEmitter.PlaySound
-- function SoundEmitter:PlaySound(soundname, ...)
--     return _PlaySound(self, sound[soundname] or soundname, ...)
-- end

-- function M_Util.SetSound(name, alias)
--     sound[name] = alias
-- end

function M_Util.GetUpvalue(fn, name, recurse_levels)
    assert(type(fn) == "function")

    recurse_levels = recurse_levels or 0
    local source_fn = fn
    local i = 1

    while true do
        local _name, value = debug.getupvalue(fn, i)
        if _name == nil then
            return
        elseif _name == name then
            return value, i, source_fn
        elseif type(value) == "function" and recurse_levels > 0 then
            local _value, _i, _source_fn = M_Util.GetUpvalue(value, name, recurse_levels - 1)
            if _value ~= nil then
                return _value, _i, _source_fn
            end
        end

        i = i + 1
    end
end

function M_Util.SetUpvalue(fn, value, name, recurse_levels)
    local _, i, source_fn = M_Util.GetUpvalue(fn, name, recurse_levels)
    if source_fn and i and value then
        debug.setupvalue(source_fn, i, value)
    end
end

function M_Util.is_array(t)
    if type(t) ~= "table" or not next(t) then
        return false
    end

    local n = #t
    for i, v in pairs(t) do
        if type(i) ~= "number" or i <= 0 or i > n then
            return false
        end
    end

    return true
end

function M_Util.merge_table(target, add_table, override)
    target = target or {}

    for k, v in pairs(add_table) do
        if type(v) == "table" then
            if not target[k] then
                target[k] = {}
            elseif type(target[k]) ~= "table" then
                if override then
                    target[k] = {}
                else
                    error("Can not override" .. k .. " to a table")
                end
            end

            M_Util.merge_table(target[k], v, override)
        else
            if M_Util.is_array(target) and not override then
                table.insert(target, v)
            elseif not target[k] or override then
                target[k] = v
            end
        end
    end
end

function M_Util.OnAttackCommonFn(inst, owner, target)
    if owner.components.rider and owner.components.rider:IsRiding() then
        return
    end

    if inst.wpstatus and inst:HasTag("Iai") then
        inst.UnsheathMode(inst)
        if target.components.combat ~= nil then
            target.components.combat:GetAttacked(owner, inst.components.weapon.damage * .8)
        end
    end

    if owner:HasTag("kenjutsu") and not inst:HasTag("mkatana") then
        inst:AddTag("mkatana")
    end

    if math.random(1,4) == 1 then
        local x = math.random(1, 1.2)
        local y = math.random(1, 1.2)
        local z = math.random(1, 1.2)
        local slash = {"shadowstrike_slash_fx","shadowstrike_slash2_fx"}

        slash = SpawnPrefab(slash[math.random(1,2)])
        slash.Transform:SetPosition(target:GetPosition():Get())
        slash.Transform:SetScale(x, y, z)
    end

    inst.components.weapon.attackwear = inst.IsShadow(target) and TUNING.GLASSCUTTER.SHADOW_WEAR or 1
end

function M_Util.GroundPoundFx(inst, scale)
    local x, y, z = inst.Transform:GetWorldPosition()
    local fx = SpawnPrefab("groundpoundring_fx")
    fx.Transform:SetScale(scale, scale, scale)
    fx.Transform:SetPosition(x, y, z)
end

function M_Util.SlashFx(inst, target, prefab, scale)
    local fx = SpawnPrefab(prefab)
    fx.Transform:SetScale(scale, scale, scale)
    fx.Transform:SetPosition(target:GetPosition():Get())
    inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
    inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe")
end

function M_Util.AoeAttack(inst, damage, range)
    local CANT_TAGS = { "INLIMBO", "invisible", "NOCLICK",  }
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, range, nil, CANT_TAGS)
    local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

    for _ ,v in pairs(ents) do
        if (v and v:HasTag("bird")) then
            v.sg:GoToState("stunned")
        end

        if v ~= nil and not v:IsInLimbo() and v:IsValid() and v.components.health ~= nil and v.components.combat ~= nil and not v.components.health:IsDead() then
            if not (v:HasTag("player") or v:HasTag("structure") or v:HasTag("companion") or v:HasTag("abigial") or v:HasTag("wall")) then
                if weapon ~= nil then
                    v.components.combat:GetAttacked(inst, weapon.components.weapon.damage*damage)
                end
                if v.components.freezable ~= nil then
                    v.components.freezable:SpawnShatterFX()
                end
            end
        elseif v ~= nil and v:HasTag("tree") or v:HasTag("stump") and not v:HasTag("structure") then
            if v.components.workable ~= nil then
                v.components.workable:WorkedBy(inst, 10)
            end
        end
    end
end

function M_Util.AddFollowerFx(inst, prefab, scale)
    local fx = SpawnPrefab(prefab)
    fx.entity:AddFollower()
    fx.Follower:FollowSymbol(inst.GUID, "swap_body", 0, 0, 0)
    if scale ~= nil then
        fx.Transform:SetScale(scale, scale, scale)
    end
end

function M_Util.Skill_CommonFn(inst, tag, name, time, mindpower, fn)
    if inst.components.skillreleaser:CanUseSkill(inst.components.combat.target) then
        inst.sg:GoToState("idle")
        inst.components.skillreleaser:SkillRemove()
        inst:DoTaskInTime(.3, function()
            inst.components.talker:Say(STRINGS.SKILL.REFUSE_RELEASE)
        end)
        return
    end

    if inst.mafterskillndm ~= nil then
        inst.mafterskillndm:Cancel()
        inst.mafterskillndm = nil
    end

    fn(inst)

    inst.components.kenjutsuka:SetMindpower(inst.components.kenjutsuka:GetMindpower() - mindpower)
    inst.components.timer:StartTimer(name, time)

    inst:RemoveTag(tag)
end

local shipwrecked_recipes = {}

---@param recipes table
function M_Util.AddShipwreckedRecipes(recipes)
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

---@param recipes table
function M_Util.AddPorklandRecipes(recipes)
    assert(type(recipes) == "table")

    for k,v in pairs(recipes) do
        porkland_recipes[k] = {
            ingredients = v.ingredients,
            tech = v.tech,
            original_recipe = v.original_recipe
        }
    end
end

-- local is_forest = function(world)
--     return world:HasTag("forest") or world:HasTag("cave")
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

---@param name string
---@param ingredients table
---@param tech string
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
        for k,v in pairs(shipwrecked_recipes) do
            ChangeRecipe(k, v.ingredients, v.tech)
        end
    -- else
    --     for k,v in pairs(shipwrecked_recipes) do
    --         ChangeRecipe(k, v.original_recipe.ingredients, v.original_recipe.tech)
    --     end
    end

    if is_porkland(world) then
        for k,v in pairs(porkland_recipes) do
            ChangeRecipe(k, v.ingredients, v.tech)
        end
    -- else
    --     for k,v in pairs(porkland_recipes) do
    --         ChangeRecipe(k, v.original_recipe.ingredients, v.original_recipe.tech)
    --     end
    end
end

AddSimPostInit(sim_postinit_fn)
