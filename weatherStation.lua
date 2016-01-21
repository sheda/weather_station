s = require "servo"
g = require "globals"
q = require "cmqtt"
local serv_pwm = {storm=112,--p78.5
                  snow=101, --p56
                  rain=90,  --p33.5
                  wind=79,  --p11
                  cloud=68, --11
                  sun=57,   --m33.5
                  wifi=46,  --m56
                  poke=35}; --m78.5

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

level=0;
function led_glow(top, bot, mode, speedu, speedd)
      if (g.led.pol == 0) and ((mode == 0) or (mode == 1)) then
        level=level+speedu;
      elseif (g.led.pol == 1) and ((mode == 0) or (mode == 2)) then
        level=level-speedd;
      else
        if (mode == 1) then
          g.led.pol=0;
        else
          g.led.pol=1;
        end
      end
      if level >= top then
        if mode == 0 then -- /\/\
          level = top;
          g.led.pol=1;
        elseif mode == 1 then --/|/|
          level = bot;
          g.led.pol=0;
        end
      elseif level <= bot then
        if mode == 0 then -- /\/\
          g.led.pol=0;
          level = bot;
        elseif mode == 2 then --|\|\
          level = bot;
          g.led.pol=0;
        end
      end
      --print(level)
      pwm.setduty(g.led.pin, level);
end

function led_blink(freq)
      if g.led.index%freq == 0 then
        g.led.pol=1;
        pwm.setduty(g.led.pin, 1023);
      else
        g.led.pol=0;
        pwm.setduty(g.led.pin, 0);
      end
end

function led_flash(pos1, pos2, pos3, pos4, pos5, pos6)
      if ((g.led.index == pos1) or (g.led.index == pos2) or
          (g.led.index == pos3) or (g.led.index == pos4) or
          (g.led.index == pos5) or (g.led.index == pos6)) then
        pwm.setduty(g.led.pin, 1023);
      else
        pwm.setduty(g.led.pin, 0);
      end
end

function led_server ()
    if (g.led.mode == 1) then
      --print("led_storm");
      led_flash(0, 2, 20, 22, 24, 70);
    elseif (g.led.mode == 2) then
      --print("led_snow");
      led_flash(0, 16, 33, 51, 66, 81);
    elseif (g.led.mode == 3) then
      --print("led_rain");
      led_blink(1);
    elseif (g.led.mode == 4) then
      --print("led_wind");
      led_glow(1023,0,1,25,25);
    elseif (g.led.mode == 5) then
      --print("led_cloud");
      led_glow(1023,980,0,25,25);
    elseif (g.led.mode == 6) then
      --print("led_sun");
      led_glow(1023,0,0,25,25);
    elseif (g.led.mode == 7) then
      --print("led_coquin");
      led_blink(2);
    end
    g.led.index = g.led.index +1;
    if (g.led.index >= 100) then
      g.led.index = 0;
    end
end

-- yahoo codes -- available at https://developer.yahoo.com/weather/documentation.html
-- Servo driver from 1% to 10% theorically(T=20ms, pwm from 1000us-2000us)
-- In pratic use abaque for PWM value according to angles
-- +90=30, +67.5=41, +45=52, +22.5=63,0=74,-22.5=85,-45=96,-67.5=107,-90=121
function toServoRange(code)
    local storm = {"0","1","2","3","4","19","37","38","39","40","41","42","43","45","46","47"};
    local snow  = {"5","6","7","8","9","10","13","14","15","16","18"};
    local rain  = {"11","12","17","35"};
    local wind   = {"20","21","22","23","24","25"};
    local cloud = {"26","27","28","29","30","44"};
    local sun  = {"31","32","33","34","36"};

    if check(code, storm) then
      print("storm");
      g.led.mode=1;
      g.servo.value = serv_pwm["storm"];
    elseif check(code, snow) then
      print("snow");
      g.led.mode=2;
      g.servo.value = serv_pwm["snow"];
    elseif check(code, rain) then
      print("rain");
      g.led.mode=3;
      g.servo.value = serv_pwm["rain"];
    elseif check(code, wind) then
      print("wind");
      g.led.mode=4;
      g.servo.value = serv_pwm["wind"];
    elseif check(code, cloud) then
      print("cloud");
      g.led.mode=5;
      g.servo.value = serv_pwm["cloud"];
    elseif check(code, sun) then
      print("sun");
      g.led.mode=6;
      g.servo.value = serv_pwm["sun"];
    else
      print("wifi");
      g.led.mode=7;
      g.servo.value = serv_pwm["wifi"];
    end
    -- Handle WTF mode
    if (g.poscnt.value <= 0) then
      pwm.setduty(g.servo.pin, g.servo.value);
    else
      g.poscnt.value = g.poscnt.value - 1;
    end
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

function main()
  -- mqtt
  q.init();

  -- routine for weather
  getWeather();
  tmr.alarm(2, 60*1000, 1, getWeather ) -- 5*60*1000 = every 5 minutes

  -- routine for led
  pwm.setup(g.led.pin, 50, 512); -- 50hz - 50%(range 0-1023)
  pwm.start(g.led.pin);
  tmr.alarm(1, 300, 1, led_server ) -- 500 = every 500 ms
end

-- Set Pin2 to output(led user)
gpio.mode(g.servo.pin,gpio.OUTPUT);

-- Get servo positions
serv_pwm["storm"], serv_pwm["snow"], serv_pwm["rain"], serv_pwm["wind"], serv_pwm["cloud"], serv_pwm["sun"], serv_pwm["wifi"], serv_pwm["poke"] = dofile("fs_position.lua").read();
g.poke_position = serv_pwm["poke"];

-- init servo module
s.init();
g.servo.value = serv_pwm["wifi"];
pwm.setduty(g.servo.pin, g.servo.value);

-- Connect Wifi
local SSID, PASS, WOEID = dofile("fs_settings.lua").read();
g.woeid=WOEID;
print("Setting STATION mode");
print("SSID:"..SSID);
print("PASS:"..PASS);
wifi.setmode(wifi.STATION);
wifi.sta.config(SSID,PASS);
wifi.sta.autoconnect(1);
SSID=nil;
PASS=nil;
WOEID=nil;

local led_val=0;
tmr.alarm (1, 800, 1, function ( )
  if (wifi.sta.getip() == nil) then
     if(led_val == 0)then
      gpio.write(g.led.pin, gpio.HIGH);
      led_val=1;
     else
      gpio.write(g.led.pin, gpio.LOW);
      led_val=0;
     end
     print ("Waiting for Wifi connection");
  else
     tmr.stop (1);
     gpio.write(g.led.pin, gpio.LOW);
     main();
     print ("Config done, IP is " .. wifi.sta.getip ( ));
     led_val=nil;
  end
end)
