local AddPrefabPostInit = AddPrefabPostInit
local UpvalueUtil = require("utils/upvalueutil")
GLOBAL.setfenv(1, GLOBAL)

local trees = {
    "winter_tree",
    "winter_twiggytree",
    "winter_deciduoustree",
    "winter_palmconetree"
}

local random_gift1 =
{
    moonrocknugget = 2,
    gears = 1,
    compass = .3,
    sewing_kit = .2,

    --gems
    redgem = .2,
    bluegem = .2,
    greengem = .1,
    orangegem = .1,
    yellowgem = .1,

    --hats
    beefalohat = .5,
    winterhat = .5,
    earmuffshat = .5,
    catcoonhat = .5,
    molehat = .5,
    rainhat = .5
}

local random_gift2 =
{
    gears = .2,
    moonrocknugget = .2,

    --gems
    redgem = .1,
    bluegem = .1,
    greengem = .1,
    orangegem = .1,
    yellowgem = .1,

    --special
    walrushat = .2,
    cane = .2,
    panflute = .1,
    bushhat = .1
}

local function fn(inst)
    if not TheWorld.ismastersim then
        return
    end

    local queuegifting = UpvalueUtil.GetUpvalue(inst.OnEntityWake, "queuegifting")
    local trygifting = UpvalueUtil.GetUpvalue(queuegifting, "trygifting")
    local dogifting = UpvalueUtil.GetUpvalue(trygifting, "dogifting")
    local NoOverlap = UpvalueUtil.GetUpvalue(dogifting, "NoOverlap")
    local GIFTING_PLAYER_RADIUS_SQ = UpvalueUtil.GetUpvalue(dogifting, "GIFTING_PLAYER_RADIUS_SQ")
    local NobodySeesPoint = UpvalueUtil.GetUpvalue(dogifting, "NobodySeesPoint")
    local function dogifting(inst)
        if TheWorld.state.isnight then
            local players = {}
            local x, y, z = inst.Transform:GetWorldPosition()
            for i, v in ipairs(AllPlayers) do
                if v:GetDistanceSqToPoint(x, y, z) < GIFTING_PLAYER_RADIUS_SQ then
                    table.insert(players, v)
                end
            end

            if #players > 0 then
                local fully_decorated = inst.components.container:IsFull()
                for _, player in ipairs(players) do
                    local loot = {}

                    -- yeah, that's it
                    local previousgiftday = player:HasTag("naughtychild") and 1 or 4

                    if player.components.wintertreegiftable ~= nil and player.components.wintertreegiftable:GetDaysSinceLastGift() >= previousgiftday then
                        player.components.wintertreegiftable:OnGiftGiven()
                        table.insert(loot, { prefab = "winter_food".. math.random(NUM_WINTERFOOD), stack = math.random(3) + (fully_decorated and 3 or 0)})
                        table.insert(loot, { prefab = not fully_decorated and GetRandomBasicWinterOrnament()
                                                or math.random() < 0.5 and GetRandomFancyWinterOrnament()
                                                or GetRandomFestivalEventWinterOrnament() })

                        table.insert(loot, { prefab = weighted_random_choice(random_gift1) })

                        if fully_decorated then
                            table.insert(loot, { prefab = weighted_random_choice(random_gift2) })
                        else
                            table.insert(loot, { prefab = PickRandomTrinket() })
                        end
                    else
                        table.insert(loot, { prefab = "winter_food".. math.random(NUM_WINTERFOOD), stack = math.random(3) })
                        table.insert(loot, { prefab = "charcoal" })
                    end

                    local items = {}
                    for i, v in ipairs(loot) do
                        local item = SpawnPrefab(v.prefab)
                        if item ~= nil then
                            if item.components.stackable ~= nil then
                                item.components.stackable.stacksize = math.max(1, v.stack or 1)
                            end
                            table.insert(items, item)
                        end
                    end
                    if #items > 0 then
                        local gift = SpawnPrefab("gift")
                        gift.components.unwrappable:WrapItems(items)
                        for i, v in ipairs(items) do
                            v:Remove()
                        end
                        local pos = inst:GetPosition()
                        local radius = inst:GetPhysicsRadius(0) + .7 + math.random() * .5
                        local theta = inst:GetAngleToPoint(player.Transform:GetWorldPosition()) * DEGREES
                        local offset =
                            FindWalkableOffset(pos, theta, radius, 8, false, true, NoOverlap) or
                            FindWalkableOffset(pos, theta, radius + .5, 8, false, true, NoOverlap) or
                            FindWalkableOffset(pos, theta, radius, 8, false, true, NobodySeesPoint) or
                            FindWalkableOffset(pos, theta, radius + .5, 8, false, true, NobodySeesPoint)
                        if offset ~= nil then
                            gift.Transform:SetPosition(pos.x + offset.x, 0, pos.z + offset.z)
                        else
                            inst.components.lootdropper:FlingItem(gift)
                        end
                    end

                    if inst.forceoff then
                        inst:DoTaskInTime(1, function() inst.forceoff = false end, inst)
                    end

                    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/bell")
                    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/chain")
                    inst.SoundEmitter:PlaySound("dontstarve/common/dropGeneric")

                    return true
                end
            end
        end
    end
    UpvalueUtil.SetUpvalue(trygifting, dogifting, "dogifting")
end

for _, v in pairs(trees) do
    AddPrefabPostInit(v, fn)
end
