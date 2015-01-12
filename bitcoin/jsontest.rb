require 'rubygems'
require 'json'

File.open 'bitcoin.json' do |f|
  s = f.readlines.first
  puts s
  puts JSON.parse(s).keys.size
end
