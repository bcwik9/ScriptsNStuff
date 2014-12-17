json.array!(@securities) do |security|
  json.extract! security, :id, :sec_type, :price, :multiplier, :amount
  json.url security_url(security, format: :json)
end
