class AddForeignKeys < ActiveRecord::Migration
  def up
    change_table :crops do |t|
      t.foreign_key :categories, dependent: :delete
    end
    change_table :types do |t|
      t.foreign_key :crops, dependent: :delete
    end
  end

  def down
    change_table :crops do |t|
      t.remove_foreign_key :categories
    end
    change_table :types do |t|
      t.remove_foreign_key :crops
    end
  end
end
