var wifi_name = 'WIFI SSID NAME';
var wifi_password = 'WIFI PASSWORD';
var hostname = 'EspTemperature';
var onewire_pin = NodeMCU.D7;

// send data to io.adafruit.com platform
var adafruit_api_key = 'IO.ADAFRUIT.COM API KEY';
var adafruit_username = 'IO.ADAFRUIT.COM USERNAME';
var adafruit_feed = 'IO.ADAFRUIT.COM FEED';

var sensors = {};
var high, low, sum;

E.on('init', function() {
  var WIFI_NAME = wifi_name;
  var WIFI_OPTIONS = { password: wifi_password };

  var wifi = require('Wifi');
  wifi.setHostname(hostname);
  wifi.connect(
    WIFI_NAME,
    WIFI_OPTIONS,
    function(err) {
      if (err) {
        console.log('Connection error: ' + err);
        return;
      }
      console.log('Connected!');
      setupSensors();
      setInterval(mqttPublish, 60000);
      runServer();
    }
  );
});

function calcTemps(){
  high = -99999;
  low = 99999;
  sum = 0;
  Object.keys(sensors).forEach(function(sensor_id, index) {
    processTemp(sensors[sensor_id]);
  });
}

function setupSensors(){
  var manager = require("OneWireTempManager").create([NodeMCU.D7]);
  manager.C.POLL_PERIOD = 5000; // refresh temperature every 5 sec
  manager.callBack = function(sensor,temp) {
     sensors[sensor.sCode] = temp;
  };
  manager.start();
}

function processTemp(celcius){
  var farenheit = celcius * 9/5 + 32;
  if(low > farenheit){
    low = farenheit;
  }
  if(high < farenheit){
    high = farenheit;
  }
  sum += farenheit;
}

function runServer() {
  var http = require('http');
  http.createServer(function(req, res) {
    res.writeHead(200, {'Content-Type': 'application/json'});
    calcTemps();
    res.end(JSON.stringify({
      num_sensors: sensors.length,
      low: low,
      high: high,
      avg: (sum/Object.keys(sensors).length),
      diff: (high-low)
    }));
  }).listen(3000);
}

var mqtt;

function startMqtt(){
  mqtt = require("MQTT").connect({
    host: "io.adafruit.com",
    port: 1883,
    protocol_level: 0,
    username: adafruit_username,
    password: adafruit_api_key
  });
}

function mqttPublish(status){
  calcTemps();
  avg_temp = sum / Object.keys(sensors).length;
  var feed = adafruit_username + '/feeds/' + adafruit_feed;
  mqtt.publish(adafruit_feed, avg_temp);
}

save(); // make sure everything loads on restart