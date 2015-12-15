-- Copyright (c) 2015 by Geekscape Pty. Ltd.  Licence LGPL V3.
function print_r ( t ) 
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    sub_print_r(t,"  ")
end

local module = {}

-- Connect to an existsing wifi access point, depending on the STA configuration.
-- This will attempt to setup a connection then check every 2.5 seconds to see
-- if an IP address has been assigned. Once that happens it stop the timer.
module.wifi_connect = function(aps)
  print("Wifi STA Connecting to " .. config.STA.SSID .. ":" .. config.STA.KEY)
  wifi.sta.config(config.STA.SSID, config.STA.KEY)
  wifi.sta.connect()
  config.STA.SSID = nil  -- more secure and save memory
  config.STA.KEY = nil
  tmr.alarm(1, 1000, 1, function()
    if wifi.sta.getip() then 
      tmr.stop(1)
      print("Wifi STA Connected as " .. wifi.sta.getip())
    end 
  end)
end


-- Connect to an existing MQTT broker, depending on the MQTT configuration.
-- This will attempt to connect to the MQTT HOST as configured and setup
-- the the default functions to connect and disconnect from the host.
module.mqtt_connect = function()
  print("MQTT Connection to broker at " .. config.MQTT.HOST .. " as user " .. config.MQTT.USER)
    module.mqtt = mqtt.Client(config.NAME, 120, config.MQTT.USER, config.MQTT.PASS)
    module.mqtt:lwt("/lwt", "offline", 0, 0)
    module.mqtt:connect(config.MQTT.HOST.IP, config.MQTT.HOST.PORT, 0, function(conn)
        print("MQTT Connected")
    end)
end


-- Setup an http server on port 80. This server will respond to the http requests
-- and dispatch them to the application function based on the request headers.
-- Any request that doesnt have a registered function will return HTTP 404.
module.http_setup = function()
    module.http = net.createServer(net.TCP, 30) 
    module.http:listen(80, function(conn) 
        conn:on("receive", function(client, headers)

          local req = dofile("httpserver-request.lc")(payload)



        
          conn:send("<H1>asdf</h1>\n")
          conn:close()         
        end)
    end)

end

module.create_http_response = function(status)
  return "HTTP/4.0 404 Not Found"
end


-- This is the main framework startup function, sometimes referred to as a dispatcher. It
-- will take care of all instantiating all of the shared application objects including
-- Wifi station and access point mode, mqtt broker connection, and the HTTP server.
module.start = function()
  -- setup wifi station
  if config.STA then
    if config.STA.SSID and config.STA.KEY then
        print("Configuring WiFi Station...")
        wifi.setmode(wifi.STATION);
        wifi.sta.getap(module.wifi_connect);
    else
        print("Configure your Wifi STA SSID and KEY, or remove the STA config key.")
    end
  end

  -- setup MQTT client
  if config.MQTT then
    if config.MQTT.HOST and config.MQTT.PORT then
        print("Configuring MQTT Client...")
        module.mqtt_connect()
    else
      print("Configure your MQTT HOST and PORT, or remove the MQTT config key.")
    end
  end

  --setup HTTP server
  if config.HTTP then
    print("Configuring HTTP Server...")
    module.http_setup()
  else
  print("no http")
  end
  
end

return module
