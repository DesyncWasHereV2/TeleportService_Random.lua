local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local PlaceId = game.PlaceId
local Cursor = nil

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

	return nil
end

local function HopToAnyNonFullServer()
	while true do
		local servers = GetServers(Cursor)
		if not servers then break end

		for _, server in ipairs(servers.data) do
			if server.playing < server.maxPlayers and server.id ~= game.JobId then
				print("🔁 Hopping to non-full server:", server.id)
				TeleportService:TeleportToPlaceInstance(PlaceId, server.id, Players.LocalPlayer)
				return
			end
		end

		Cursor = servers.nextPageCursor
		if not Cursor then break end
	end

	warn("❌ No non-full servers found.")
end

HopToAnyNonFullServer()
