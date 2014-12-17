types = ['stock', 'bond', 'cash']
names = ['tracey', 'ben', 'matt', 'sarah', 'bob', 'jen', 'alice', 'alfred', 'charlie', 'kate']

File.open 'data.csv', 'w' do |f|
  f.puts 'sec_type,price,multiplier,amount,portfolio_owner'
  10.times do 
    f.puts "#{types.sample},#{rand(100)/10.0},#{rand(100)/10.0},#{rand(100)},#{names.sample}"
  end
end
