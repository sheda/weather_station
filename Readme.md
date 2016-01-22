# Picture Frame - Weather Stations (by Sheda 2016) on ESP8266 NodeMcu
This project is covered by Licence GPL v2.0

This weather station connect to yahoo weather forecast throught wifi connection and display the forecast for a setted city through given WOEID.
The weather forecast is displayed through 6 pictograms (storm, snow, rain, wind, cloud, sun) driven with a servo motor.
This also has got a poke function working through MQTT protocol using a broker.
So this rely on a public third party external service that may experience unexpected outage.

The whole project is running over [NODE-MCU](https://github.com/nodemcu/nodemcu-firmware) with some additionals module see part 4 for more info about requirement.

---

1 - Setting Mode:
=================
The setting mode is  entered if switch is on position "SET" before **Switching On** the Weather Station. The wifi icon is shown on the wheel and LED is stand still on.

This will create a wifi hotspot:
 * SSID: "SHEDA_CFG"
 * PSWD: 12345678

Once connected you will get IP "192.168.4.2"

### Setting instruction:
This server allow you to set SSID, PASSWORD of your internet connection, and the WOEID.
 * Set the switch to "SET" position
 * Plug the power supply
 * On your device connect to WIFI "SHEDA_CFG" with password "12345678"
 * Open a web browser and connect to "http://192.168.4.1"
 * Enter the ssid and password of your __house's wifi__ with internet connection.
 * Go to "http://woeid.rosselliot.co.nz/", to get your WOEID (for Paris woeid is 615702) and copy it in the right field
 * Click Submit
 * Power off the WeatherStation
 * And set the switch to "WEATHER" position

---

2 - Normal WeatherMode:
================

The weather Mode is the main behaviour of the WeatherStation, it use previously setted credential to connect WIFI with internet connection.

### Main behaviour:
It will boot and display wifi icon until wifi connection if ok. Next, it fetches each 3 minutes the yahoo's weather forcast and display the result on the wheel.

### Poke behaviour:
Your friends can poke you on throught using MQTT client. This rely on a broker that may experience unexpected outage. The displayed poke last until the weather is refreshed.

**Client on android:**
* [MyMQTT](https://play.google.com/store/apps/details?id=at.tripwire.mqtt.client&hl=en)

**Settings:**
* Open the App
* Enter the the broker address, port 1883(default)
* Publish on the channel "/sheda/<your_id>/poke" with message payload or not it doesn't matter

---

3 - Electronic Board:
=====================

The pin header on the right of the board (switch is on the left) is separated as follow from top to bottom:

**Servo:**

* 1 : GND  (brown wire)
* 2 : 3.3V (red wire)
* 3 : DATA (yellow wire)

**UART 3v3 (9600N1): /!\ Beware of using TTL uart it may destroy the esp8266, use "voltage divisor bridge" before the pin 4**

* 4: RX (connect TX of your UART adapter)
* 5: TX (connect RX of your uart adapter)
* 6: GND (connect GND of your uart adapter)

**Power Supply(DC 5v-15v max):**

- 7: VCC (connect AC-DC adapter +)
- 8: GND (connect AC-DC adapter -)

**Warnings:**

- **/!\ The AC-DC came with 3pins, the one not connected should be outside the board and NOT connected on pin 6**
- **/!\ The Power regulator may be HOT according to workload should not touch it.**

**Electronic circuit for Picture Frame Weather Forcast by Sheda**
(realised on asciiflow.com)

        3.3V
        +++
         |
         +------+
         |      |
         |     +++                                                    header0
         |     | |2.2Ko                                               +-----+
        B|     | |                                                    |Servo|
         |     +++                                        3.3V    A +----1----> GND(Brown)
      +--+--+ C |                                         +++         |     |
      |     +---+---------X                                |      B +----2----> Pwr(Red)
      | XXX |              1              ESP8266-1        |          |     |
      |X   X|     jumper0 X---+       Connector top View   |      C +----3----> Data(yellow)
      |X +---->            2  |    D   +------+------+     |          |     |
      |X   X|             X   |    +---+ RX   |  3.3 +-----+          +-----+
      | XXX | Servo       +   |        |      |      |     |          |UART |
      +-----+             |   |        +-------------+     |      D <----4----+ TX uart  /!\ If 5v add
         |A               |   +--------+ GPIO0|  NC  |     |          |     |                 divisor bridge
        +-+              +++           |      |      |     |      E +----5----> RX uart
        GND    3.3V      GND           +-------------+     |          |     |
               +++               +-----+ GPIO2|  3.3 +-----+    GND +----6----+ GND uart
                |                |     |      |      |                |     |
                +------+         |     +-------------+  E             +-----+
                |      |         |     | GND  |  TX  +--+             |PWR  |
               +++   + |         |     |      |      |            F <----7----+ Pwr +
          2.2Ko| |   +---+22uf   |     +--+---+------+                |     |
               | |   +---+       |        |                     GND +----8----+ Pwr -
               +++     |         |       +++                          |     |
                |      |         |       GND                          +-----+
                X      |         |
                 1     |         |
       Btn_user X------x---------+                      LM1117V33
                 2     |                            +--------------+
                X    X+++X          5V(15Vmax)     3|              |2
                |     \ / LED            +----+-----+In         Out+-----+----->3.3v
                |      X                F     |     |      GND     |     |
                |    X+++X                    |     +--------------+   + |
                |      |                    +---+100nf      |1         +---+10uf
               +++    +++                   +---+           |          +---+
           10Ko| |    | |100o                 |             |            |
               | |    | |                     |             |            |
               +++    +++                    +++           +++          +++
                |      |                     GND           GND          GND
                |      |
               +++    +++
               GND    GND

---

4 - NodeMcu firmware & Lua Programmation:
=========================

a - Flash NodeMCU firmware

The NodeMCU firware come with a lot of built-in module that are expensive in term of program memory using. To get more space for our luas program files we will get custom build.
We need the following module installed: node,file,gpio,wifi,net,pwm,tmr,mqtt,cjson

Cool feature: Build online NodeMcu firmware:  
[http://nodemcu-build.com/](http://nodemcu-build.com/)

Get the ESP8266 flasher:  
[https://github.com/nodemcu/nodemcu-flasher](https://github.com/nodemcu/nodemcu-flasher)

To Flash the NodeMCU Firmware ESP8266-01:
- Shunt GPIO0 to GND so as to the module became in flash mode (so use position 2 of jumper 0)
- Connect the serial UART wiring (mind that TX UART must be connected to RX ESP8266, and the oposite Rx UART and TX ESP8266)
- PowerOn the Board
- Launch the flasher and select the firmware in the config tab.
- Press Flash
- You should See the MAC of this chip apearing and the progress bar moving

b - Programme LUAs scripts

To programme LUA script inside the chip we will use ESPlorer, this software ease the programmation and debug of LUAs scripts.  
[http://esp8266.ru/esplorer/#download](http://esp8266.ru/esplorer/#download)
>i: But from this point we could completly use a terminal and make execute diretly lua line by directly writing those

To Programme:
- First change your MQTT information in cmqtt.lua file(broker url, userid, password, etc)
- Disconnect GPIO0 from GND! We are not flashing firmware anymore, discussing with the firmware.
- Connect UART
- Power on
- i: You should see header of NodeMcu and fail message looking for init.lua
- From that point send every files .lua and send also "settings" and "pos_settings".
- /!\ if you got error during the flash this may be due to ESP8266 trying to print some character over serial while programming this may create error, juste reboot and continue flashing

---

5 - More info:
=====================

* [MQTT](https://en.wikipedia.org/wiki/MQTT)
* [YAHOO WEATHER API](https://developer.yahoo.com/weather/)
* [ESP8266](http://wiki.iteadstudio.com/ESP8266_Serial_WIFI_Module)
* [NODE-MCU](https://github.com/nodemcu/nodemcu-firmware)
* [SOURCES](https://github.com/sheda/weather_station)
