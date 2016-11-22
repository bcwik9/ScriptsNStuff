# This script runs through a list of websites and attempts to scrape emails off those sites. Typically used in conjunction with Parsehub.
require 'spidr'
require 'json'
require 'timeout'
require 'net/http'
require 'open-uri'
require 'open_uri_redirections'

### OPTIONS
files = Dir.glob("*.json") # typically this is a result from Parsehub. will reprocess file if filename ends in ".processed"
# yelp encodes urls
unescape_urls = true
# how long to wait between requesting pages to not overload and flag servers. minimum should be 1 seconds
delay_between_pages = 1
# max number of websites to process in parallel
max_website_threads = 1
# how to navigate the json
website_key = 'companies'
url_key = 'website'

def filter_url url
  # add pages to ignore here
  skip = ['jpg', 'pdf', 'css', 'ico', 'png']
  skip.any? { |s| url =~ /\.#{s}$/i }
end

def scrape_emails webpage_source
  email_regex = /(([\w+\-](\.[\w+\-])?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+)/i
  emails = []
  matches = webpage_source.scan email_regex
  matches.each do |match|
    email = match.first.to_s
    unless filter_url(email) || emails.include?(email)
      puts "FOUND EMAIL: #{email}"
      emails.push email
    end
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
  source = ""
  begin
    # TODO: rewrite this using open-uri which handles redirects automatically
    source =  open(uri.to_s, allow_redirections: :all).read

    # if we still don't have anything, try adding/removing "www"
    if source.empty?
      if uri.to_s =~ /www/i
        uri = URI(uri.to_s.gsub("http://www.", "http://"))
      else
        uri = URI(uri.to_s.gsub("http://", "http://www."))
      end
      source = open(uri.to_s, allow_redirections: :all).read
    end
  rescue Exception => e
    puts "Error fetching #{uri}: #{e}"
  end
  source
end

def secondary_scrape_site_for_emails uri, options={}
  options[:timeout] ||= 60
  source = get_webpage_source_for uri
  urls = scrape_webpage_links source, uri
  all_emails = []
  all_emails += scrape_emails(source)
  important_urls = ['about', 'contact', 'faq']
  process_first = urls.select{|website| important_urls.any?{|u| website.include?(u)} }
  urls -= process_first
  begin
    Timeout::timeout(options[:timeout]) do
      (process_first + urls).each do |url|
        begin
          next if filter_url(url)
          sleep 1
          uri = URI(url)
          puts "Checking #{uri}"
          all_emails += scrape_emails(get_webpage_source_for(uri))
        rescue
          puts "Skipping bad url: \"#{url}\""
        end
      end
    end
  rescue Exception => e
    puts "Secondary scraped for #{uri} timed out or there was an error #{e}"
  end
  all_emails.uniq!
  puts "Secondary scrape found #{all_emails.size} emails"
  all_emails
end


### START
files.each_with_index do |file, file_index|
  puts "Processing file #{file} (#{file_index+1}/#{files.size})"
  json_data = File.readlines(file).join ''
  companies = JSON.parse json_data
  companies = companies[website_key] unless file =~ /\.processed$/
  start_time = Time.now
  website_threads = []

  companies.each_with_index do |company, company_index|
    website_url = company[url_key]
    next if website_url.nil? || (company['scraped_emails'] && !company['scraped_emails'].empty?)
    website_url = URI.unescape website_url if unescape_urls
    uri = URI(website_url)
    uri = URI('http://' + website_url) if uri.scheme.nil? # must have http://
    company[url_key] = website_url if unescape_urls # update url so we don't have to unescape again

    # limit the number of threads running
    while website_threads.size >= max_website_threads do
      sleep 2
      website_threads.each do |t|
        unless t.alive?
          t.join
          website_threads.delete t
        end
      end
    end
    
    website_threads << Thread.new {
      begin
        Timeout::timeout(30) do
          Spidr.site(uri) do |spider|
            spider.every_html_page do |page|
              sleep delay_between_pages
              
              # skip certain pages
              page_url = page.url.to_s
              if filter_url(page_url)
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
        puts "#{uri} timed out after 30 seconds or there was an error"
      end
      
      # if no emails were found, try secondary scraper
      if company['scraped_emails'].nil? || company['scraped_emails'].empty?
        puts "No emails found for #{uri}. Attempting secondary scrape"
        company['scraped_emails'] = secondary_scrape_site_for_emails uri
      end
    }
  end

  # make sure all threads are done processing
  website_threads.each { |t| t.join }

  # post processing
  companies.each do |c|
    c['scraped_phone_numbers'] = c['scraped_phone_numbers'].join ', ' if c['scraped_phone_numbers'].is_a? Array
    c['scraped_emails'] = c['scraped_emails'].join ', ' if c['scraped_emails'].is_a? Array
  end

  File.open "#{file}\.processed", 'w' do |f|
    f.puts companies.to_json
  end
  puts "Finished processing #{file}. Elapsed time: #{(Time.now - start_time)/60} minutes"
end
