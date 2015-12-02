--init.lua, 3 second delay before running file
pin1=3
gpio.mode(pin1,gpio.OUTPUT)

pin2=4
gpio.mode(pin2,gpio.INPUT)

countdown = 3
tmr.alarm(0,1000,1,function()
    print(countdown)
    countdown = countdown-1
    if countdown<1 then
        tmr.stop(0)
        countdown = nil
        local s,err
        if (gpio.read(pin2) == gpio.HIGH) then
          s,err = pcall(function() dofile("settings_server.lua") end);
        else
          s,err = pcall(function() dofile("weatherStation.lua") end);
        end
        if not s then print(err) end
    end
end)
