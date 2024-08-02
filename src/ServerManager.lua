-- ServerManager 1.0.2
--
-- This Script has been developed by Maatijaa. Also known as Paradoxer.
--
-- Project is licensed by MIT License.
--
-- This Module is a combination of all modules, and heavily modified which gives more features to this script.
--
-- You can contribute to this project via our https://github.com/Maatijaa/ServerManager/ github page.

local ServerManager = {}

-- Maintenance Module - list player names/ids which you want to join the game during the maintenance break.
local bypassList = {
	Usernames = {},
	UserIds = {}
}

-- Whitelist Module - list player names/ids which are allowed to join the game.
local whitelist = {
	Usernames = {}, -- Add usernames of users who you want to join the game. This is only works if Whitelist is enabled.
	UserIds = {} -- Instead of Usernames, you can add UserIds. Also Works only if Whitelist Module is enabled!
}

-- Blacklist Modules - list player names/ids and group ids which are blocked from joining the game.
local playerBlacklist = {
	Usernames = {}, -- Stores username with reason
	UserIds = {} -- Stores userId with reason
}

local groupBlacklist = {
	GroupIds = {} -- Stores groupId with reason
}

-- You can enable/disable modules here.
local isMaintenanceMode = false
local isAccountAgeCheckEnabled = false
local isAltDetectionEnabled = false
local isGroupOnlyEnabled = false
local isWhitelistEnabled = false
local isPlayerBlacklistEnabled = false
local isGroupBlacklistEnabled = false

-- Parameters for each method available in this version of ServerManager Module.
local minAccountAge = 30 -- This is Account Age module, used same for Anti-alt modules.
local altDetectionThreshold = 10 -- This is AltDetection module, currently in beta. The number 10 means how much player has played games before joining this game.
local requiredGroupId = 123456 -- You can add your groupID here.


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

function ServerManager:AddPlayerBlacklistUsername(username, reason)
	playerBlacklist.Usernames[username] = reason
end

function ServerManager:AddPlayerBlacklistUserId(userId, reason)
	playerBlacklist.UserIds[userId] = reason
end

function ServerManager:RemovePlayerBlacklistUsername(username)
	playerBlacklist.Usernames[username] = nil
end

function ServerManager:RemovePlayerBlacklistUserId(userId)
	playerBlacklist.UserIds[userId] = nil
end

function ServerManager:IsPlayerBlacklisted(player)
	local username = player.Name
	local userId = player.UserId

	if playerBlacklist.Usernames[username] then
		return true, playerBlacklist.Usernames[username]
	end

	if playerBlacklist.UserIds[userId] then
		return true, playerBlacklist.UserIds[userId]
	end

	return false
end

function ServerManager:AddGroupBlacklist(groupId, reason)
	groupBlacklist.GroupIds[groupId] = reason
end

function ServerManager:RemoveGroupBlacklist(groupId)
	groupBlacklist.GroupIds[groupId] = nil
end

function ServerManager:IsGroupBlacklisted(player)
	for groupId, reason in pairs(groupBlacklist.GroupIds) do
		if player:IsInGroup(groupId) then
			return true, reason
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


function ServerManager:PlayerAdded(player)
	if isPlayerBlacklistEnabled then
		local blacklisted, reason = ServerManager:IsPlayerBlacklisted(player)
		if blacklisted then
			print("Player blacklisted. Kicking: " .. player.Name .. " Reason: " .. reason)
			player:Kick("SM - You are blacklisted from joining this game. Reason: " .. reason)
			return
		end
	end

	if isGroupBlacklistEnabled then
		local blacklisted, reason = ServerManager:IsGroupBlacklisted(player)
		if blacklisted then
			print("Player in blacklisted group. Kicking: " .. player.Name .. " Reason: " .. reason)
			player:Kick("SM - You are in a blacklisted group. Reason: " .. reason)
			return
		end
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
		local gameCount = #player:GetPlayerGames()
		if gameCount < altDetectionThreshold and not ServerManager:CanBypass(player) then
			print("Alt account detected. Kicking: " .. player.Name)
			player:Kick("SM - Alt account detected. Access denied.")
			return
		end
	end

	if isGroupOnlyEnabled then
		local inGroup = player:IsInGroup(requiredGroupId)
		if not inGroup and not ServerManager:CanBypass(player) then
			print("Player not in group. Kicking: " .. player.Name)
			player:Kick("SM - You must join Group in order to proceed...")
			return
		end
	end
end

game.Players.PlayerAdded:Connect(function(player)
	ServerManager:PlayerAdded(player)
end)

return ServerManager
