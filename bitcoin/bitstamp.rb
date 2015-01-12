require 'rubygems'
require 'json'
require 'net/https'

# set up https
uri = URI.parse 'https://www.bitstamp.net/api/ticker/'
http = Net::HTTP.new uri.host, uri.port
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

# set up request
request = Net::HTTP::Get.new uri.request_uri

# get response, convert to hash
response = http.request request
response_hash = JSON.parse response.body

# parse data
puts response_hash['last']
puts response_hash['volume']
puts response_hash['high']
puts response_hash['low']
puts response_hash['bid']
puts response_hash['ask']
