local globals = {
    woeid = "3D576272",    -- Antibes - http://woeid.rosselliot.co.nz/lookup/
    poscnt = {value = 0},  -- If not Zere will keep current position
    led = {value = 0,      -- 0 - 1
           pin = 4},       -- GPIO2
    servo = { value = 512, -- range from 0-1023
              pin = 3}     -- GPIO0
}
return globals
