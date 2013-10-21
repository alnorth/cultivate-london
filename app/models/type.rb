class Type < ActiveRecord::Base
  belongs_to :crop

  attr_accessible :name, :crop_id

  def self.find_or_create_by_name_and_crop(name, crop)
    first(:conditions => ['UPPER(name) = UPPER(?) AND crop_id = ?', name, crop.id]) || create(:name => name, :crop_id => crop)
  end
end
