globals = require "globals"
--[[tmr.alarm(0,20,1,function() -- 50Hz 
    if globals.servo.value then
        gpio.write(globals.servo.pin, gpio.HIGH)
        tmr.delay(globals.servo.value)
        gpio.write(globals.servo.pin, gpio.LOW)
    end
end)--]]
local s = {}
function s.init()
  pwm.setup(globals.servo.pin, 50, 512); -- 50hz - 50%(range 0-1023)
  pwm.start(globals.servo.pin);
end
return s