class Security < ActiveRecord::Base
  belongs_to :portfolio

  def self.import file
    CSV.foreach(file.path, headers: true) do |row|
      Security.create! row.to_hash
    end
  end
end
