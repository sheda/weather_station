print("Setting AP mode")
wifi.setmode(wifi.SOFTAP)
local cfg={}
cfg.ssid="SHEDA_CFG";
cfg.pwd="12345678"
wifi.ap.config(cfg)
cfg={}
cfg.ip="192.168.4.1";
cfg.netmask="255.255.255.0";
cfg.gateway="192.168.4.1";
wifi.ap.setip(cfg);

while ((wifi.ap.getip() == "0.0.0.0") or (wifi.ap.getip() == nil)) do
  print("Not yet connected, waiting...");
  tmr.delay(1000000); -- 1sec
end
cfg=nil
print("Connected. IP: ", wifi.ap.getip())
print(node.heap())

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
      if( (_GET.ssid ~= nil) and (_GET.pass ~= nil) and (_GET.woeid ~= nil)) then
        print("WEB SSID:".._GET.ssid);
        print("WEB PASS:".._GET.pass);
        print("WEB WOEID:".._GET.woeid);
        dofile("fs_settings.lua").write(_GET.ssid, _GET.pass, _GET.woeid);
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
    buf = buf..'<p>WOEID <INPUT TYPE="text" NAME="woeid" VALUE='..WOEID..' SIZE=10>&nbsp;</p>';
    buf = buf..'<p><input type="submit" value="Submit">&nbsp;</p>';
    buf = buf..'</form>';
    
    client:send(buf);
    client:close();
    local SSID="";
    local PASS="";
    local WOEID="";
    collectgarbage();
  end)
  --conn:on("sent", function(client) client:close() end)
 end)

collectgarbage();
print("Done AP");