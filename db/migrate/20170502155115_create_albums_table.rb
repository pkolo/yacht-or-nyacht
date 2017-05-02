class CreateAlbumsTable < ActiveRecord::Migration
  def change
    create_table :albums do |t|
      t.string :title, null: false
      t.string :discog_id, null: false

      t.timestamps
    end
  end
end
