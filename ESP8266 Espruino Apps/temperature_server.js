E.on('init', function() {
  var WIFI_NAME = 'WIFI SSID NAME';
  var WIFI_OPTIONS = { password: 'WIFI PASSWORD' };

  var wifi = require('Wifi');
  wifi.setHostname("EspTemperature");
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
      runServer();
    }
  );
});

var high, low, sum, sensors;

function pollTemps(){
  sensors.forEach(function(sensor, index) {
    sensor.getTemp();
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

function resetData(){
  high = -99999;
  low = 99999;
  sum = 0;
}

function runServer() {
  var http = require('http');
  http.createServer(function(req, res) {
    res.writeHead(200, {'Content-Type': 'application/json'});
    resetData();
    sensors.forEach(function(sensor, index) {
      processTemp(sensor.getTemp());
    });
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
