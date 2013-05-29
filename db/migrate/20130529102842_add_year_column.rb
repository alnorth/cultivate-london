class AddYearColumn < ActiveRecord::Migration
  def change
    change_table :batches do |t|
      t.integer :year
    end
  end
end
