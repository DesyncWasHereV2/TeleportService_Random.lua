local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local function getServers(pages)
    local allServers = {}
    local cursor = nil
    local baseUrl = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"

    for i = 1, pages do
        local url = baseUrl
        if cursor then
            url = url .. "&cursor=" .. cursor
        end

        local success, data = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)

        if success and data and data.data then
            for _, server in ipairs(data.data) do
                table.insert(allServers, server)
            end
            cursor = data.nextPageCursor
            if not cursor then break end
        else
            warn("Failed to get servers for page " .. i)
            warn("Success:", success)
            warn("Raw result:", data)
            break
        end
    end

    return allServers
end

local function getRandomJobId()
    local start = tick()
    while true do
        local servers = getServers(3)
        if #servers > 0 then
            local chosenServer = servers[math.random(1, #servers)]
            local jobId = chosenServer.id
            print("Found server:", jobId)
            print("Time taken: " .. (tick() - start) .. " seconds")
            return jobId
        else
            warn("No servers found. Retrying in 60 seconds...")
            task.wait(60)
        end
    end
end

local jobId = getRandomJobId()
if jobId then
    local success, errorMessage = pcall(function()
        return TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Players.LocalPlayer)
    end)

    print(success, errorMessage)
end
