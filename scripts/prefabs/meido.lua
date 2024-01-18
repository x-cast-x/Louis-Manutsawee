require("prefabs/world")

local assets = {
    Asset("SCRIPT", "scripts/prefabs/world.lua"),
}

local prefabs = {}

local tile_physics_init = function(inst)
    inst.Map:AddTileCollisionSet(
        COLLISION.LAND_OCEAN_LIMITS,
        TileGroups.ImpassableTiles, true,
        TileGroups.ImpassableTiles, false,
        0.25, 64
    )
end

local common_postinit = function(inst)
    --Initialize lua components
    inst:AddComponent("ambientlighting")

    --Dedicated server does not require these components
    --NOTE: ambient lighting is required by light watchers
    if not TheNet:IsDedicated() then
        -- inst:AddComponent("dynamicmusic")
        -- inst:AddComponent("ambientsound")
        -- inst.components.ambientsound:SetReverbPreset("cave")
        -- inst.components.ambientsound:SetWavesEnabled(false)
        inst:AddComponent("dsp")
        inst:AddComponent("colourcube")
        inst:AddComponent("hallucinations")

        -- Grotto
        inst:AddComponent("grottowaterfallsoundcontroller")
    end


    TheWorld.Map:SetUndergroundFadeHeight(5)
end

local master_postinit = function(inst)
    inst:AddComponent("katanaspawner")
    inst:AddComponent("meido")
end

return MakeWorld("meido", prefabs, assets, common_postinit, master_postinit, {"meido", "hades"}, {tile_physics_init = tile_physics_init})
