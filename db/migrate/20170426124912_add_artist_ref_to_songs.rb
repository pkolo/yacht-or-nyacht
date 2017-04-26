class AddArtistRefToSongs < ActiveRecord::Migration
  def change
    remove_column :songs, :artist
    add_reference :songs, :artist, index: true
  end
end
