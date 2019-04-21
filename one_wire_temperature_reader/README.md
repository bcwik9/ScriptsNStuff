## 1-wire DS18B20 Temperature sensor module reader
This is a simple ruby script that outputs the temperatures of 1-wire DS18B20 temperature sensors. Tested using Raspberry Pi 3 and [CHIP](http://www.getchip.com). It outputs each sensors temperature in farenheit, and also tracks the average, min, max, and temperature difference (if there are multiple sensors).

You might have to run a command to set up one wire before the devices show up.

### Raspberry Pi 3 Setup
Connect wires to 3.3v, GROUND, and data pin (pin 4, physical pin 7. See [this](http://pinout.xyz/pinout/pin7_gpio4)).

### CHIP Setup
Connect wires to 3.3v, GROUND, and LCD-D2 for data (see [this](https://docs.getchip.com/chip.html#gpio)). Make sure you have latest firmware (`sudo apt update` and `sudo apt upgrade`)

### Tutorial
[Tutorial](https://learn.adafruit.com/adafruits-raspberry-pi-lesson-11-ds18b20-temperature-sensing/hardware)

### Wire Diagram for 
[Wire Diagram Link](https://learn.adafruit.com/assets/3782)
