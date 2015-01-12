require 'btc_exchange'

# create a list of exchange hash data
marshal_loc = '/home/fonix/data/est/prod/misc/'
exchange_names = ['MtGox', 'BTC China', 'Bitstamp']
exchange_hashes = [
         File.open("#{marshal_loc}MtGoxExchange_history.dat") { |f| Marshal.load(f) },
         File.open("#{marshal_loc}BtcChinaExchange_history.dat") { |f| Marshal.load(f) },
         
         File.open("#{marshal_loc}BitstampExchange_history.dat") { |f| Marshal.load(f) }
        ]
raise 'Invalid number of exchange names or exchange hashes specified' if exchange_names.size != exchange_hashes.size

# iterate through each exchange hash
# time of data fetch mapped to the values
all_data = {}
exchange_hashes.each_with_index do |exchange_hash,i|
  exchange_hash.each do |k,v|
    v[:exchange] = exchange_names[i]
    all_data[k.to_f] = v
    puts k.to_f
    puts v
  end
end
File.open('bitcoin.json', 'w') do |f| f.puts all_data.to_json end

# generate HTML chart
stats = [:last, :vol, :high, :low, :buy, :sell]
stats.each do |stat|
  html_template_file_contents = File.open('test.html') { |html| html.readlines }
  chart_file = File.open "/home/user/bcwik/public_html/#{stat}_bitcoin_exchange_chart.html", 'w' do |chart_file|
    html_template_file_contents.each do |line|
      case line
      when /var data/i
        chart_file.puts line
        chart_file.puts "[\"Timestamp\",#{exchange_names.inspect.sub /\[/, ''},"
        last_values = {}
        last_timestamp = 0
        all_data.keys.sort.each do |k|
          last_values[all_data[k][:exchange]] = all_data[k][stat]
          next if last_values.keys.size != exchange_names.size
          next if last_timestamp == k.to_i
          last_timestamp = k.to_i
          datarow = "[\"#{Time.at(k)}\","
          exchange_names.each do |exchange_name|
            datarow += "#{last_values[exchange_name]},"
          end
          datarow += '],'
          chart_file.puts datarow
        end
      when /title/i
        title_line = line.gsub /bitcoin exchange/i, "#{stat} values by Bitcoin Exchange"
        chart_file.puts title_line
      else
        chart_file.puts line
      end
    end
  end
end
