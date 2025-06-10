class CreateEpisodes < ActiveRecord::Migration[7.2]
  def change
    create_table :episodes do |t|
      t.string :name, null: false
      t.integer :season
      t.integer :episode_number
      t.string :episode_type
      t.integer :runtime
      t.decimal :rating, precision: 3, scale: 1
      t.string :image_medium
      t.string :image_original
      t.text :summary
      t.references :tv_show, null: false, foreign_key: true
      t.integer :tvmaze_id, null: false

      t.timestamps
    end

    add_index :episodes, :tvmaze_id, unique: true
    add_index :episodes, [ :tv_show_id, :season, :episode_number ], unique: true
    add_index :episodes, :season
    add_index :episodes, :episode_number
  end
end
