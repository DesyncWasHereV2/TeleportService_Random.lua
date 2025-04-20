local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

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

local function teleportFailed()
    local promptGui = CoreGui:FindFirstChild("RobloxPromptGui")
    if promptGui and promptGui.Enabled then
        local overlay = promptGui:FindFirstChild("promptOverlay")
        if overlay and overlay.Visible then
            local errorPrompt = overlay:FindFirstChild("ErrorPrompt")
            if errorPrompt and errorPrompt.Visible then
                return true
            end
        end
    end
    return false
end

while true do
    local jobId = getRandomJobId()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, Players.LocalPlayer)

    task.wait(7)

    if teleportFailed() then
        warn("Teleport failed. Retrying...")
        task.wait(5)
    else
        break
    end
end
