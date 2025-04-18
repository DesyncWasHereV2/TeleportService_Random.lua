local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local PlaceId = game.PlaceId
local Cursor = nil

repeat task.wait() until game.JobId and #game.JobId > 5

local function GetServers(cursor)
	local url = "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
	if cursor then
		url = url .. "&cursor=" .. cursor
	end

	local success, result = pcall(function()
		return HttpService:JSONDecode(game:HttpGet(url))
	end)

	if success and result and result.data then
		return result
	end

	warn("❌ Failed to get server list.")
	return nil
end

local function HopToAnyNonFullServer()
	while true do
		print("📄 Requesting server list...")
		local servers = GetServers(Cursor)
		if not servers then break end

		for _, server in ipairs(servers.data) do
			print("➡️ Server:", server.id, "Players:", server.playing, "/", server.maxPlayers)
			if server.playing < server.maxPlayers and server.id ~= game.JobId then
				print("✅ Found non-full server, hopping:", server.id)
				TeleportService:TeleportToPlaceInstance(PlaceId, server.id, Players.LocalPlayer)
				return
			end
		end

		Cursor = servers.nextPageCursor
		if not Cursor then break end
		task.wait(0.5)
	end

	warn("⚠️ No non-full servers found.")
end

HopToAnyNonFullServer()
