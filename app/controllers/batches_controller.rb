class BatchesController < ApplicationController
  def create
    batch = Batch.create()
    update_and_save(batch, params[:batch], true)

    respond_to do |format|
      format.json { render json: batch }
    end
  end

  def update
    batch = Batch.find(params[:id])
    update_and_save(batch, params[:batch])

    respond_to do |format|
      format.json { render json: batch }
    end
  end

  def destroy
    batch = Batch.find(params[:id])
    batch.destroy

    respond_to do |format|
      format.json { render json: batch }
    end
  end

  def update_and_save(batch, data, is_new=false)
    batch.site = Site.where(name: data[:site_name]).first_or_create
    batch.category = Category.where(name: data[:category_name]).first_or_create
    batch.crop = Crop.where(name: data[:crop_name], category_id: batch.category).first_or_create
    batch.type = Type.where(name: data[:type_name], crop_id: batch.crop).first_or_create

    batch.generation = data[:generation]
    batch.size = Size.where(:name => data[:size_name]).first_or_create
    batch.units_per_tray = data[:units_per_tray]
    batch.total_trays = data[:total_trays]

    batch.start_week = data[:start_week]
    batch.germinate_week = data[:germinate_week]
    batch.pot_week = data[:pot_week]
    batch.sale_week = data[:sale_week]
    batch.expiry_week = data[:expiry_week]

    batch.stage = data[:stage]

    if is_new && !data[:year].nil?
      batch.year = data[:year]
    end

    batch.save()
  end
end
