class Batch < ActiveRecord::Base
  belongs_to :site
  belongs_to :category
  belongs_to :crop
  belongs_to :type
  belongs_to :size

  attr_accessible :expiry_week, :generation, :germinate_week, :pot_week, :sale_week, :start_week, :total_trays, :units_per_tray
end
