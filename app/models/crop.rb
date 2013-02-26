class Crop < ActiveRecord::Base
  belongs_to :category
  has_many :types

  attr_accessible :name, :category_id
end
