# Search through wikipedia and gain all the knowledges!
class WikipediaSearch
  WIKIPEDIA_API_ENDPOINT = 'https://en.wikipedia.org/w/api.php'

  class << self

    # see https://www.mediawiki.org/wiki/API:Search
    def search_for term
      form_data = {
        format: :json,
        action: :query,
        list: :search,
        srsearch: term
      }
      response = http_get form_data
      response['query']['search'] if response.present? && response.has_key?('query')
    end

    # see https://www.mediawiki.org/wiki/Extension:TextExtracts#API
    def get_extracts params
      form_data = {
        format: :json,
        action: :query,
        redirects: true,
        prop: :extracts,
        exintro: true,
        explaintext: true,
      }
      # must specify either pageids or titles
      if params.has_key? :pageids
        form_data[:pageids] = params[:pageids]
      else
        form_data[:titles] = params[:titles]
      end
      
      response = http_get form_data
      response['query']['pages'] if response.present? && response.has_key?('query')
    end

    def get_extract_from_search_for term
      pages = get_extracts(titles: get_title_from_search_for(term)) 
      page = pages.first.last if pages.present?
      page['extract'] if page.present?
    end

    def get_title_from_search_for term
      pages = search_for term
      pages.first['title'] if pages.first.present?
    end

    private
    
    def http_get data
      uri = URI.parse(WIKIPEDIA_API_ENDPOINT)
      uri.query = URI.encode_www_form data
      response =  Net::HTTP.get_response(uri)
      JSON.parse response.body
    end
  end
end
