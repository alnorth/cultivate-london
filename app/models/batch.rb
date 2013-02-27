class Batch < ActiveRecord::Base
  belongs_to :site
  belongs_to :category
  belongs_to :crop
  belongs_to :type
  belongs_to :size

  attr_accessible :expiry_week, :generation, :germinate_week, :pot_week, :sale_week, :start_week, :total_trays, :units_per_tray, :site_id, :category_id, :crop_id, :type_id, :size_id

  def serializable_hash(options={})
    options = {
      :include => {
        :site => {:only => [:name]},
        :category => {:only => [:name]},
        :type => {:only => [:name]},
        :crop => {:only => [:name]},
        :size => {:only => [:name]}
      },
      :only => [:id, :expiry_week, :generation, :germinate_week, :pot_week, :sale_week, :start_week, :total_trays, :units_per_tray]
    }.update(options)
    super(options)
  end
end
