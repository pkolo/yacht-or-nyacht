class CreateSongsTable < ActiveRecord::Migration
  def change
    create_table(:songs) do |t|
      t.column :title, :string, null: false
      t.column :artist, :string, null: false
      t.column :year, :integer, null: false
      t.column :dave_score, :float, null: false
      t.column :jd_score, :float, null: false
      t.column :hunter_score, :float, null: false
      t.column :steve_score, :float, null: false
    end
  end
end
