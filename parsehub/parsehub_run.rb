class ParsehubRun < ActiveRecord::Base  
  validates :run_token, presence: true, uniqueness: true

  def self.parsehub_get url
    uri = URI.parse(url)
    uri.query = URI.encode_www_form({:api_key => PARSEHUB_KEY})
    response =  Net::HTTP.get_response(uri)
    JSON.parse response.body
  end

  def self.parsehub_post url, options=nil
    uri = URI.parse(url)
    form_data = { api_key: PARSEHUB_KEY }
    form_data[:start_value_override] = options.to_json unless options.nil?
    uri.query = URI.encode_www_form(form_data)
    response =  Net::HTTP.post_form(uri, form_data)
    JSON.parse response.body
  end

  def self.create_parsehub_run project_token, form_data=nil
    response = ParsehubRun.parsehub_post "https://www.parsehub.com/api/v2/projects/#{project_token}/run", form_data
    ParsehubRun.create!(run_token: response['run_token'], project_token: project_token)
  end

  def get_status
    response = ParsehubRun.parsehub_get "https://www.parsehub.com/api/v2/runs/#{run_token}"
    update!(complete: (response['data_ready'] == 1))
    response
  end

  def get_results
    if complete?
      results = ParsehubRun.parsehub_get "https://www.parsehub.com/api/v2/runs/#{run_token}/data"
      update!(results: results.to_json)
      return results
    end
  end

  def delete_from_parsehub
    uri = URI.parse("https://www.parsehub.com/api/v2/runs/#{run_token}")
    uri.query = URI.encode_www_form({api_key: PARSEHUB_KEY})
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request =  Net::HTTP::Delete.new(uri.request_uri)
    response = http.request(request)
    JSON.parse response.body
  end
  
end
