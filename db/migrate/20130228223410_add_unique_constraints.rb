class AddUniqueConstraints < ActiveRecord::Migration
  def up
    add_index :sites, :name, :unique => true
    add_index :categories, :name, :unique => true
    add_index :crops, :name, :unique => true
    add_index :types, :name, :unique => true
    add_index :sizes, :name, :unique => true
  end

  def down
    remove_index(:sites, :column => :name)
    remove_index(:categories, :column => :name)
    remove_index(:crops, :column => :name)
    remove_index(:types, :column => :name)
    remove_index(:sizes, :column => :name)
  end
end
