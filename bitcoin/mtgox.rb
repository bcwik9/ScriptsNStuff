require 'rubygems'
require 'json'
require 'net/https'

# set up https
uri = URI.parse 'https://mtgox.com/api/1/BTCUSD/ticker'
http = Net::HTTP.new uri.host, uri.port
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

# set up request
request = Net::HTTP::Get.new uri.request_uri

# get response, convert to hash
response = http.request request
response_hash = JSON.parse response.body

# parse data
puts response_hash['return']['last']['value']
puts response_hash['return']['vol']['value']
puts response_hash['return']['high']['value']
puts response_hash['return']['low']['value']
puts response_hash['return']['buy']['value']
puts response_hash['return']['sell']['value']
