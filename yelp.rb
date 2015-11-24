# this script searches yelp and returns businesses in JSON format for the terms and areas you specify (edit below)

require 'yelp'
require 'json'

# Yelp API key info for my account
client = Yelp::Client.new({ consumer_key: 'jt1n4V-SWZuF2zsUveiNwQ',
                            consumer_secret: 'qPIfNjEr6akwxhpip-iGGaNctq0',
                            token: 'a1Yd_Yktd01lR47esdW430Jaezuh2iI0',
                            token_secret: 'pjjle_2TKFz-E9mYu-jCKC9twmY'
                          })


# Search options
save_to = 'yelp_results.json'
search_terms = ['transportation', 'limo', 'party bus']
search_areas = ['Boston, MA', 'Springfield, MA', 'Hartford, CT', 'New Haven, CT', 'New London, CT', 'Albany, NY', 'Newport, RI', 'Providence, RI', 'Plymouth, MA', 'Barnstable, MA', 'Portsmouth, NH', 'Manchester, NH', 'Laconia, NH', 'Portland, ME', 'Brunswick, ME', 'Philadelphia, PA', 'Cherry Hill, NJ', 'Atlantic City, NJ', 'Toms River, NJ', 'Princeton, NJ', 'Allentown, PA', 'Scranton, PA', 'Harrisburg, PA', 'Baltimore, MD', 'Washington DC', 'Alexandria, VA', 'Richmond, VA', 'Harrisonburg, VA', 'Charlottesville, VA', 'Ocean City, MD']
max_results = 20 # Yelp API max is 20, otherwise it will error

# Start searching
businesses = {}
search_areas.each do |area|
  search_terms.each do |term|
    params = { 
      term: term,
      limit: max_results,
      offset: 0,
      #sort: 1, # 1 is sort by distance
      #radius_filter: 40000, # 40000 meters (25miles) is max
      #category_filter: 'partybusrentals,transport'
    }
    results = client.search(area, params)
    while results.businesses.size > 0
      puts "Location: #{area} (#{search_areas.index(area)+1}/#{search_areas.size}). Search Term: #{term} (#{search_terms.index(term)+1}/#{search_terms.size}). Offset: #{params[:offset]}/#{results.total}. Total found: #{businesses.size}"
      results.businesses.each do |business|
        #businesses.push({
        businesses[business.url] = {
          name: business.name,
          phone: business.phone,
          url: business.url,
          address: business.location.display_address
        }
      end
      params[:offset] += max_results
      results = client.search(area, params)
    end

  end
end

File.open(save_to, 'w') { |f| f.puts businesses.values.to_json }
puts "Found #{businesses.size} businesses total"
puts "Results saved to #{save_to}"
