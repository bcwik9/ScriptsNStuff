// Automatically control your smoker or BBQ grill

E.on('init', function() {
  var WIFI_NAME = 'WIFI SSID NAME';
  var WIFI_OPTIONS = { password: 'WIFI PASSWORD' };
  var hostname = "EspBBQ";
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
      console.log('Wifi connected to: ' + WIFI_NAME);
      setInterval(setDamperPosition, 5000);
    }
  );
});

var servo_frequency = 333; // Hertz
var servo_interval;
function pwm(duty) {
  if ((typeof interval) !== "undefined") {
    clearInterval(servo_interval);
    NodeMCU.D1.reset();
  }
  servo_interval = setInterval(function() {
    digitalPulse(NodeMCU.D1, 1, duty * (1000/servo_frequency));
  }, 1000/servo_frequency);
}

var current_temp = 75;
var desired_temp = 225;
function setDamperPosition(){
  var temp_diff = current_temp - desired_temp;
  var full_open_til_temp = -25;
  var full_close_at_temp = 2;
  var partial_open_temp_range = Math.abs(full_open_til_temp - full_close_at_temp);
  var full_closed_duty = 0.34;
  var full_open_duty = 0.75;
  if(temp_diff < full_open_til_temp){
    // below target temp, completely open
    pwm(full_open_duty);
  } else if(temp_diff > full_close_at_temp){
    // above target temp, completely closed
    pwm(full_closed_duty);
  } else if(temp_diff < 0){
      // partially open, below target temp
      var duty_range = full_open_duty - full_closed_duty;
      var percentage = temp_diff / full_open_til_temp;
      var partial_duty = full_close_duty + (duty_range * percentage);
      pwm(partial_duty);
  }
}