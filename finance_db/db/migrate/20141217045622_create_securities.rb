class CreateSecurities < ActiveRecord::Migration
  def change
    create_table :securities do |t|
      t.string :sec_type
      t.float :price
      t.float :multiplier
      t.integer :amount

      t.timestamps
    end
  end
end
