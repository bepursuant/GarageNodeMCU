-- This is the main NodeMCU/Lua startup script, which is called by the NodeMCU firmware
-- automatically when the node is powered. In it, we will load the configuration and
-- framework from their associated files and then boot to the application itself.

print("Delaying startup for 5 seconds. If caught in a boot loop, issue \r\na tmr.stop(0) command within the next 5 seconds to regain control.")

tmr.alarm(0, 5000, 0,  function()
	print("Initializing...")

	-- Anyone who has used a NodeMCU will be familiar with its memory constraints. To
	-- help address the lack of heap memory let's start by compiling our lua files
	-- into smaller binary files using the built-in node.compile functionality.
	local appFiles = {'app.lua', 'config.lua', 'framework.lua'}
	for i, f in ipairs(appFiles) do
		if file.open(f) then
			file.close()
			print('Compiling:', f)
			node.compile(f)
			file.remove(f)
			collectgarbage()
		end
	end
	appFiles = nil
	collectgarbage()


	app = {}
	-- Load configuration file
	print("Loading Configuration...")
	config = require("config")

	-- Load the framework and kick it all off
	print("Loading Framework...")
	framework = require("framework")

	-- Load the application, default 'app'
	print("Loading Application...")
	app = require("app")

	framework.start()
	app.start()

end)