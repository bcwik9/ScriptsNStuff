require 'spidr'
require 'json'
require 'timeout'

max_time_per_company = 30 # seconds
file = 'weddingwire_boston.json' # typically this is a result from Parsehub
json_data = File.readlines(file).join ''
companies = JSON.parse(json_data)['companies'] #['company']

companies.each do |company|
  website_url = company['website']
  next if website_url.nil?

  begin
    Timeout::timeout(max_time_per_company) do
      Spidr.site(website_url) do |spider|
        spider.every_html_page do |page|
          # skip certain pages
          page_url = page.url.to_s
          skip = false
          skip_page_extensions = ['jpg', 'pdf', 'css', 'ico'] # add extensions here to ignore them
          skip_page_extensions.each do |extension|
            skip = true if page_url =~ /\.#{extension}/i
          end
          if skip
            puts "Skipping #{page.url}"
            next
          end
          
          puts "Checking #{page.url}"
          company['scraped_phone_numbers'] ||= []
          company['scraped_emails'] ||= []
          
          phone_number_regex = /\(*(\d{3})\)*\s*-*\.*\s*(\d{3})\s*-*\.*\s*(\d{4})/
          matches = page.body.scan phone_number_regex
          matches.each do |match|
            phone_number = match.join ''
            puts "FOUND PHONE NUMBER: #{phone_number}"
            company['scraped_phone_numbers'].push phone_number unless company['scraped_phone_numbers'].include? phone_number
          end
          
          email_regex = /(([\w+\-](\.[\w+\-])?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+)/i
          matches = page.body.scan email_regex
          matches.each do |match|
            email = match.first.to_s
            puts "FOUND EMAIL: #{email}"
            company['scraped_emails'].push email unless company['scraped_emails'].include? email
          end
        end
      end
    end
  rescue
    puts "#{website_url} timed out after #{max_time_per_company} seconds"
  end
end

# post processing
companies.each do |c|
  c['scraped_phone_numbers'] = c['scraped_phone_numbers'].join ', ' unless c['scraped_phone_numbers'].nil?
  c['scraped_emails'] = c['scraped_emails'].join ', ' unless c['scraped_emails'].nil?
end

File.open "#{file}\.processed", 'w' do |f|
  f.puts companies.to_json
end
