var wifi_name = 'WIFI SSID NAME';
var wifi_password = 'WIFI PASSWORD';
var hostname = 'EspTemperature';
var onewire_pin = NodeMCU.D7;

// send data to io.adafruit.com platform
var adafruit_api_key = 'IO.ADAFRUIT.COM API KEY';
var adafruit_username = 'IO.ADAFRUIT.COM USERNAME';
var adafruit_feed = 'IO.ADAFRUIT.COM FEED';

var http = require('http');
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
      setInterval(sendTempToAdafruit, 60000);
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

function sendTempToAdafruit(){
  calcTemps();
  var payload = JSON.stringify({
    value: (sum/Object.keys(sensors).length)
  });
  var path = '/api/v2/' + adafruit_username + '/feeds/' + adafruit_feed + '/data';
  var opts = {
    host: 'io.adafruit.com',
    path: path,
    method: 'POST',
    protocol: 'https:',
    headers: {
      'X-AIO-KEY': adafruit_api_key,
      'Content-Length': payload.length,
      'Content-Type': 'application/json'
    }
  };

  var req = require('http').request(opts, function(res){
    res.on('data', function(data) {
     //console.log("HTTP> "+data);
    });
  });
  req.on('error', function(e) {
    console.log('problem with request: ' + e.message);
  });
  req.end(payload);
}

function runServer() {
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

save(); // make sure everything loads on restart