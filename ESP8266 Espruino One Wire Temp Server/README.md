### ESP8266 Espruino One Wire Temp Server
This is a lightweight server that reads one wire temperature sensors (specifically a DS18B20 sensor).

#### Setup
[Tutorial found here](https://cuneyt.aliustaoglu.biz/en/programming-esp8266-using-javascript-with-espruino/)
- Flash your ESP8266 with [Espruino firmware](https://www.espruino.com/Download)
  - I downloaded the "combined" file: `espruino_2v01_esp8266_4mb_combined_4096.bin`
  - Run command to flash on linux (I flashed using a raspberry pi):
    ```
    esptool.py --port /dev/ttyUSB0 erase_flash
    esptool.py --port /dev/ttyUSB0 --baud 115200 write_flash --flash_size=detect -fm dio 0 espruino_2v01_esp8266_4mb_combined_4096.bin
    ```
      - Note: Your device could be on something other than `/dev/ttyUSB0` depending on if you have other things plugged in, etc.
      - Note: You can use a higher baud rate (230400, 460800, etc) and the flash will be faster, but all devices don't support high baud rates.
- You should now be able to connect to the ESP8266 by running: `screen /dev/ttyUSB0 115200`
- Copy and paste the contents of the server.js file to the ESP8266 terminal
  - First be sure to replace your Wifi credentials in the file!
- A server should be running. Get the IP of the ESP8266 (look at your router's DHCP client list), and navigate to that in a web browser in port 3000 (or whatever you set it to). It should look something like `192.168.0.100:3000`. A page should load with temperatures!
- (Optional) Run this command to set the name of your device to something recognizable in your router list and to other devices:
```
var wifi = require('Wifi');
wifi.setHostname("MyDeviceName");
```
