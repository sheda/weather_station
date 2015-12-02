local M
do
--Tries to retrieve locals from the file system.
local read_from_fs = function()
    local _SSID="ERR_RDFS"
    local _PASS="ERR_RDFS"
    local _WOEID="ERR_RDFS"
    if (file.open("settings", "r") == true) then
        line = file.readline();
        while (line ~= nil) do
            --print(".");
            setting = settings_split(line);
            if (setting[0] == "SSID") then
                _SSID = setting[1];
                print("Read_SSID=".._SSID);
            elseif (setting[0] == "PASS") then
                _PASS = setting[1];
                print("Read_PASS=".._PASS);
            elseif (setting[0] == "WOEID") then
                _WOEID = setting[1];
                print("Read_WOEID=".._WOEID);
            else
                print("Unknown settings key.");
            end
            line = file.readline();
        end
    else
     print("No file 'settings'");
    end
   return _SSID, _PASS, _WOEID
end

--Splits string with format key=value into key and value.
function settings_split(str)
    local t={} ; local i=0
    for str in string.gmatch(str, "[^=\n]+") do -- TODO remove endofline
        t[i] = str;
        i = i + 1;
    end
    return t
end
--Writes locals to file system
local write_to_fs = function(_SSID, _PASS, _WOEID)
    file.open("settings", "w+");
    if(_SSID ~= nil and _PASS ~= nil and _WOEID ~= nil) then
     print("Write_SSID=".._SSID);
     print("Write_PASS=".._PASS);
     print("Write_WOEID=".._WOEID);
     file.writeline("SSID=".._SSID);
     file.writeline("PASS=".._PASS);
     file.writeline("WOEID=".._WOEID);
     print("Write_done");
    else
     file.writeline("SSID=ERR_WRFS");
     file.writeline("PASS=ERR_WRFS");
     file.writeline("WOEID=ERR_WOEID");
     print("Write_err");
    end
    file.close();
end
  -- expose
  M = {
      read = read_from_fs,
      write = write_to_fs,
  }
end
return M
