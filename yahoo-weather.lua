local httpClient = require "http-client"
local globals = require "globals"

--local url = "https://query.yahooapis.com/v1/public/yql?format=json&q="
--    .."select%20atmosphere.humidity%2Citem.condition.temp%2C%20item.condition.text"
--    .."%20from%20weather.forecast%20where%20woeid="..config.woeid

local url = "https://query.yahooapis.com/v1/public/yql?q="
    .."select%20item.condition%20from%20weather.forecast%20where%20woeid%"..globals.woeid
    .."%20and%20u%3D'c'&format=json"

local y = {}

function y.fetch(callback)
    httpClient.getJson(url, function(json) 
        local Temp = json.query.results.channel.item.condition.temp
        local Code = json.query.results.channel.item.condition.code
        local Text = json.query.results.channel.item.condition.text
        json = nil
        collectgarbage()
        callback(Temp, Code, Text)
    end)
end

return y
