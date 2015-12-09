g = require "globals"
-- 50 hz

local s = {}
function s.init()
  pwm.setup(g.servo.pin, 50, 512); -- 50hz - 50%(range 0-1023)
  pwm.start(g.servo.pin); 
end
return s
