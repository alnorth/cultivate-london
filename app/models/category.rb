class Category < ActiveRecord::Base
  has_many :crops

  attr_accessible :name

  def self.case_insensitive_find_or_create_by_name(name)
    first(:conditions => ['UPPER(name) = UPPER(?)', name]) || create(:name => name)
  end
end
