class Batch < ActiveRecord::Base
  belongs_to :site
  belongs_to :category
  belongs_to :crop
  belongs_to :type
  belongs_to :size

  classy_enum_attr :stage, :default => :sow

  attr_accessible :expiry_week, :generation, :germinate_week, :pot_week, :sale_week, :start_week, :total_trays, :units_per_tray, :site_id, :category_id, :crop_id, :type_id, :size_id, :stage

  # This is used when generating JSON. We don't send IDs for linked ojects, instead we send their names.
  def serializable_hash(options={})
    options = {
      :include => {
        :site => {:only => [:name]},
        :category => {:only => [:name]},
        :type => {:only => [:name]},
        :crop => {:only => [:name]},
        :size => {:only => [:name]}
      },
      :only => [:id, :expiry_week, :generation, :germinate_week, :pot_week, :sale_week, :start_week, :total_trays, :units_per_tray, :stage]
    }.update(options)
    super(options)
  end

end
