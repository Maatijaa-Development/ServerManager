-- ServerManager Loader.
--
-- This Script has been developed by Maatijaa. Also known as Paradoxer.
--
-- Project is licensed by MIT License.
--
-- This Script simply loads the ServerManager module. And ensures that its goona load without problems.

-- A bit advenced Loading System, with debug messages.. Press F9 to see them btw.
-- You can see latest change logs on our GitHub page. https://github.com/Maatijaa-Development/ServerManager

print("888888   8b   d88")
print("88    8  88b  d88")
print("  88     88YbdP88")
print("    88   88 YY 88")
print("8    88  88 YY 88")
print(" 8888    88 YY 88")

print("Loader System starting..")

print("Loading ServerManager...")
local serverManagerPath = game:GetService("ServerScriptService"):WaitForChild("SM_Module"):WaitForChild("ServerManager")
print("ServerManager Loaded Succsesfully!")

print("ServerManager Module has been loaded!")


local ServerManager = require(serverManagerPath)

print("ServerManager Module has been loaded!")

