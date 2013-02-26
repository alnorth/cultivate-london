class Type < ActiveRecord::Base
  belongs_to :crop

  attr_accessible :name
end
