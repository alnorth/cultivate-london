class AddStageToBatch < ActiveRecord::Migration
  def change
    change_table :batches do |t|
      t.integer :stage
    end
  end
end
