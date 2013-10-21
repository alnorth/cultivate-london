class Crop < ActiveRecord::Base
  belongs_to :category
  has_many :types

  attr_accessible :name, :category_id

  def self.find_or_create_by_name_and_category(name, category)
    first(:conditions => ['UPPER(name) = UPPER(?) AND category_id = ?', name, category.id]) || create(:name => name, :category_id => category)
  end
end
