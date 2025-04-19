local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function TeleportToAnyServer(placeId)
    local success, servers = pcall(function()
        return game:GetService("HttpService"):GetAsync("https://games.roblox.com/v1/games/" .. placeId .. "/servers?limit=10")
    end)
    
    if not success then
        warn("❌ Failed to fetch server list.")
        return
    end

    local availableServers = {}
    
    local serverData = game:GetService("HttpService"):JSONDecode(servers)
    for _, server in ipairs(serverData.data) do
        if server.playing < server.maxPlayers then
            table.insert(availableServers, server)
        end
    end
    
    if #availableServers == 0 then
        warn("❌ No available servers to join.")
        return
    end

    local serverToJoin = availableServers[math.random(1, #availableServers)]

    local success, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, serverToJoin.id, LocalPlayer)
    end)

    if not success then
        warn("❌ Failed to teleport:", err)
    else
        print("✅ Teleported to server ID:", serverToJoin.id)
    end
end

TeleportToAnyServer(game.PlaceId)
