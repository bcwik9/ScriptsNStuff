var wifi_name = 'WIFI SSID NAME';
var wifi_password = 'WIFI PASSWORD';
var hostname = 'EspTemperature';

// send data to io.adafruit.com platform
var adafruit_api_key = 'IO.ADAFRUIT.COM API KEY';
var adafruit_username = 'IO.ADAFRUIT.COM USERNAME';
var adafruit_feed = 'IO.ADAFRUIT.COM FEED';

var http = require('http');
var high, low, sum, sensors;

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

function pollTemps(){
  resetData();
  sensors.forEach(function(sensor, index) {
    processTemp(sensor.getTemp());
  });
}

function setupSensors(){
  var ow = new OneWire(13); // 13 is GPIO Pin number
  sensors = ow.search().map(function (device) {
    return require("DS18B20").connect(ow, device);
  });
  if (sensors.length === 0) print("No OneWire devices found");
  setInterval(pollTemps, 5000);
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
  var payload = JSON.stringify({
    value: (sum/sensors.length)
  });
  var path = '/api/v2/' + adafruit_username + '/feeds/' + adafruit_feed + '/data';
  var opts = {
    host: 'io.adafruit.com',
    path: path,
    method: 'POST',
    protocol: 'https:',
    headers: {
      'X-AIO-KEY': adafruit_io_api_key,
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

function resetData(){
  high = -99999;
  low = 99999;
  sum = 0;
}

function runServer() {
  http.createServer(function(req, res) {
    res.writeHead(200, {'Content-Type': 'application/json'});
    res.end(JSON.stringify({
      num_sensors: sensors.length,
      low: low,
      high: high,
      avg: (sum/sensors.length),
      diff: (high-low)
    }));
  }).listen(3000);
}

save(); // make sure everything loads on restart
