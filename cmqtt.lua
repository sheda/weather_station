local g = require "globals"

local broker = "your_broker_url"; -- IP or hostname of MQTT broker
local mqttport = 1883; -- MQTT port (default 1883)
local userID = "USER"; -- username for authentication if required
local userPWD  = "PWD"; -- user password if needed for security
local clientID = "TONY_STARK";

local cmqtt = {}

-- LEDs Actions
function cmqtt.led_wr(pl)
 local pl = pl or "off"
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

function cmqtt.wtf(act, pl)
 local pl = pl or "0";
 local ipl = tonumber(pl);
 if(act=="set")then
  g.poscnt.value = ipl;
  g.servo.value = 121;
  pwm.setduty(g.servo.pin, 121); -- refer to weatherStation
 elseif(act == "clr")then
  g.poscnt.value = 0;
  if(g.servo.value==121)then
    pwm.setduty(g.servo.pin, 107); -- refresh servo to boot value if not already refreshed
  else
    pwm.setduty(g.servo.pin, g.servo.value); -- refresh servo to current weather value
  end
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
 if (topic == "/sheda/"..clientID.."/Led/set") then
  cmqtt.led_wr(data)
 end
 if topic == ("/sheda/"..clientID.."/Led/get") then
  m:publish("/sheda/node", '{ "status": "'..cmqtt.led_rd()..'" }', 0, 0, function(conn)end)
 end  
 if (topic == "/sheda/"..clientID.."/WTF/set") then
  cmqtt.wtf("set",data)
 end
 if topic == ("/sheda/"..clientID.."/WTF/clr") then
  cmqtt.wtf("clr","0")
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
