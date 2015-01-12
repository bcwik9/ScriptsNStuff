require 'rubygems'
require 'json'
require 'net/https'

def get_exchange_rate from_currency='CNY', to_currency='USD'
 #raise 'IMPLEMENT EXCHANGE RATE: http://www.reddit.com/r/Bitcoin/comments/1rn82s/tickerpy_bitstampbtcchinabtcecoinjarmtgox_usd/'
  #url = "https://finance.yahoo.com/d/quotes.csv?f=sl1&s=#{from_currency}#{to_currency}=X"
  url = "http://rate-exchange.appspot.com/currency?from=#{from_currency}&to=#{to_currency}"
  uri = URI.parse url
  http = Net::HTTP.new uri.host, uri.port
  #http.use_ssl = true
  #http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  
  # set up request
  request = Net::HTTP::Get.new uri.request_uri
  
  # get response, convert to hash
  response = http.request request
  response_hash = JSON.parse response.body
  rate = response_hash['rate'].to_f
end

# set up https
uri = URI.parse 'https://data.btcchina.com/data/ticker'
http = Net::HTTP.new uri.host, uri.port
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

# set up request
request = Net::HTTP::Get.new uri.request_uri

# get response, convert to hash
response = http.request request
response_hash = JSON.parse response.body

# parse data
exchange_rate = get_exchange_rate
puts response_hash['ticker']['last'].to_f * exchange_rate
puts response_hash['ticker']['vol']
puts response_hash['ticker']['high'].to_f * exchange_rate
puts response_hash['ticker']['low'].to_f * exchange_rate
puts response_hash['ticker']['buy'].to_f * exchange_rate
puts response_hash['ticker']['sell'].to_f * exchange_rate
