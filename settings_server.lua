local function unescape(s)
  local rt, i, len = "", 1, #s
  s = s:gsub('+', ' ')
  local j, xx = s:match('()%%(%x%x)', i)
  while j do
    rt = rt .. s:sub(i, j-1) .. string.char(tonumber(xx,16))
    i = j+3
    j, xx = s:match('()%%(%x%x)', i)
  end
 return rt .. s:sub(i)
end

print("Mode Setting Server");
s = require "servo"
g = require "globals"

-- Set Pin2 to output(led user)
gpio.mode(g.servo.pin,gpio.OUTPUT);

-- init servo module
s.init();
local __STORM="";
local __SNOW="";
local __RAIN="";
local __WIND="";
local __CLOUD="";
local __SUN="";
local __WIFI="";
local __POKE="";
__STORM, __SNOW, __RAIN, __WIND, __CLOUD, __SUN, __WIFI, __POKE = dofile("fs_position.lua").read();
g.servo.value = tonumber(__WIFI);
pwm.setduty(g.servo.pin, g.servo.value);
local __STORM=nil;
local __SNOW=nil;
local __RAIN=nil;
local __WIND=nil;
local __CLOUD=nil;
local __SUN=nil;
local __WIFI=nil;
local __POKE=nil;

print("Setting AP mode");
wifi.setmode(wifi.SOFTAP);
local cfg={};
cfg.ssid="SHEDA_CFG";
cfg.pwd="12345678";
wifi.ap.config(cfg);
cfg={};
cfg.ip="192.168.4.1";
cfg.netmask="255.255.255.0";
cfg.gateway="192.168.4.1";
wifi.ap.setip(cfg);

local led_val=0;
while ((wifi.ap.getip() == "0.0.0.0") or (wifi.ap.getip() == nil)) do
   if(led_val == 0)then
    gpio.write(g.servo.pin, gpio.HIGH);
    led_val=1;
   else
    gpio.write(g.servo.pin, gpio.LOW);
    led_val=0;
  end
  print("Not yet connected, waiting...");
  tmr.delay(1000000); -- 1sec
end
cfg=nil
print("Connected. IP: ", wifi.ap.getip())
print(node.heap())

gpio.write(pin2, gpio.HIGH);
led_val=1;

srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
  conn:on("receive",function(client, request)
    print("OnReq");
    local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
    local _GET = {};
    print(node.heap());
    if(vars~=nil)then
      for k, v in string.gmatch(vars, "([^?= ]+)=([^&= ]+)&*") do
        _GET[k] = v;
      end
      if((_GET.ssid ~= nil) and (_GET.pass ~= nil) and (_GET.woeid ~= nil)) then
        print("WEB SSID:".._GET.ssid);
        local ssid_dec = unescape(_GET.ssid);
        print("WEB SSID_DEC:"..ssid_dec);

        print("WEB PASS:".._GET.pass);
        local pass_dec = unescape(_GET.pass);
        print("WEB PASS_DEC:"..pass_dec);

        print("WEB WOEID:".._GET.woeid);
        dofile("fs_settings.lua").write(ssid_dec, pass_dec, _GET.woeid);
      elseif((_GET.storm ~= nil) and (_GET.snow ~= nil) and (_GET.rain ~= nil) and (_GET.wind ~= nil) and (_GET.cloud ~= nil) and (_GET.sun ~= nil) and (_GET.wifi ~= nil) and (_GET.poke ~= nil)) then
        dofile("fs_position.lua").write(tonumber(_GET.storm), tonumber(_GET.snow), tonumber(_GET.rain), tonumber(_GET.wind), tonumber(_GET.cloud), tonumber(_GET.sun), tonumber(_GET.wifi), tonumber(_GET.poke));
      elseif((_GET.position ~= nil)) then
        g.servo.value = tonumber(_GET.position);
        pwm.setduty(g.servo.pin, g.servo.value);
      end
    end
    print(node.heap())

    local SSID="";
    local PASS="";
    local WOEID="";
    SSID, PASS, WOEID = dofile("fs_settings.lua").read();
    local buf = "<h1>SHEDA config</h1>";
    buf = buf..'<form action="t">';
    buf = buf..'<p>SSID <INPUT TYPE="text" NAME="ssid" VALUE='..SSID..' SIZE=10>&nbsp;</p>';
    buf = buf..'<p>PASS <INPUT TYPE="text" NAME="pass" VALUE='..PASS..' SIZE=10>&nbsp;</p>';
    buf = buf..'<p>WOEID <INPUT TYPE="text" NAME="woeid" VALUE='..WOEID..' SIZE=10>&nbsp; (<a href="http://woeid.rosselliot.co.nz">find your woeid here</a>)</p>';
    buf = buf..'<p><input type="submit" value="Submit">&nbsp;</p>';
    buf = buf..'</form>';
    local STORM="";
    local SNOW="";
    local RAIN="";
    local WIND="";
    local CLOUD="";
    local SUN="";
    local WIFI="";
    local POKE="";
    STORM, SNOW, RAIN, WIND, CLOUD, SUN, WIFI, POKE = dofile("fs_position.lua").read();
    buf = buf..'<form action="p">';
    buf = buf..'<p>STORM <INPUT TYPE="text" NAME="storm" VALUE='..STORM..' SIZE=10>&nbsp;</p>';
    buf = buf..'<p>SNOW <INPUT TYPE="text" NAME="snow" VALUE='..SNOW..' SIZE=10>&nbsp;</p>';
    buf = buf..'<p>RAIN <INPUT TYPE="text" NAME="rain" VALUE='..RAIN..' SIZE=10>&nbsp;</p>';
    buf = buf..'<p>WIND <INPUT TYPE="text" NAME="wind" VALUE='..WIND..' SIZE=10>&nbsp;</p>';
    buf = buf..'<p>CLOUD <INPUT TYPE="text" NAME="cloud" VALUE='..CLOUD..' SIZE=10>&nbsp;</p>';
    buf = buf..'<p>SUN <INPUT TYPE="text" NAME="sun" VALUE='..SUN..' SIZE=10>&nbsp;</p>';
    buf = buf..'<p>WIFI <INPUT TYPE="text" NAME="wifi" VALUE='..WIFI..' SIZE=10>&nbsp;</p>';
    buf = buf..'<p>POKE <INPUT TYPE="text" NAME="poke" VALUE='..POKE..' SIZE=10>&nbsp;</p>';
    buf = buf..'<p><input type="submit" value="Submit">&nbsp;</p>';
    buf = buf..'</form>';

    buf = buf..'<form action="a">';
    buf = buf..'<p>POSITION<INPUT TYPE="text" NAME="position" VALUE='..g.servo.value..' SIZE=10>&nbsp;</p>';
    buf = buf..'<p><input type="submit" value="Submit">&nbsp;</p>';
    buf = buf..'</form>';

    client:send(buf);
    client:close();
    buf=nil;
    local SSID=nil;
    local PASS=nil;
    local WOEID=nil;
    local STORM=nil;
    local SNOW=nil;
    local RAIN=nil;
    local WIND=nil;
    local CLOUD=nil;
    local SUN=nil;
    local WIFI=nil;
    local POKE=nil;
    collectgarbage();
  end)
  --conn:on("sent", function(client) client:close() end)
 end)

collectgarbage();
print("Done AP");
