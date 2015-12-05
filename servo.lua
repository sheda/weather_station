g = require "globals"
-- 50 hz

local s = {}
function s.init()
  --pwm.setup(g.servo.pin, 50, 512); -- 50hz - 50%(range 0-1023)
  --pwm.start(g.servo.pin); 
  tmr.alarm(0,20,1,function()
    if g.servo.value then
        gpio.write(g.servo.pin, gpio.HIGH)
        tmr.delay(g.servo.value)
        gpio.write(g.servo.pin, gpio.LOW)
    end
  end)
end
return s
