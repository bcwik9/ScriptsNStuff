# This script runs through a list of websites and attempts to scrape emails off those sites. Typically used in conjunction with Parsehub.

require 'spidr'
require 'json'
require 'timeout'
require 'net/http'

SKIP_PAGES = ['jpg', 'pdf', 'css'] # add extensions here to ignore them

def scrape_emails webpage_source
  email_regex = /(([\w+\-](\.[\w+\-])?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+)/i
  emails = []
  matches = webpage_source.scan email_regex
  matches.each do |match|
    email = match.first.to_s
    puts "FOUND EMAIL: #{email}"
    emails.push email unless emails.include? email
  end
  emails
end

def scrape_phone_numbers webpage_source
  phone_number_regex = /\(*(\d{3})\)*\s*-*\.*\s*(\d{3})\s*-*\.*\s*(\d{4})/
  phone_numbers = []
  matches = webpage_source.scan phone_number_regex
  matches.each do |match|
    phone_number = match.join ''
    #puts "FOUND PHONE NUMBER: #{phone_number}"
    phone_numbers.push phone_number unless phone_numbers.include? phone_number
  end
  phone_numbers
end

def scrape_webpage_links webpage_source, uri
  urls = []
  raw_hrefs = webpage_source.split "href"
  raw_hrefs.each do |raw_href|
    if raw_href =~ /=['"]([^" ]*)['"]/
      new_url = $1.to_s
      if new_url !~ /http/ && !new_url.include?(uri.host)
        new_url = "http://" + ("#{uri.host}/#{new_url}".gsub '//', '/')
      end
      urls << new_url
    end
  end
  urls.uniq
end

def get_webpage_source_for uri
  response = Net::HTTP.get_response uri
  source = response.body
  
  # check for a redirect
  if response.code == "301"
    uri = URI.parse response.header['location']
    source = Net::HTTP.get uri
  end

  # if we still don't have anything, try adding/removing "www"
  if source.empty?
    if uri.to_s =~ /www/i
      uri = URI(uri.to_s.gsub("http://www.", "http://"))
    else
      uri = URI(uri.to_s.gsub("http://", "http://www."))
    end
    source = Net::HTTP.get uri
  end
  source
end

def scrape_site_for_emails uri
  source = get_webpage_source_for uri
  urls = scrape_webpage_links source, uri
  all_emails = []
  all_emails += scrape_emails(source)
  important_urls = ['about', 'contact']
  process_first = urls.select{|website| important_urls.any?{|u| website.include?(u)} }
  urls -= process_first
  (process_first + urls).each do |url|
    begin
      next if SKIP_PAGES.any? {|s| url =~ /#{s}/}
      sleep 1
      uri = URI(url)
      puts "Checking #{uri}"
      all_emails += scrape_emails(get_webpage_source_for(uri))
    rescue
      puts "Skipping bad url: \"#{url}\""
    end
  end
  all_emails.uniq
end


### INIT
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

files.each_with_index do |file, file_index|
  puts "Processing file #{file} (#{file_index+1}/#{files.size})"
  json_data = File.readlines(file).join ''
  companies = JSON.parse(json_data)[template_mappings[type][:lead_name]]

  companies.each_with_index do |company, company_index|
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
            SKIP_PAGES.each do |extension|
              skip = true if page_url =~ /\.#{extension}/i
            end
            if skip
              puts "Skipping #{page.url}"
              next
            end

            puts "File #{file_index+1}/#{files.size} (#{file}). Company #{company_index+1}/#{companies.size}. Checking #{page.url}"
            company['scraped_emails'] ||= []
            company['scraped_phone_numbers'] ||= []

            company['scraped_emails'] = (company['scraped_emails'] + scrape_emails(page.body)).uniq
            company['scraped_phone_numbers'] = (company['scraped_phone_numbers'] + scrape_phone_numbers(page.body)).uniq
          end
        end
      end
    rescue
      puts "#{uri} timed out after #{max_time_per_company} seconds or there was an error"
    end

    # if no emails were found, try secondary scraper
    if company['scraped_emails'].nil? || company['scraped_emails'].empty?
      begin
        Timeout::timeout(max_time_per_company*2) do
          puts "No emails found for #{uri}. Attempting secondary scrape"
          company['scraped_emails'] = scrape_site_for_emails uri
        end
      rescue Exception => e
        puts "#{uri} secondary scrape timed out after #{max_time_per_company*2} seconds: #{e}"
        puts e.to_s
      end
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
