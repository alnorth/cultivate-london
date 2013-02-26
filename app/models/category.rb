class Category < ActiveRecord::Base
  has_many :crops

  attr_accessible :name
end
