s = require "servo"
g = require "globals"
q = require "cmqtt"

local serv_pwm = {storm=30, --p90
                 snow=41, --p67
                 rain=52, --p45
                 fog=63, --p22
                 wind=74,   --0
                 cloud=85, --m22
                 fair=96, --m45
                 boot=107,--m67
                 wtf=121};--m90

function list_iter (t)
  local i = 0
  local n = table.getn(t)
  return function ()
           i = i + 1
           if i <= n then return t[i] end
           end
end

function check(i, table)
  local iter = list_iter(table)
  for var in iter do
     if var == i then
      print(var)
      iter=nil;
      return 1
     end
  end
  iter=nil;
  return nil
end

-- yahoo codes -- available at https://developer.yahoo.com/weather/documentation.html
-- Servo driver from 1% to 10% theorically(T=20ms, pwm from 1000us-2000us)
-- In pratic use abaque for PWM value according to angles
-- +90=30, +67.5=41, +45=52, +22.5=63,0=74,-22.5=85,-45=96,-67.5=107,-90=121
function toServoRange(code)
    local storm = {"0","1","2","3","4","19","37","38","39","40","41","42","43","45","46","47"};
    local snow  = {"5","6","7","8","9","10","13","14","15","16","18"};
    local rain  = {"11","12","17","35"};
    local fog   = {"20","21","22","25"};
    local wind  = {"23","24"};
    local cloud = {"26","27","28","29","30","44"};
    local fair  = {"31","32","33","34","36"};

   
    if check(code, storm) then
      print("storm");
      g.servo.value = serv_pwm["storm"];
    elseif check(code, snow) then
      print("snow");
      g.servo.value = serv_pwm["snow"];
    elseif check(code, rain) then
      print("rain");
      g.servo.value = serv_pwm["rain"];
    elseif check(code, fog) then
      print("fog");
      g.servo.value = serv_pwm["fog"];
    elseif check(code, wind) then
      print("wind");
      g.servo.value = serv_pwm["wind"];
    elseif check(code, cloud) then
      print("cloud");
      g.servo.value = serv_pwm["cloud"];
    elseif check(code, fair) then
      print("fair");
      g.servo.value = serv_pwm["fair"];
    else
      print("Boot");
      g.servo.value = serv_pwm["boot"];
    end
    pwm.setduty(g.servo.pin, g.servo.value);
end

function getWeather()
    y = require "yahoo-weather"
    y.fetch(function(Temp, Code, Text)
        iTemp = Temp or "?"
        iCode = Code or "?"
        iText = Text or "?"
        print(iText)
        toServoRange(iCode)
    end)
    y=nil;
    collectgarbage()
end

-- Set Pin2 to output(led user)
gpio.mode(g.servo.pin,gpio.OUTPUT);

-- init servo module
s.init();
g.servo.value = serv_pwm["boot"];
pwm.setduty(g.servo.pin, g.servo.value);

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

g.woeid=WOEID;
led_val=nil;
SSID=nil;
PASS=nil;
WOEID=nil;
print("Connected. IP: ", wifi.sta.getip())
print(node.heap())

-- mqtt
q.init();

-- routine for weather
getWeather();
tmr.alarm(2, 60*1000, 1, getWeather ) -- 5*60*1000 = every 5 minutes
