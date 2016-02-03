class CreateParsehubRuns < ActiveRecord::Migration
  def change
    create_table :parsehub_runs do |t|
      t.string :run_token, null: false, unique: true
      t.string :project_token, null: false
      t.boolean :complete, default: false
      t.text :results

      t.timestamps null: false
    end
  end
end
