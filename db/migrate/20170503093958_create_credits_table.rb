class CreateCreditsTable < ActiveRecord::Migration
  def change
    create_table :credits do |t|
      t.string :role, null: false
      t.references :personnel, index: true
      t.references :creditable, polymorphic: true, index: true

      t.timestamps
    end
  end
end
