class Size < ActiveRecord::Base
  attr_accessible :name

  def self.case_insensitive_find_or_create_by_name(name)
    first(:conditions => ['UPPER(name) = UPPER(?)', name]) || create(:name => name)
  end
end
