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

function runServer() {
  var http = require('http');
  http.createServer(function(req, res) {
    res.writeHead(200);
    if (status === '/on') digitalWrite(16,false);
    if (status === '/off') digitalWrite(16,true);
    res.end();
}).listen(3000);
}

save(); // make sure everything loads on restart
