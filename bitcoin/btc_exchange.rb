###
# These ruby classes represent various Bitcoin exchanges and are used to fetch values
###

require 'rubygems'
require 'json'
require 'net/https'

###
# Generic bitcoin exchange class
###
class BtcExchange
  attr_accessor :json_url, :last, :vol, :high, :low, :buy, :sell, :currency

  def initialize url
    @json_url = url
    # Default values for currency are USD
    # If the values we are retrieving aren't USD,
    # change @currency and record the exchange rate used
    @currency = 'USD'
    @rate = 1.0
  end
  
  # Returns the exchange rate for the provided currencies
  def self.get_exchange_rate from_currency, to_currency
    url = "http://rate-exchange.appspot.com/currency?from=#{from_currency}&to=#{to_currency}"
    uri = URI.parse url
    http = Net::HTTP.new uri.host, uri.port
    
    # set up request
    request = Net::HTTP::Get.new uri.request_uri
    
    # get response, convert to hash
    response = http.request request
    response_hash = JSON.parse response.body
    rate = response_hash['rate'].to_f
  end

  # Runs a HTTPS request and returns the response body as a hash if it's a json
  def run_json_http_request
    uri = URI.parse @json_url
    http = Net::HTTP.new uri.host, uri.port
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  
    # set up request
    request = Net::HTTP::Get.new uri.request_uri
    
    # get response, convert to hash
    response = http.request request
    response_hash = JSON.parse response.body
  end

  # Returns last, vol, high, low, buy, and sell as a hash
  def to_hash
    h = {
      :last => @last,
      :vol => @vol,
      :high => @high,
      :low => @low,
      :buy => @buy,
      :sell => @sell,
      :currency => @currency,
      :rate => @rate
    }
  end

  # To string
  def to_s
    out = ''
    out += "Last: #{@last}, "
    out += "Volume: #{@vol}, "
    out += "High: #{@high}, "
    out += "Low: #{@low}, "
    out += "Buy: #{@buy}, "
    out += "Sell: #{@sell}, "
    out += "Currency: #{@currency}, "
    out += "Exchange rate: #{@rate}"
    return out
  end

end

###
# MtGox exchange class
###
class MtGoxExchange < BtcExchange
  
  def initialize url='https://mtgox.com/api/1/BTCUSD/ticker'
    super url
  end
  
  # Updates the last,vol,high,low,buy, and sell for a given exchange
  def update_values
    response_hash = run_json_http_request
    
    # check to make sure we're using the correct currency
    currency = response_hash['return']['last']['currency']
    if @currency != currency
      @currency = currency
      @rate = BtcExchange.get_exchange_rate @currency, 'USD'
    end
    
    # set the values
    @last = response_hash['return']['last']['value'].to_f * @rate
    @vol = response_hash['return']['vol']['value'].to_f
    @high = response_hash['return']['high']['value'].to_f * @rate
    @low = response_hash['return']['low']['value'].to_f * @rate
    @buy = response_hash['return']['buy']['value'].to_f * @rate
    @sell = response_hash['return']['sell']['value'].to_f * @rate
  end

end

###
# BTC China exchange class
###
class BtcChinaExchange < BtcExchange
  
  def initialize url='https://data.btcchina.com/data/ticker'
    super url
  end

  # Updates the last,vol,high,low,buy, and sell for a given exchange
  def update_values
    response_hash = run_json_http_request
    @currency = 'CNY'
    @rate = BtcExchange.get_exchange_rate @currency, 'USD'
    @last = response_hash['ticker']['last'].to_f * @rate
    @vol = response_hash['ticker']['vol'].to_f
    @high = response_hash['ticker']['high'].to_f * @rate
    @low = response_hash['ticker']['low'].to_f * @rate
    @buy = response_hash['ticker']['buy'].to_f * @rate
    @sell = response_hash['ticker']['sell'].to_f * @rate
  end

end

###
# Bitstamp exchange class
###
class BitstampExchange < BtcExchange
  
  def initialize url='https://www.bitstamp.net/api/ticker/'
    super url
  end
  
  # Updates the last,vol,high,low,buy, and sell for a given exchange
  def update_values
    response_hash = run_json_http_request
    @last = response_hash['last'].to_f * @rate
    @vol = response_hash['volume'].to_f
    @high = response_hash['high'].to_f * @rate
    @low = response_hash['low'].to_f * @rate
    @buy = response_hash['bid'].to_f * @rate
    @sell = response_hash['ask'].to_f * @rate
  end

end
