class CreateCreditsTable < ActiveRecord::Migration
  def change
    create_table :credits do |t|
      t.string :role
      t.references :personnel, index: true, foreign_key: true
      t.references :album, index: true, foreign_key: true

      t.timestamps
    end
  end
end
