# This script runs through a list of websites and attempts to scrape emails off those sites. Typically used in conjunction with Parsehub.

require 'spidr'
require 'json'
require 'timeout'

files = Dir.glob("*.json") # typically this is a result from Parsehub
type = :yelp # change this depending on website parsehub template we're processing
delay_between_pages = 1
max_time_per_company = 30 # seconds

template_mappings = {
  default: {
    lead_name: 'companies',
    url_name: 'website'
  },
  yelp: {
    lead_name: 'companies',
    url_name: 'website_url'
  },
  bizbash: {
    lead_name: 'leads',
    url_name: 'url'
  }
}

files.each do |file|
  puts "Processing file #{file}"
  json_data = File.readlines(file).join ''
  companies = JSON.parse(json_data)[template_mappings[type][:lead_name]]

  companies.each do |company|
    website_url = company[template_mappings[type][:url_name]]
    next if website_url.nil?
    if(type == :yelp)
      # yelp escapes/encodes its URLs
      website_url = URI.unescape($1) if website_url =~ /url=(http.+)&website_link/
    end
    uri = URI(website_url)
    uri = URI('http://' + website_url) if uri.scheme.nil? # must have http://

    begin
      Timeout::timeout(max_time_per_company) do
        Spidr.site(uri) do |spider|
          spider.every_html_page do |page|
            sleep delay_between_pages
            
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
      puts "#{uri} timed out after #{max_time_per_company} seconds"
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
end
