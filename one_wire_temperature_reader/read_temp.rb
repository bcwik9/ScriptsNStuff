while true
  threads = []
  high = -99999
  low = 99999
  sum = 0
  Dir.glob('/sys/bus/w1/devices/28-*').each do |sensor_folder|
    threads << Thread.new do
      temp_data = File.readlines File.join(sensor_folder, 'w1_slave')
      temperature_c = $1.to_i/1000.0 if temp_data.last =~ /t=(\d+)/
      temperature_f = temperature_c * 9/5 + 32
      low = temperature_f if low > temperature_f
      high = temperature_f if high < temperature_f
      sum += temperature_f
      puts "sensor #{sensor_folder}: #{temperature_f}f"
    end
  end
  threads.each { |t| t.join }
  puts "num_sensors: #{threads.size}, low: #{low}f, high: #{high}f, avg: #{sum/threads.size.to_f}, diff: #{high-low}f"
end
