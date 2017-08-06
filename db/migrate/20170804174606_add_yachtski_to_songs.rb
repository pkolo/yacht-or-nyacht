class AddYachtskiToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :yachtski, :float, index: true
  end
end
