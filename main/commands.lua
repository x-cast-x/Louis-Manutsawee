GLOBAL.setfenv(1, GLOBAL)

function c_getkatana()
    d_spawnlist(ALL_KATANA)
end

function c_setmindpower(num)
    local player = ConsoleCommandPlayer()
    if player ~= nil and player.components.kenjutsuka ~= nil then
        player.components.kenjutsuka:SetMindpower(num or 30)
    end
end

function c_setkenjutsulevel(level)
    local player = ConsoleCommandPlayer()
    if player.components.kenjutsuka ~= nil then
        player.components.kenjutsuka:SetKenjutsuLevel(level or 0)
    end
end

if not rawget(_G, "c_revealmap") then
    function c_revealmap()
        local size = 2 * TheWorld.Map:GetSize()
        local player = ConsoleCommandPlayer()
        for x = -size, size, 32 do
            for z = -size, size, 32 do
                player.player_classified.MapExplorer:RevealArea(x, 0, z)
            end
        end
    end
end

function c_trackkatana()
    local player = ConsoleCommandPlayer()
    local mortalblade = SpawnPrefab("mortalblade")
    TheWorld:PushEvent("ms_trackkatana", {name = mortalblade.prefab})
    mortalblade.Transform:SetPosition(player.Transform:GetWorldPosition())
end

function c_printtable(t)
    if type(t) == "table" then
        print(PrintTable(t))
    end
end
