-- This is the main NodeMCU/Lua startup script, which is called by the NodeMCU firmware
-- automatically when the node is powered. In it, we will load the configuration and
-- framework from their associated files and then boot to the application itself.

print("Initializing FrameworkNodeMCU...")

function startup()
	app = {}
	-- load configuration file
	print("Loading Configuration...")
	config = require("config")

	-- Load the framework and kick it all off
	print("Loading Framework...")
	framework = require("framework")

	-- Load the application, default 'application'
	print("Loading Application...")
	app = require("application")

	framework.start()
	app.start()
end
startup()
--tmr.alarm(0, 1000000, 0,  startup)
