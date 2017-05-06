class RemoveArtistFromAlbum < ActiveRecord::Migration
  def change
    remove_reference :albums, :artist, index: true
  end
end
