class CreatePersonnelTable < ActiveRecord::Migration
  def change
    create_table :personnels do |t|
      t.string :name, null: false
      t.string :discog_id

      t.timestamps
    end
  end
end
