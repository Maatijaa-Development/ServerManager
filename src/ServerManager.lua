-- ServerManager 1.0.1
--
-- This Script has been developed by Maatijaa. Also known as Paradoxer.
--
-- Project is licensed by MIT License.
--
-- This Module is a combination of all modules, and heavily modified which gives more features to this script.
--
-- You can contribute to this project

local ServerManager = {}

-- Maintenance Module - list player names/ids which you want to join the game during the maintenance break.
local bypassList = {
	Usernames = {},
	UserIds = {}
}

-- Whitelist Module - list player names/ids which are allowed to join the game.
local whitelist = {
	Usernames = {},
	UserIds = {}
}

-- You can enable/disable modules here.
local isMaintenanceMode = false
local isAccountAgeCheckEnabled = false
local isAltDetectionEnabled = false
local isGroupOnlyEnabled = false
local isWhitelistEnabled = false

-- Parameters for each method available in this version of ServerManager Module.
local minAccountAge = 30 -- This is Account Age module, used same for Anti-alt modules.
local altDetectionThreshold = 10 -- This is AltDetection module, currently in beta. The number 10 means how much player has played games before joining this game.
local requiredGroupId = 123456 -- You can add your groupID here.

-- Bypass list functions
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

function ServerManager:PlayerAdded(player)
	if isWhitelistEnabled and not ServerManager:IsWhitelisted(player) then
		print("Player not whitelisted. Kicking: " .. player.Name)
		player:Kick("SM - You are not whitelisted.")
		return
	end

	if isMaintenanceMode and not ServerManager:CanBypass(player) then
		print("Server in maintenance mode. Kicking: " .. player.Name) 
		player:Kick("SM - This server is under development.")
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
			print("Alt account detected. Kicking: " .. player.Name) -- Added debug message
			player:Kick("SM - Alt account detected. Access denied.")
			return
		end
	end

	if isGroupOnlyEnabled then
		local inGroup = player:IsInGroup(requiredGroupId)
		if not inGroup and not ServerManager:CanBypass(player) then
			print("Player not in group. Kicking: " .. player.Name) -- Added debug message
			player:Kick("SM - You must join Group in order to proceed...")
			return
		end
	end
end

game.Players.PlayerAdded:Connect(function(player)
	ServerManager:PlayerAdded(player)
end)

return ServerManager
