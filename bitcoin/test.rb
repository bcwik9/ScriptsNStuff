require 'btc_exchange'

# Hash of exchanges mapping the exchange name to the URL used for getting JSON ticker info
exchanges = [BtcChinaExchange.new, BitstampExchange.new, MtGoxExchange.new]

# Go through each exchange and record their values to the corresponding Marshal file
marshal_loc = '/home/fonix/data/est/prod/misc/'
exchanges.each do |exchange|
  puts "Getting values for #{exchange.class} using #{exchange.json_url}..."
  now = Time.now
  exchange.update_values
  marshal_file = File.join marshal_loc, "#{exchange.class}_history.dat"
  # values_hash maps the timestamp the values were retrieved to the values themselves
  values_hash = File.open(marshal_file) { |f| Marshal.load f }
  values_hash[now] = exchange.to_hash
  # save the values_hash via Marshal
  File.open(marshal_file, 'w') do |f| Marshal.dump(values_hash, f) end
  puts "Finished updating values for #{exchange.class}: #{exchange.to_s}"
end
