-- Copyright (c) 2015 by Geekscape Pty. Ltd.  Licence LGPL V3.

local module = {}

gc = config.GARAGE

module.start = function()
    if gc.BUTTON and gc.RELAY then
       print("GarageNodeMCU Configuration Loaded")

        --[[if config.MQTT then
            app.mqtt.publish("/topic","hello",0,0, function(conn) 
                print("sent") 
            end)
    
            app.mqtt.on("message", function(conn, topic, msg)   
               print("Recieved:" .. topic .. ":" .. msg)   
               if (msg=="GO") then  -- Activate Door Button
                  --print("Activating Door")   
                  gpio.write(3,gpio.LOW)  
                  tmr.delay(1000000) -- wait 1 second
                  gpio.write(3,gpio.HIGH)  
               else  
                  print("Invalid - Ignoring")   
               end   
            end)
        end
        ]]--


        if config.HTTP then



        end

        

       
    else
        print("GarageNodeMCU Configuration is missing, check config.lua")
    end
end


module.open = function()
end

module.close = function()
end

module.http_get_status = function()
  -- read status of sensors
  -- set module operating status
  -- return to caller
end

module.http_post_status = function(newStatus)
  -- If current status == newStatus, return error code
  -- otherwise, call open/close function
  -- return to caller
end

module.http_get_info = function()
  -- return module info
  -- ip, ap, subnet
  -- chip id, node id
  -- current status
  -- last activity
end


return module
