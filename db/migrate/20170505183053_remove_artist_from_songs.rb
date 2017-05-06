class RemoveArtistFromSongs < ActiveRecord::Migration
  def change
    remove_reference :songs, :artist, index: true
  end
end
