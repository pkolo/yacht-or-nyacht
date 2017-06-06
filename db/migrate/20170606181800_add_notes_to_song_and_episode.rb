class AddNotesToSongAndEpisode < ActiveRecord::Migration
  def change
    add_column :songs, :notes, :text, index: true
    add_column :episodes, :notes, :text, index: true
  end
end
