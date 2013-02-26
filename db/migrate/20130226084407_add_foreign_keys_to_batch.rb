class AddForeignKeysToBatch < ActiveRecord::Migration
  def up
    change_table :batches do |t|
      t.foreign_key :sites, dependent: :delete
      t.foreign_key :categories, dependent: :delete
      t.foreign_key :crops, dependent: :delete
      t.foreign_key :types, dependent: :delete
      t.foreign_key :sizes, dependent: :delete
    end
  end

  def down
    change_table :batches do |t|
      t.remove_foreign_key :sites, dependent: :delete
      t.remove_foreign_key :categories, dependent: :delete
      t.remove_foreign_key :crops, dependent: :delete
      t.remove_foreign_key :types, dependent: :delete
      t.remove_foreign_key :sizes, dependent: :delete
    end
  end
end
