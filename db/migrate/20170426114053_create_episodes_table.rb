class CreateEpisodesTable < ActiveRecord::Migration
  def change
    create_table(:episodes) do |t|
      t.column :number, :string
    end
  end
end
