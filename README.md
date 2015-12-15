# GarageNodeMCU
NodeMCU (ESP8266) based garage door controller application in Lua. Allows you to wirelessly control a garage door, and check it's status (open/closed) remotely.

# Installation
1. Copy config.lua-example to config.lua and edit the settings to match your setup
2. Write framework.lua, application.lua, config.lua, and init.lua to your NodeMCU (using bepursuant/SublimeNodeMCU for example, or ESPlorer)
3. Reset your NodeMCU. You should now be able to access the api at the {ip address}/api to do things like check the status, open, or close the door.