require 'spidr'

website = ARGV.first
website ||= 'http://www.klsdiversified.com/'
Spidr.site(website) do |spider|
  spider.every_page do |page|
    puts "[-] #{page.url}"
    next if page.url.to_s =~ /\.js/i # skip js pages

    phone_number_regex = /\(*(\d{3})\)*\s*-*\.*\s*(\d{3})\s*-*\.*\s*(\d{4})/
    matches = page.body.scan phone_number_regex
    matches.each do |match|
      puts "FOUND PHONE NUMBER: #{match.join ''}"
    end

    email_regex = /(([\w+\-](\.[\w+\-])?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+)/i
    matches = page.body.scan email_regex
    matches.each do |match|
      puts "FOUND EMAIL: #{match[0].to_s}"
    end
  end
end
