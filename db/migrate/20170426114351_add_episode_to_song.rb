class AddEpisodeToSong < ActiveRecord::Migration
  def change
    add_reference :songs, :episode, index: true
  end
end
