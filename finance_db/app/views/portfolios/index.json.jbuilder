json.array!(@portfolios) do |portfolio|
  json.extract! portfolio, :id, :owner
  json.url portfolio_url(portfolio, format: :json)
end
