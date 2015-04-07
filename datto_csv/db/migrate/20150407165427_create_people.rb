class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :first_name
      t.string :last_name
      t.integer :age
      t.string :github_account
      t.date :date_of_third_grade_graduation

      t.timestamps null: false
    end
  end
end
