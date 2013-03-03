class BatchesController < ApplicationController
  def save
    p = params[:batch]

    batch = Batch.where(:id => p[:id]).first_or_create()

    batch.site = Site.where(:name => p[:site_name]).first_or_create()
    batch.category = Category.where(:name => p[:category_name]).first_or_create()
    batch.crop = Crop.where(:name => p[:crop_name]).first_or_create()
    batch.type = Type.where(:name => p[:type_name]).first_or_create()

    batch.generation = p[:generation]
    batch.size = Size.where(:name => p[:size_name]).first_or_create()
    batch.units_per_tray = p[:units_per_tray]
    batch.total_trays = p[:total_trays]

    batch.start_week = p[:start_week]
    batch.germinate_week = p[:germinate_week]
    batch.pot_week = p[:pot_week]
    batch.sale_week = p[:sale_week]
    batch.expiry_week = p[:expiry_week]

    batch.save()

    respond_to do |format|
      format.json { render json: batch }
    end
  end
end
