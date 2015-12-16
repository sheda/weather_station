local M
do
--Tries to retrieve locals from the file system.
local read_from_fs = function()
    local _STORM="ERR_RDFS"
    local _SNOW="ERR_RDFS"
    local _RAIN="ERR_RDFS"
    local _WIND="ERR_RDFS"
    local _CLOUD="ERR_RDFS"
    local _SUN="ERR_RDFS"
    local _WIFI="ERR_RDFS"
    local _POKE="ERR_RDFS"
    if (file.open("pos_settings", "r") == true) then
        line = file.readline();
        while (line ~= nil) do
            setting = settings_split(line);
            if (setting[0] == "STORM") then
                _STORM = setting[1];
                print("Read_STORM=".._STORM);
            elseif (setting[0] == "SNOW") then
                _SNOW = setting[1];
                print("Read_SNOW=".._SNOW);
            elseif (setting[0] == "RAIN") then
                _RAIN = setting[1];
                print("Read_RAIN=".._RAIN);
            elseif (setting[0] == "WIND") then
                _WIND = setting[1];
                print("Read_WIND=".._WIND);
            elseif (setting[0] == "CLOUD") then
                _CLOUD = setting[1];
                print("Read_CLOUD=".._CLOUD);
            elseif (setting[0] == "SUN") then
                _SUN = setting[1];
                print("Read_SUN=".._SUN);
            elseif (setting[0] == "WIFI") then
                _WIFI = setting[1];
                print("Read_WIFI=".._WIFI);
            elseif (setting[0] == "POKE") then
                _POKE = setting[1];
                print("Read_POKE=".._POKE);
            else
                print("Unknown settings key.");
            end
            line = file.readline();
        end
    else
     print("No file 'pos_settings'");
    end
   return _STORM, _SNOW, _RAIN, _WIND, _CLOUD, _SUN, _WIFI, _POKE
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
local write_to_fs = function(_STORM, _SNOW, _RAIN, _WIND, _CLOUD, _SUN, _WIFI, _POKE)
    file.open("pos_settings", "w+");
    if((_STORM ~= nil) and (_SNOW ~= nil) and (_RAIN ~= nil) and (_WIND ~= nil) and (_CLOUD ~= nil) and (_SUN ~= nil) and (_WIFI ~= nil) and (_POKE ~= nil) ) then
     print("Write_STORM=".._STORM);
     print("Write_SNOW=".._SNOW);
     print("Write_RAIN=".._RAIN);
     print("Write_STORM=".._WIND);
     print("Write_SNOW=".._CLOUD);
     print("Write_RAIN=".._SUN);
     print("Write_STORM=".._WIFI);
     print("Write_SNOW=".._POKE);  
     file.writeline("STORM=".._STORM);
     file.writeline("SNOW=".._SNOW);
     file.writeline("RAIN=".._RAIN);
     file.writeline("WIND=".._WIND);
     file.writeline("CLOUD=".._CLOUD);
     file.writeline("SUN=".._SUN);
     file.writeline("WIFI=".._WIFI);
     file.writeline("POKE=".._POKE);
     print("Write_done");
    else
     file.writeline("STORM=74");
     file.writeline("SNOW=74");
     file.writeline("RAIN=74");
     file.writeline("WIND=74");
     file.writeline("CLOUD=74");
     file.writeline("SUN=74");
     file.writeline("WIFI=74");
     file.writeline("POKE=74");
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
