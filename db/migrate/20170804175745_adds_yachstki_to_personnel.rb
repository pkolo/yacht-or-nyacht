class AddsYachstkiToPersonnel < ActiveRecord::Migration
  def change
    add_column :personnels, :yachtski, :float, index: true
  end
end
