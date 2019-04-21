## 1-wire DS18B20 Temperature sensor module reader
This is a simple ruby script that outputs the temperatures of 1-wire DS18B20 temperature sensors. Tested using Raspberry Pi 3 and [CHIP](http://www.getchip.com). It outputs each sensors temperature in farenheit, and also tracks the average, min, max, and temperature difference (if there are multiple sensors).

You might have to run a command to set up one wire before the devices show up.

### Raspberry Pi 3 Setup
- Connect wires to 3.3v, GROUND, and data pin (pin 4, physical pin 7. See [this](http://pinout.xyz/pinout/pin7_gpio4)).
- Run the script

### CHIP Setup
- Connect wires to 3.3v, GROUND, and LCD-D2 for data (see [this](https://docs.getchip.com/chip.html#gpio)). Make sure you have latest firmware (`sudo apt update` and `sudo apt upgrade`)
- Run the script

### Onion Omega2
- Connect wires to 3.3v, GROUND, and GPIO data pin.
- [Run command](https://onion.io/2bt-reading-temperature-from-a-1-wire-sensor/) `insmod w1-gpio-custom bus0=0,<YOUR GPIO PIN NUMBER HERE>,0` to enable one wire devices
  - ex. if I have the data wire plugged in to GPIO 18, my command would look like `insmod w1-gpio-custom bus0=0,18,0`
- Run the script

### Tutorial
[Tutorial](https://learn.adafruit.com/adafruits-raspberry-pi-lesson-11-ds18b20-temperature-sensing/hardware)

### Wire Diagram for 
[Wire Diagram Link](https://learn.adafruit.com/assets/3782)
