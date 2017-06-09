class AddLinkToEpisodes < ActiveRecord::Migration
  def change
    add_column :episodes, :link, :string
  end
end
