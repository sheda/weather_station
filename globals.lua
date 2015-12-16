local globals = {
    woeid = "576272",      -- Antibes - http://woeid.rosselliot.co.nz/lookup/
    pos_poke = 35,         -- Poke position
    poscnt = {value = 0},  -- If not Zere will keep current position
    led = {value = 0,      -- 0 - 1
           mode = 0,
           pin = 4},       -- GPIO2
    servo = { value = 74,  -- range from 0-1023
              pin = 3}     -- GPIO0
}
return globals
