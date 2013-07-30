class AddStageToBatch < ActiveRecord::Migration
  def change
    change_table :batches do |t|
      t.string :stage
    end
  end
end
