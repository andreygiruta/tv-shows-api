class CreateTvShows < ActiveRecord::Migration[7.2]
  def change
    create_table :tv_shows do |t|
      t.string :name, null: false
      t.string :show_type
      t.string :language
      t.string :status
      t.integer :runtime
      t.date :premiered
      t.date :ended
      t.string :official_site
      t.decimal :rating, precision: 3, scale: 1
      t.text :genres
      t.string :schedule_time
      t.text :schedule_days
      t.string :image_medium
      t.string :image_original
      t.text :summary
      t.references :network, null: true, foreign_key: { to_table: :distributors }
      t.integer :tvmaze_id, null: false

      t.timestamps
    end

    add_index :tv_shows, :tvmaze_id, unique: true
    add_index :tv_shows, :name
    add_index :tv_shows, :status
    add_index :tv_shows, :premiered
    add_index :tv_shows, :rating
    add_index :tv_shows, %i[network_id status]
  end
end
