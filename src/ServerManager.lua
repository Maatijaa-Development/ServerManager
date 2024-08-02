-- ServerManager 1.0.0
--
-- This Script has ben developed by Maatijaa. Also known as Paradoxer.
--
-- Project is licensed by MIT License.
--
-- This Module is combination of all modules, and heavly modified which gives more features into this script.
--
-- You can contribute to this project 


local ServerManager = {}

-- This is Maintenance Module, list player names/ids which you want to join game during maintenance break.
local bypassList = {
	Usernames = {},
	UserIds = {}
}

-- You can enable/disable modules here.
local isMaintenanceMode = false
local isAccountAgeCheckEnabled = true
local isAltDetectionEnabled = false
local isGroupOnlyEnabled = false

-- This is parameters for each method avilable in this version of ServerManager Module,
local minAccountAge = 10000 -- This is Account Age module used same for Anti-alt modules.
local altDetectionThreshold = 10 -- This is AltDetection module, currently in beta. The number 10 means how much player has played games before joining in this game.
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
	if isMaintenanceMode and not ServerManager:CanBypass(player) then
		player:Kick("SM - This server is under development.")
		return
	end

	if isAccountAgeCheckEnabled then
		local accountAge = player.AccountAge
		if accountAge < minAccountAge and not ServerManager:CanBypass(player) then
			player:Kick("SM - Your account must be at least " .. minAccountAge .. " days old to play.")
			return
		end
	end

	if isAltDetectionEnabled then
		local gameCount = #player:GetPlayerGames() 
		if gameCount < altDetectionThreshold and not ServerManager:CanBypass(player) then
			player:Kick("SM - Alt account detected. Access denied.")
			return
		end
	end

	if isGroupOnlyEnabled then
		local inGroup = player:IsInGroup(requiredGroupId)
		if not inGroup and not ServerManager:CanBypass(player) then
			player:Kick("SM - You must be a member of the group to play.")
			return
		end
	end
end

game.Players.PlayerAdded:Connect(function(player)
	ServerManager:PlayerAdded(player)
end)

return ServerManager
