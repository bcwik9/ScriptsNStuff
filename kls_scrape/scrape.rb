require 'spidr'

website = ARGV.first
website ||= 'http://www.klsdiversified.com/'
Spidr.site(website) do |spider|
  spider.every_page do |page|
    puts "[-] #{page.url}"
    next if page.url.to_s =~ /\.js/i # skip js pages

    if page.body =~ /\(*(\d{3})\)*\s*-*\.*\s*(\d{3})\s*-*\.*\s*(\d{4})/ # regex matches a phone number
      puts "FOUND PHONE NUMBER: #{$1.to_s + $2.to_s + $3.to_s}"
    end
  end
end
