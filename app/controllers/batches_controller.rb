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
    batch.site = Site.case_insensitive_find_or_create_by_name(data[:site_name])
    batch.category = Category.case_insensitive_find_or_create_by_name(data[:category_name])
    batch.crop = Crop.find_or_create_by_name_and_category(data[:crop_name], batch.category)
    batch.type = Type.find_or_create_by_name_and_crop(data[:type_name], batch.crop)

    batch.generation = data[:generation]
    batch.size = Size.case_insensitive_find_or_create_by_name(data[:size_name])
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
