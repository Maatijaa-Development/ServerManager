-- SMM - SystemMessagesManager
-- This system is still in BETA. Will get updated soon.
-- Make sure you have SM_Module folder in ServerScriptService otherwise this module will NOT load.
--
-- If you want to contribute to this project | https://github.com/Maatijaa-Development/ServerManager


local function checkServerManager()
	local SM_Module = ServerScriptService:WaitForChild("SM_Module")
	if SM_Module then
		local ServerManager = SM_Module:WaitForChild("ServerManager")
		if ServerManager then
			print("ServerManager API has been loaded successfully")
			return true
		else
			print("ServerManager API could not be found. Disabling SMM")
			return false
		end
	else
		print("SM_Module folder could not be found. Disabling SMM")
		return false
	end
end

local messages = {
	"Just put fries in the bag sir.", -- This is an example message.

  -- You can add as many messages as you want.
}

local interval = 1 -- This is interval based on seconds
local messagesEnabled = true -- This controls whether messages are sent or not

local function sendMessages()
	while messagesEnabled do
		for _, msg in ipairs(messages) do
			if not messagesEnabled then
				break
			end
			game.StarterGui:SetCore("ChatMakeSystemMessage", {
				Text = "[System:] " .. msg; -- This is the Prefix
				Color = Color3.new(0.741176, 0, 0);
			})
			wait(interval)
		end
	end
end

local function toggleMessages(state)
	messagesEnabled = state
	if messagesEnabled then
		print("Messages are now enabled.")
		sendMessages()
	else
		print("Messages are now disabled.")
	end
end

-- to start sending messages do true to stop do false simple as fu-
toggleMessages(false) 

