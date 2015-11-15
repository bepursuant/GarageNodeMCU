--[[ bepursuant/GarageNodeMCU
A NodeMCU based garage door opener/monitor
--]]

local HOST = "192.168.1.1"
local PORT = 1883
local USER = ""
local PASS = ""

local CLIENT = "ESP-" .. node.chipid()

local RELAY = 4
local SENSOR_CLOSED = 3
local SENSOR_OPEN = 2

--------------------------------------------------
local STATES = {closed=0, open=1, transport=2}

function readSensors()

   -- pack the readings into a 'tuple' so that we can easily check them below
   local reading = {gpio.read(SENSOR_OPEN), gpio.read(SENSOR_CLOSED)}

   --compare our reading to our state options and report accordingly
   if(reading == {0,0}) then
      --Transport
      STATE = STATES.transport
   end

   if(reading == {0,1}) then
      --Closed
      STATE = STATES.closed
   end

   if(reading == {1,0}) then
      --Open
      STATE = STATES.open
   end

   if(reading == {1,1}) then
      --Error
   end


   m:publish("openhab/garage/state", STATE, 0, 0)
   print("Published openhab/garage/state = " .. STATE )

   return STATE
end


-- hold the current state of the door
local STATE = readSensors()

print("GarageMCU Starting...")


io.write("Setting up GPIO...")
-- Setup GPIO Pins
gpio.write(SENSOR_OPEN, gpio.LOW) -- Open Sensor
gpio.mode(SENSOR_OPEN, gpio.INPUT, gpio.PULLDOWN)

gpio.write(SENSOR_CLOSED, gpio.LOW) -- Closed Sensor
gpio.mode(SENSOR_CLOSED, gpio.INPUT, gpio.PULLDOWN)

gpio.write(RELAY, gpio.HIGH) -- Open/Close Relay
gpio.mode(RELAY, gpio.OUTPUT)
print("OK!")


-- Start up mqtt
m = mqtt.Client(CLIENT, 120, USER, PASSWORD)

-- Register Last Will and Testament
io.write("Registering last will and testament...")
m:lwt("/lwt", "offline", 0, 0)
print("OK!")

function connect()

   io.write("Connecting to MQTT Host at [" .. HOST .. ":".. PORT .."]...")

   m:connect(HOST, PORT, 0, function(conn) 
      print("OK!")

      io.write("Subscribing to relay...")
      m:subscribe("openhab/garage/relay1",0, function(conn) 
         print("OK!") 

      end)
   end)
end

-- Connect to MQTT Server
connect()

-- Reconnect to mqtt server if needed
m:on("offline", function(con)
   print ("Server connection lost - attempting to reconnect")
   tmr.alarm(1, 10000, 0, function()
      connect()
   end)
end)



 -- Register events for both sensors so that we don't have to manually
 -- poll them
io.write("Registering sensor events...")
gpio.trig({SENSOR_CLOSED, SENSOR_OPEN}, "both", function (level)

   readSensors()

end)
print("OK!")


-- MQTT Message Processor
io.write("Registering message processor...")
m:on("message", function(conn, topic, msg)
   io.write(">> Received: " .. topic .. ":" .. msg .."...")   
   if (msg == "GO") then  -- Activate Door Button
      io.write("triggering door...")
      gpio.write(RELAY, gpio.LOW)  
      tmr.delay(1000000) -- wait 1 second
      gpio.write(RELAY, gpio.HIGH)
      print("OK!")
   else  
      print("NOK!")   
   end   
end)
print("OK!")

