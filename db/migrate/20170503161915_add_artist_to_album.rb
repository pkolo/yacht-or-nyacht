class AddArtistToAlbum < ActiveRecord::Migration
  def change
    add_reference :albums, :artist, index: true
    add_column :albums, :year, :integer
  end
end
