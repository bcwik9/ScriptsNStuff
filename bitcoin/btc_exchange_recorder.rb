###
# This script grabs the last, volume, buy, sell, high, and low values from Bitcoin exchanges
###

require 'btc_exchange'
require 'fileutils'
require 'timeout'

# Hash of exchanges mapping the exchange name to the URL used for getting JSON ticker info
exchanges = [BitstampExchange.new, BtcChinaExchange.new]

# Go through each exchange and record their values to the corresponding Marshal file
marshal_loc = '/home/fonix/data/est/prod/misc/'
exchanges.each do |exchange|
  Timeout.timeout(5*60) do # 5 minute timeout
    puts "Getting values for #{exchange.class} using #{exchange.json_url}..."
    now = Time.now
    exchange.update_values rescue next
    marshal_file = File.join marshal_loc, "#{exchange.class}_history.dat"
    if File.exists? marshal_file
      # values_hash maps the timestamp the values were retrieved to the values themselves
      values_hash = File.open(marshal_file) { |f| Marshal.load f }
    else
      # if exchange marshal file doesnt exist, create new blank hash
      puts "**WARNING** #{marshal_file} did not exist, creating new value hash!"
      values_hash = {}
    end
    values_hash[now] = exchange.to_hash
    # save the values_hash via Marshal
    File.open(marshal_file, 'w') do |f| Marshal.dump(values_hash, f) end
    puts "Finished updating values for #{exchange.class}: #{exchange.to_s}"
    # copy marshal file so we have a backup
    FileUtils.cp marshal_file, "#{marshal_file}_bkup"
  end
end
