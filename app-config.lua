-- Copyright (c) 2015 by Geekscape Pty. Ltd.  Licence LGPL V3.

local config = {}

config.NAME = "ESP-" .. node.chipid()

-- Station Mode (Client/Node)
config.STA = {}

config.HTTP = true

--TODO: add AP mode
--config.AP = {}
--config.AP.SSID = config.NAME
--config.AP.KEY

--TODO: add MQTT mode
--config.MQTT = {}
--config.MQTT.HOST = {}
--config.MQTT.HOST.IP = "192.168.0.1"
--config.MQTT.HOST.PORT = 4000
--config.MQTT.USER = "USER"
--config.MQTT.PASS = "PASS"


config.GARAGE = {}
config.GARAGE.RELAY = 5		-- the relay pin
config.GARAGE.OPEN = 6		-- the open sensor pin
config.GARAGE.CLOSED = 7	-- the closed sensor pin
config.GARAGE.DELAY = 200000 --how long to hold relay closed to trigger door

return config
