class AddYtToSong < ActiveRecord::Migration
  def change
    add_column :songs, :yt_id, :string
  end
end
