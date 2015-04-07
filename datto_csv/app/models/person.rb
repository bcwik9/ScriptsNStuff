class Person < ActiveRecord::Base

  def to_s
    [self.id, self.first_name, self.last_name, self.age, self.github_account, self.date_of_third_grade_graduation].join ','
  end
end
