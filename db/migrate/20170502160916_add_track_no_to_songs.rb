class AddTrackNoToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :track_no, :string
  end
end
