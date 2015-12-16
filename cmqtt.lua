local g = require "globals"

local broker = "your_broker_url"; -- IP or hostname of MQTT broker
local mqttport = 1883; -- MQTT port (default 1883)
local userID = "USER"; -- username for authentication if required, let blank if not password required
local userPWD  = "PWD"; -- user password if needed for security, let blank if not password required
local clientID = "TONY_STARK";

local cmqtt = {}

-- LEDs Actions
function cmqtt.wtf(act, pl)
 local pl = pl or "0";
 local ipl = tonumber(pl);
 if(act=="set")then
  g.poscnt.value = ipl;
  g.servo.value = g.poke_position;
  pwm.setduty(g.servo.pin, g.poke_position); -- refer to weatherStation
 end
end

-- When message are received
function cmqtt.mqtt_mess(conn, topic, data)
 local idata = data or "";
 print(topic..":"..idata);
 
 if topic == "/sheda/reset" then -- general reset
  node.restart()
 elseif topic == "/sheda/reset/"..clientID then -- node specific reset
  node.restart()
 end
 if (topic == "/sheda/"..clientID.."/poke") then
    cmqtt.wtf("set","0");
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
     m:subscribe("/sheda/"..clientID.."/poke",0,
     function(conn)
      print(node.heap())  
      m:publish("/sheda/node", '{ "node": "'..clientID..'", "features": ["reset", "poke"] }', 0, 0,
      function(conn)
       print("published clientID and features to /node")
      end) --PUB-node 
     end) --SUB-WTF
    end) --SUB-ResetClient
   end) --SUB-Reset
  end) --Connect
end -- funtion init

return cmqtt
