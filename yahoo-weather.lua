local httpClient = require "http-client"
local g = require "globals"

local url = "http://query.yahooapis.com/v1/public/yql?q=";
      url = url.."select%20item.condition%20from%20weather.forecast%20where%20woeid%3D"..g.woeid;
      url = url.."%20and%20u%3D%27c%27&format=json";
local y = {}
function y.fetch(callback)
    httpClient.getJson(url, function(json)
        local Temp = json.query.results.channel.item.condition.temp;
        local Code = json.query.results.channel.item.condition.code;
        local Text = json.query.results.channel.item.condition.text;
        json = nil
        print ("Temp"..Temp);
        print ("Code"..Code);
        print ("Text"..Text);
        collectgarbage();
        callback(Temp, Code, Text);
    end)
end
return y
