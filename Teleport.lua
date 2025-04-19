local function getRandomJobId()
    while true do
        local success, data = pcall(function()
            return game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. game.PlaceId .. '/servers/Public?sortOrder=Asc&limit=100'))
        end)

        if success and data and data.data then
            local servers = data.data
            if #servers > 0 then
                local randomServer = servers[math.random(1, #servers)]
                local jobId = randomServer.id
                print("Random JobId: " .. jobId)
                break
            end
        else
            print("Data invalid or error, retrying...")
        end
        
        task.wait(60)
    end
end

local RandomJobId = getRandomJobId()
game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, RandomJobId, game.Players.LocalPlayer)
