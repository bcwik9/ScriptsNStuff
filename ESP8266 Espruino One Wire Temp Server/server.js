E.on('init', function() {
  var WIFI_NAME = 'WIFI SSID NAME';
  var WIFI_OPTIONS = { password: 'WIFI PASSWORD' };

  var wifi = require('Wifi');
  wifi.connect(
    WIFI_NAME,
    WIFI_OPTIONS,
    function(err) {
      if (err) {
        console.log('Connection error: ' + err);
        return;
      }
      console.log('Connected!');
      runServer();
    }
  );
});

var high, low, sum, num_readings;

function tempReady(celcius){
  var farenheit = celcius * 9/5 + 32;
  if(low > farenheit){
    low = farenheit;
  }
  if(high < farenheit){
    high = farenheit;
  }
  sum += farenheit;
  num_readings++;
}

function resetData(){
  high = -99999;
  low = 99999;
  sum = 0;
  num_readings = 0;
}

function runServer() {
  var http = require('http');
  http.createServer(function(req, res) {
    res.writeHead(200);
    var status = req.url.replace('/?', '');
    //if (status === 'on') ledStatus(1);
    //if (status === 'off') ledStatus(0);
    
    resetData();
    var ow = new OneWire(13); // 13 is GPIO Pin number
    var sensors = ow.search().map(function (device) {
      return require("DS18B20").connect(ow, device);
    });
    if (sensors.length === 0) print("No OneWire devices found");
    sensors.forEach(function(sensor, index) {
      sensor.getTemp(tempReady);
    });
    var ready_interval = setInterval(function(){
      if(num_readings >= sensors.length){
        clearInterval(ready_interval);
        res.end('Num Sensors: ' + sensors.length + ', Low: ' + low + ', High: ' + high + ', Avg: ' + (sum/sensors.length) + ', Diff: ' + (high-low));
      }
    }, 200);
}).listen(3000);
}

save(); // make sure everything loads on restart
