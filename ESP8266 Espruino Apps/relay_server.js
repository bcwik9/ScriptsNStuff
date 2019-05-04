var WIFI_NAME = 'WIFI SSID NAME';
var WIFI_OPTIONS = { password: 'WIFI PASSWORD' };

// send data to io.adafruit.com platform
var adafruit_api_key = 'IO.ADAFRUIT.COM API KEY';
var adafruit_username = 'IO.ADAFRUIT.COM USERNAME';
var adafruit_feed = 'IO.ADAFRUIT.COM FEED';

E.on('init', function() {
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
      startMqtt();
    }
  );
});

function runServer() {
  var http = require('http');
  http.createServer(function(req, res) {
    res.writeHead(200);
    var status = req.url.replace('/?', '');
    if(status === '/on'){
      digitalWrite(NodeMCU.D0, false);
      mqttPublish(true);
    } else if (status === '/off'){
      digitalWrite(NodeMCU.D0, true);
      mqttPublish(false);
    }
    res.end();
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
  var feed = adafruit_username + '/feeds/' + adafruit_feed;
  mqtt.publish(adafruit_feed,status);
}

save(); // make sure everything loads on restart
