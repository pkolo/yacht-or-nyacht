class AddsYachtskiToAlbums < ActiveRecord::Migration
  def change
    add_column :albums, :yachtski, :float, index: true
  end
end
