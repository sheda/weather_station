local g = require "globals"

local broker = "your_broker_url"; -- IP or hostname of MQTT broker
local mqttport = 1883; -- MQTT port (default 1883)
local userID = "USER"; -- username for authentication if required
local userPWD  = "PWD"; -- user password if needed for security
local clientID = "TONY_STARK";

local cmqtt = {}

-- LEDs Actions
function cmqtt.led_wr(pl)
 if(pl=="on")then
  g.led.value = 1;
  gpio.write(g.led.pin,gpio.HIGH);
 elseif(pl == "off")then
  gpio.write(g.led.pin,gpio.LOW);
  g.led.value = 0;
 end
end
function cmqtt.led_rd()
 return g.led.value;
end

-- When message are received
function cmqtt.mqtt_mess(conn, topic, data)
 local idata = data or "err"
 print(topic..":"..idata)
 
 if topic == "/sheda/reset" then -- general reset
  node.restart()
 elseif topic == "/sheda/reset/"..clientID then -- node specific reset
  node.restart()
 end
 
 print("x /sheda/"..clientID.."/WTF/set");
 
 if (topic == "/sheda/"..clientID.."/WTF/set") then
  cmqtt.led_wr(idata)
 end
 if topic == ("/sheda/"..clientID.."/WTF/get") then
  m:publish("/sheda/node", '{ "status": "'..cmqtt.led_rd()..'" }', 0, 0, function(conn)end)
 end  
end

-- initilisation
function cmqtt.init()
 m = mqtt.Client(clientID, 120, userID, userPWD)
 m:on("message", cmqtt.mqtt_mess)
 m:connect( broker , mqttport, 0,
  function(conn)
   local iclientID = clientID or "?";
   print("Connected to MQTT:"..broker ..":".. mqttport .." as "..iclientID )
   m:subscribe("/sheda/reset",0,
   function(conn)
    print(node.heap())
    m:subscribe("/sheda/"..clientID.."/reset/",0,
    function(conn)
     print(node.heap())  
     m:subscribe("/sheda/"..clientID.."/WTF/#",0,
     function(conn)
      print(node.heap())  
      m:publish("/sheda/node", '{ "node": "'..clientID..'", "features": ["reset", "WTF"] }', 0, 0,
      function(conn)
       print("published clientID and features to /node")
      end) --PUB-node 
     end) --SUB-WTF
    end) --SUB-ResetClient
   end) --SUB-Reset
  end) --Connect
end -- funtion init

return cmqtt
