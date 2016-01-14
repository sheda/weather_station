# Picture Frame - Weather Stations (by Sheda 2016)
This project is covered by Licenc GPL v2.0

This weather station connect to yahoo weather forecast throught wifi connection and display the forecast for a setted city through given WOEID.
The weather forecast is displayed through 6 pictograms (storm, snow, rain, wind, cloud, sun) driven with a servo motor.
This also has got a poke function working through MQTT protocol using a broker.
So this rely on a public third party external service that may experience unexpected outage.

---

1 - Setting Mode:
=================
The setting mode is  entered if switch is on position "SET" before **Switching On** the Weather Station. The wifi icon is shown on the wheel and LED is stand still on.

This will create a wifi hotspot:
 * SSID: "SHEDA_CFG"
 * PSWD: 12345678

Once connected you will get IP "192.168.4.2".

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

4 - More info:
=====================

* [MQTT](https://en.wikipedia.org/wiki/MQTT)
* [YAHOO WEATHER API](https://developer.yahoo.com/weather/)
* [ESP8266](http://wiki.iteadstudio.com/ESP8266_Serial_WIFI_Module)
* [NODE-MCU](https://github.com/nodemcu/nodemcu-firmware)
* [SOURCES](https://github.com/sheda/weather_station)
