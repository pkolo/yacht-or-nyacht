class AddIndicesToSearchColumns < ActiveRecord::Migration
  def change
    add_index :personnels, :name
    add_index :songs, :title
    add_index :albums, :title
  end
end
