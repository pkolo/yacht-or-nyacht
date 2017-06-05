class AddSlugColumnsToSearchTables < ActiveRecord::Migration
  def change
    add_column :songs, :slug, :string, index: true
    add_column :personnels, :slug, :string, index: true
    add_column :albums, :slug, :string, index: true
  end
end
