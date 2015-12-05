y = require "yahoo-weather"
s = require "servo"
g = require "globals"

function check(i, list)
  for var in list do
     if var == i then
      print(var)
      return 1
     end
  end
  return nil
end

-- yahoo codes -- available at https://developer.yahoo.com/weather/documentation.html
storm = {0,1,2,3,4,19,37,38,39,40,41,42,43,45,46,47};
snow  = {5,6,7,8,9,10,13,14,15,16,18};
rain  = {11,12,17,35};
fog   = {20,21,22,25};
wind  = {23,24};
cloud = {26,27,28,29,30,44};
fair  = {31,32,33,34,36};
function toServoRange(code)
    if check(code, storm) then
      print("storm");
      g.servo.value = 0;
    elseif check(code, snow) then
      print("snow");
      g.servo.value = 128;
    elseif check(code, rain) then
      print("rain");
      g.servo.value = 256;
    elseif check(code, fog) then
      print("fog");
      g.servo.value = 512;
    elseif check(code, wind) then
      print("wind");
      g.servo.value = 640;
    elseif check(code, cloud) then
      print("cloud");
      g.servo.value = 768;
    elseif check(code, fair) then
      print("fair");
      g.servo.value = 896;
    else
      print("hey");
      g.servo.value = 896;
      -- remaining reserved for special
    end
    pwm.setduty(pin, g.servo.value);
end

function getWeather()
    y.fetch(function(Temp, Code, Text)
        iTemp = Temp or "?"
        iCode = Code or "?"
        iText = Text or "?"
        print(iText)
        toServoRange(iCode)
    end)
end

-- Set Pin2 to output(led user)
pin2=4
gpio.mode(pin2,gpio.OUTPUT)

-- Connect Wifi
local SSID, PASS, WOEID = dofile("fs_settings.lua").read();
print("Setting STATION mode");
print("SSID:"..SSID);
print("PASS:"..PASS);
wifi.setmode(wifi.STATION);
wifi.sta.config(SSID,PASS);
wifi.sta.autoconnect(1);

local led_val=0;
tmr.alarm (1, 800, 1, function ( )
  if (wifi.sta.getip() == nil) then
     if(led_val == 0)then
      gpio.write(pin2, gpio.HIGH);
      led_val=1;
     else
      gpio.write(pin2, gpio.LOW);
      led_val=0;
     end
     print ("Waiting for Wifi connection")
  else
     tmr.stop (1)
     print ("Config done, IP is " .. wifi.sta.getip ( ))
  end
end)

led_val=nil;
SSID=nil;
PASS=nil;
WOEID=nil;
print("Connected. IP: ", wifi.sta.getip())
print(node.heap())


--s.init()
tmr.alarm(2, 10*1000, 1, getWeather ) -- 5*60*1000 = every 5 minutes
