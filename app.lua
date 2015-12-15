-- Copyright (c) 2015 by Geekscape Pty. Ltd.  Licence LGPL V3.

local module = {}

local gc = config.GARAGE -- just a quicker way to reference this applications specific config


-- Main application startup function which is called after the
-- framework is loaded by init.lua. Here we do anything any
-- other app would, like opening GPIO pins and MQTT subs
module.start = function()

  if gc.RELAY and gc.OPEN and gc.CLOSED and gc.DELAY then

    print("GarageNodeMCU Configuration Found")

    -- Setup the GPIO pins for sensing and interacting with the garage door opener
    -- and the door itself. The RELAY pin is what triggers the opener to toggle
    -- the door position. OPEN and CLOSED are both reed sensors for the door
    gpio.mode(gc.RELAY, gpio.OUTPUT)

    -- Because we are using the internal pullup, the sensor is considered "on" when 
    -- the voltage drops to ground. If the voltage on the open sensor drops then
    -- we know the door just opened. When the sensor rises the door is closing
    gpio.mode(gc.OPEN, gpio.INPUT, gpio.PULLUP)
    gpio.trig(gc.OPEN, "both", module.onOpenChange)


    -- In the same way the OPEN sensor works this sensor is considered "on" when
    -- the voltage drops to ground. If the voltage on the closed sensor drops
    -- then we know the door just closed. If it rises, the door is opening
    gpio.mode(gc.CLOSED, gpio.INPUT,gpio.PULLUP)
    gpio.trig(gc.CLOSED, "both", module.onCloseChange)
   
  else
    print("GarageNodeMCU Configuration is missing, check config.lua")
  end
end

-- Here we have to do something I didn't want to do, but in the end it had to be done
-- Because we cannot connect two interrupts to a pin (one for up and one for down)
-- we have to do our dispatching in a status change function. Lame, but it works
module.onOpenChange = function(type)
  if (type == "up") then
    module.closing()
  end
  if (type == "down") then
    module.open()
  end
end

module.onCloseChange = function(type)
  if (type == "up") then
    module.opening()
  end
  if (type == "down") then
    module.closed()
  end
end

module.opening = function()
  print("OPENING")
  -- door is openinesg

end

module.open = function()
  print("OPEN")
  -- door is now open

  -- publish status

end

module.closing = function()
  print("CLOSING")
  --door is closing

end

module.closed = function()
  print("CLOSED")
  -- door is now closed

end


-- open the door
module._open = function()
  if (module.status() ~= "OPEN") then
    if (module._toggle()) then
      return true
    end
  end
  return false
end

-- close the door
module._close = function()
  if (module.status() ~= "CLOSED") then
    if (module._toggle()) then
      return true
    end
  end
  return false
end

-- toggle the relay, only local
module._toggle = function()
  gpio.write(gc.RELAY, gpio.HIGH)
  tmr.delay(gc.DELAY)
  gpio.write(gc.RELAY, gpio.LOW)
  return true
end

-- check the current status of the sensors
module.status = function()
  local open = gpio.read(gc.OPEN)
  local closed = gpio.read(gc.CLOSED)

  if (open == 0) then
    return "OPEN"
  end

  if (closed == 0) then
    return "CLOSED"
  end

  return "IDUNNO"
end

-- HTTP GET /api/status 
module.http_get_api_status = function()
  return module.status()
  -- read status of sensors
  -- set module operating status
  -- return to caller
end

-- HTTP GET /api/toggle
module.http_get_api_toggle = function()
  if(module._toggle()) then
    return "TOGGLED RELAY"
  else
    return "ERROR"
  end
end

-- HTTP GET /api/open
module.http_get_api_open = function()
  if (module._open()) then
    return "OPENING"
  else
    return "DOOR ALREADY OPEN"
  end  
end

-- HTTP GET /api/close
module.http_get_api_close = function()
  if (module._close()) then
    return "CLOSING"
  else
    return "DOOR ALREADY CLOSED"
  end  
end

-- HTTP GET /info
module.http_get_info = function()
  -- return module info
  -- ip, ap, subnet
  -- chip id, node id
  -- current status
  -- last activity
end


return module
