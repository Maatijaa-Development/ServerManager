-- ServerManager 1.0.2
--
-- This Script has been developed by Maatijaa. Also known as Paradoxer.
--
-- Project is licensed by MIT License.
--
-- This Module is a combination of all modules, and heavily modified which gives more features to this script.
--
-- You can contribute to this project via our https://github.com/Maatijaa/ServerManager/ github page.
--
-- Any bug can be reported on our github page https://github.com/Maatijaa/ServerManager/issues 

local ServerManager = {}

-- List of banned group IDs
local bannedGroups = {
	6652790, -- Example group ID
	16325235, -- Add as much as you want commands!
}

-- List of blacklisted player IDs
local blacklistedPlayers = {
	1351351, -- Example player ID
	87654321, -- Add more player IDs to block
}

-- Parameters to enable or disable functionalities
local isGroupBlacklistEnabled = false
local isPlayerBlacklistEnabled = false
local isWhitelistEnabled = false
local isMaintenanceMode = false
local isAccountAgeCheckEnabled = false
local minAccountAge = 30
local isAltDetectionEnabled = false
local altDetectionThreshold = 10
local isGroupOnlyEnabled = false
local requiredGroupId = 0

-- List of users who can bypass all checks
local bypassList = {
	Usernames = {},
	UserIds = {}
}

-- List of users who are whitelisted
local whitelist = {
	Usernames = {}, -- Put players username. If you dont want to use UserID.
	UserIds = {}, -- Put players ID. If you dont want to use username.
}


local function checkGroupBlacklist(player)
	if isGroupBlacklistEnabled then
		local blacklisted = ""
		for i = 1, #bannedGroups do
			local groupId = bannedGroups[i]
			if player:IsInGroup(groupId) then
				local groupInfo = game:GetService("GroupService"):GetGroupInfoAsync(groupId)
				blacklisted = blacklisted .. " " .. groupInfo.Name
				player:Kick("SM - You can't join because you are in the following blacklisted groups:" .. blacklisted)
				return
			end
		end
	end
end


local function checkPlayerBlacklist(player)
	if isPlayerBlacklistEnabled then
		for _, blacklistedId in pairs(blacklistedPlayers) do
			if player.UserId == blacklistedId then
				player:Kick("SM - You are blacklisted from joining this game.")
				return
			end
		end
	end
end


function ServerManager:AddBypassUsername(username)
	table.insert(bypassList.Usernames, username)
end

function ServerManager:AddBypassUserId(userId)
	table.insert(bypassList.UserIds, userId)
end


function ServerManager:RemoveBypassUsername(username)
	for i, v in ipairs(bypassList.Usernames) do
		if v == username then
			table.remove(bypassList.Usernames, i)
			break
		end
	end
end

function ServerManager:RemoveBypassUserId(userId)
	for i, v in ipairs(bypassList.UserIds) do
		if v == userId then
			table.remove(bypassList.UserIds, i)
			break
		end
	end
end


function ServerManager:CanBypass(player)
	local username = player.Name
	local userId = player.UserId

	for _, v in ipairs(bypassList.Usernames) do
		if v == username then
			return true
		end
	end

	for _, v in ipairs(bypassList.UserIds) do
		if v == userId then
			return true
		end
	end

	return false
end


function ServerManager:AddWhitelistUsername(username)
	table.insert(whitelist.Usernames, username)
end

function ServerManager:AddWhitelistUserId(userId)
	table.insert(whitelist.UserIds, userId)
end


function ServerManager:RemoveWhitelistUsername(username)
	for i, v in ipairs(whitelist.Usernames) do
		if v == username then
			table.remove(whitelist.Usernames, i)
			break
		end
	end
end

function ServerManager:RemoveWhitelistUserId(userId)
	for i, v in ipairs(whitelist.UserIds) do
		if v == userId then
			table.remove(whitelist.UserIds, i)
			break
		end
	end
end


function ServerManager:IsWhitelisted(player)
	local username = player.Name
	local userId = player.UserId

	for _, v in ipairs(whitelist.Usernames) do
		if v == username then
			return true
		end
	end

	for _, v in ipairs(whitelist.UserIds) do
		if v == userId then
			return true
		end
	end

	return false
end

function ServerManager:SetWhitelist(state)
	isWhitelistEnabled = state
end

function ServerManager:SetMaintenanceMode(state)
	isMaintenanceMode = state
end

function ServerManager:SetAccountAgeCheck(state, minAge)
	isAccountAgeCheckEnabled = state
	if minAge then
		minAccountAge = minAge
	end
end

function ServerManager:SetAltDetection(state, threshold)
	isAltDetectionEnabled = state
	if threshold then
		altDetectionThreshold = threshold
	end
end

function ServerManager:SetGroupOnly(state, groupId)
	isGroupOnlyEnabled = state
	if groupId then
		requiredGroupId = groupId
	end
end

function ServerManager:SetPlayerBlacklist(state)
	isPlayerBlacklistEnabled = state
end

function ServerManager:SetGroupBlacklist(state)
	isGroupBlacklistEnabled = state
end


game.Players.PlayerAdded:Connect(function(player)
	checkGroupBlacklist(player)
	checkPlayerBlacklist(player)

	if isPlayerBlacklistEnabled and ServerManager:CanBypass(player) then
		print("Player blacklisted. Kicking: " .. player.Name)
		player:Kick("SM - You are blacklisted from joining this game.")
		return
	end

	if isGroupBlacklistEnabled and ServerManager:CanBypass(player) then
		print("Player in blacklisted group. Kicking: " .. player.Name)
		player:Kick("SM - You are in a blacklisted group.")
		return
	end

	if isWhitelistEnabled and not ServerManager:IsWhitelisted(player) then
		print("Player not whitelisted. Kicking: " .. player.Name)
		player:Kick("SM - You are not whitelisted.")
		return
	end

	if isMaintenanceMode and not ServerManager:CanBypass(player) then
		print("Server in maintenance mode. Kicking: " .. player.Name)
		player:Kick("SM - This server is under maintenance.")
		return
	end

	if isAccountAgeCheckEnabled then
		local accountAge = player.AccountAge
		if accountAge < minAccountAge and not ServerManager:CanBypass(player) then
			print("Account too young. Kicking: " .. player.Name)
			player:Kick("SM - Your account must be at least " .. minAccountAge .. " days old to play.")
			return
		end
	end

	if isAltDetectionEnabled then
		local gameCount = #player:GetGamesPlayed()
		if gameCount < altDetectionThreshold and not ServerManager:CanBypass(player) then
			print("Player suspected of being an alt. Kicking: " .. player.Name)
			player:Kick("SM - You are suspected of being an alt.")
			return
		end
	end

	if isGroupOnlyEnabled and not player:IsInGroup(requiredGroupId) then
		print("Player not in required group. Kicking: " .. player.Name)
		player:Kick("SM - You must be in group ID " .. tostring(requiredGroupId) .. " to join.")
		return
	end
end)

return ServerManager
