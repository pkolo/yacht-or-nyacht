class CreateArtistsTable < ActiveRecord::Migration
  def change
    create_table(:artists) do |t|
      t.column :name, :string, null: false
    end
  end
end
