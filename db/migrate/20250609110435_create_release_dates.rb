class CreateReleaseDates < ActiveRecord::Migration[7.2]
  def change
    create_table :release_dates do |t|
      t.date :airdate, null: false
      t.string :airtime
      t.references :episode, null: false, foreign_key: true

      t.timestamps
    end

    add_index :release_dates, :airdate
    add_index :release_dates, [ :airdate, :episode_id ], unique: true
    add_index :release_dates, [ :airdate, :airtime ]
  end
end
