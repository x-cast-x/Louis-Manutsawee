local MakeKatana = require "prefabs/katana_def"

local function TryStartFx(inst, owner)
    owner = owner
        or inst.components.equippable:IsEquipped() and inst.components.inventoryitem.owner
        or nil

    if owner == nil then
        return
    end

    if inst._vfx_fx_inst == nil then
        inst._vfx_fx_inst = SpawnPrefab("pocketwatch_weapon_fx")
        inst._vfx_fx_inst.entity:AddFollower()
        inst._vfx_fx_inst.entity:SetParent(owner.entity)
        inst._vfx_fx_inst.Follower:FollowSymbol(owner.GUID, "swap_object", 15, 0, 0)
    end
end

local function StopFx(inst)
    if inst._vfx_fx_inst ~= nil then
        inst._vfx_fx_inst:Remove()
        inst._vfx_fx_inst = nil
    end
end

local shadow_fx = {"wanda_attack_shadowweapon_old_fx", "wanda_attack_pocketwatch_old_fx", "hitsparks_fx"}
local CANT_TAGS = {"player", "INLIMBO", "structure", "companion", "abigial", "birds", "prey", "wall" ,"boat", "bird"}

-- local shusui_onattack = function(inst, owner, target)
--     local radius = 6
--     local x, y, z = owner.Transform:GetWorldPosition()
--     local ents = TheSim:FindEntities(x, y, z, radius, nil, CANT_TAGS)

--     for _, v in pairs(ents) do
--         if v ~= nil and v:IsValid() and v.components.health ~= nil and not v.components.health:IsDead() then
--             local shadowfx = SpawnPrefab(shadow_fx[2])
--             shadowfx.Transform:SetScale(2, 2, 2)
--             shadowfx.Transform:SetPosition(v:GetPosition():Get())

--             if v ~= target then
--                 v.components.health:DoDelta(-20)
--             end
--         end
--     end
-- end

local hitsparks_fx_colouroverride = {1, 0, 0}
local mortalblade_onattack = function(inst, owner, target)
    if inst.IsShadow(target) or inst.IsLunar(target) then
        target.components.combat:GetAttacked(owner, inst.components.weapon.damage * 10)
    end

    local shadowfx
    local radius = 10
    local x, y, z = owner.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, radius, nil, CANT_TAGS)

    local spark = SpawnPrefab("hitsparks_fx")
    spark:Setup(owner, target, nil, hitsparks_fx_colouroverride)
    -- 将hitsparks_fx的black值设置为true
    spark.black:set(true)

    for _, v in pairs(ents) do
        if v ~= nil and v:IsValid() and v.components.health ~= nil and not v.components.health:IsDead() then
            if math.random(1, 2) == 1 then
                shadowfx = SpawnPrefab(shadow_fx[math.random(1,2)])
            else
                shadowfx = SpawnPrefab(shadow_fx[math.random(1,2)])
            end
            if shadowfx.prefab == "hitsparks_fx" then
                spark:Setup(owner, target, nil, hitsparks_fx_colouroverride)
                -- 将hitsparks_fx的black值设置为true
                spark.black:set(true)
            end
            shadowfx.Transform:SetScale(3, 3, 3)
            shadowfx.Transform:SetPosition(v:GetPosition():Get())
            inst.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")

            if v ~= target then
                v.components.health:DoDelta(-TUNING.KATANA.TRUE_DAMAGE)
            end
        end
    end
end

local shusui_common_postinit = function(inst)
    inst:AddTag("shusui")
end

-- local shusui_master_postinit = function(inst)
--     inst.components.weapon:SetDamage(42)
-- end

local mortalblade_common_postinit = function(inst)
    inst:AddTag("mortalblade")
end

local function OnRemove(inst)
    SendModRPCToShard(SHARD_MOD_RPC["manutsawee"]["SyncKatanaData"], 1, false, inst.prefab)
end

local function OnSave(inst, data)
    if inst.first_time_unsheathed ~= nil then
        data.first_time_unsheathed = inst.first_time_unsheathed
    end
end

local function OnLoad(inst, data)
    if data ~= nil then
        if inst.first_time_unsheathed ~= nil then
            inst.first_time_unsheathed = data.first_time_unsheathed
        end
    end
end

local mortalblade_master_postinit = function(inst)
    inst.first_time_unsheathed = true

    inst:ListenForEvent("onremove", OnRemove)

    inst.TryStartFx = TryStartFx
    inst.StopFx = StopFx

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    inst.onequip_fn = function(inst, owner)
        inst.TryStartFx(inst, owner)
    end

    inst.onunequip_fn = function(inst, owner)
        inst.StopFx(inst)
    end
end

local tenseiga_onattack = function(inst, owner, target)
    local health = target.components.health
    if health ~= nil then
        if target:HasTag("abigail") then
            owner.components.talker:Say(STRINGS.CHARACTERS.MANUTSAWEE.DESCRIBE.ABIGAIL.PROMPT)
        elseif target:HasTag("ghost") then
            local fx = SpawnPrefab("fx_book_light_upgraded")
            fx.Transform:SetScale(.9, 2.5, 1)
            fx.entity:AddFollower()
            fx.Follower:FollowSymbol(target.GUID)
            owner.components.talker:Say(STRINGS.CHARACTERS.MANUTSAWEE.DESCRIBE.GHOST_KILL)
            target:DoTaskInTime(1, function() health:Kill() end)
        end

        if not (target:HasTag("ghost") and target:HasTag("abigail")) and inst.IsShadow(target) or inst.IsLunar(target) then
            if health:IsInvincible() then
                health:SetInvincible(false)
            end
            health:Kill()
        end
    end
end

local tenseiga_common_postinit = function(inst)
    inst:AddTag("tenseiga")
    -- inst.AnimState:SetMultColour(0, 0, 0, 0.9)
    -- inst.AnimState:SetMultColour(0.4, 0.4, 0.4, 1)
end

local tenseiga_master_postinit = function(inst)
    local _onhaunt = inst.components.hauntable.onhaunt
    local function OnHaunt(inst, player)
        if player ~= nil and player:HasTag("playerghost") then
            player:PushEvent("respawnfromghost", { source = inst, user = inst })
            local fx = SpawnPrefab("fx_book_light_upgraded")
            fx.Transform:SetScale(.9, 2.5, 1)
            fx.entity:AddFollower()
            fx.Follower:FollowSymbol(inst.GUID)
        end

        return _onhaunt(inst, player)
    end

    inst.components.hauntable.onhaunt = OnHaunt

    inst:RemoveComponent("finiteuses")
end

local function kage_common_postinit(inst)
    inst:AddTag("kage")
end

local function kage_master_postinit(inst)
    inst.TryStartFx = TryStartFx
    inst.StopFx = StopFx

    inst.onequip_fn = function(inst, owner)
        inst.TryStartFx(inst, owner)
    end

    inst.onunequip_fn = function(inst, owner)
        inst.StopFx(inst)
    end
end

local kage_onattack = mortalblade_onattack

local katana_data = {
    shusui = {
        common_postinit = shusui_common_postinit,
        -- master_postinit = shusui_master_postinit,
        -- onattack = shusui_onattack,
        damage = TUNING.KATANA.TRUE_DAMAGE
    },
    mortalblade = {
        common_postinit = mortalblade_common_postinit,
        master_postinit = mortalblade_master_postinit,
        onattack = mortalblade_onattack,
        damage = TUNING.KATANA.TRUE_DAMAGE
    },
    tenseiga = {
        common_postinit = tenseiga_common_postinit,
        master_postinit = tenseiga_master_postinit,
        onattack = tenseiga_onattack,
        damage = 0,
    },
    kage = {
        common_postinit = kage_common_postinit,
        master_postinit = kage_master_postinit,
        onattack = kage_onattack,
        damage = TUNING.KATANA.TRUE_DAMAGE,
    }
}

local ret = {}
for k, v in pairs(katana_data) do
    local data = {
        name = k,
        build = k,
        onattack = v.onattack,
        common_postinit = v.common_postinit,
        master_postinit = v.master_postinit,
        damage = v.damage
    }
    table.insert(ret, MakeKatana(data))
end

return unpack(ret)
