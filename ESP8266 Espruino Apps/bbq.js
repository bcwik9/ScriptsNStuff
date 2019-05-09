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

function getCurrentTemp(){
  reset_pwm(); // ensure pwm is stopped or temp reading will be off due to voltage fluctuation
  var reading = analogRead(A0); // between 0 and 1
  var known_resistor = 10000; // ohms
  var ohms = known_resistor*reading/(1-reading);
  // steinhart equation
  var stein_a = 0.005304267469;
  var stein_b = -0.0003267544608;
  var stein_c = 0.0000004967505701;
  var log_r = Math.log(ohms);
  var kelvin = 1 / (stein_a + stein_b*log_r + stein_c * Math.pow(log_r, 3));
  var celcius = kelvin - 273.15;
  var farenheit = celcius * 9 / 5 + 32;
  console.log(farenheit);
  return farenheit;
}

var servo_frequency = 333; // Hertz
var servo_interval;
function reset_pwm(){
  if ((typeof servo_interval) !== "undefined") {
    clearInterval(servo_interval);
    NodeMCU.D1.reset();
  }
}

function pwm(duty) {
  console.log(duty);
  servo_interval = setInterval(function() {
    digitalPulse(NodeMCU.D1, 1, duty * (1000/servo_frequency));
  }, 1000/servo_frequency);
  setTimeout(reset_pwm, 1000); // stop pwm, it's process/voltage intensive
}

var desired_temp = 225;
function setDamperPosition(){
  var current_temp = getCurrentTemp();
  var full_open_offset_temp = -25;
  var full_open_until = desired_temp + full_open_offset_temp; // temp at which we start closing the damper
  var full_close_offset_temp = 2;
  var full_close_at = desired_temp + full_close_offset_temp; // temp at which we completely close the damper
  var partial_open_temp_range = full_close_at - full_open_until;
  var full_close_duty = 0.3; // duty where the damper is completely closed
  var full_open_duty = 0.7; // duty where the damper is completely open
  if(current_temp < full_open_until){
    // below target temp, completely open
    pwm(full_open_duty);
  } else if(current_temp > full_close_at){
    // above target temp, completely closed
    pwm(full_close_duty);
  } else {
    // partially open
    var duty_range = full_open_duty - full_close_duty;
    var duty_percentage = (full_close_at - current_temp) / partial_open_temp_range;
    var partial_duty = full_close_duty + (duty_range * duty_percentage);
    pwm(partial_duty);
  }
}
save();