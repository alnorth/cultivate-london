class CreateBatches < ActiveRecord::Migration
  def change
    create_table :batches do |t|
      t.integer :generation
      t.integer :units_per_tray
      t.integer :total_trays
      t.integer :start_week
      t.integer :germinate_week
      t.integer :pot_week
      t.integer :sale_week
      t.integer :expiry_week

      t.references :site
      t.references :category
      t.references :crop
      t.references :type
      t.references :size

      t.timestamps
    end
  end
end
