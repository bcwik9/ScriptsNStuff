class Portfolio < ActiveRecord::Base
  has_many :securities
end
