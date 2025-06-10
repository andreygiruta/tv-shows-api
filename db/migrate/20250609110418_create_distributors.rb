class CreateDistributors < ActiveRecord::Migration[7.2]
  def change
    create_table :distributors do |t|
      t.string :name, null: false
      t.string :country
      t.string :official_site
      t.integer :tvmaze_id, null: false

      t.timestamps
    end

    add_index :distributors, :tvmaze_id, unique: true
    add_index :distributors, :name
    add_index :distributors, :country
  end
end
