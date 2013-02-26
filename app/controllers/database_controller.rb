class DatabaseController < ApplicationController
  def index
    if params[:search]
      @batches = Batch.includes([:site, :category, :crop, :size])
        .where([
          "crops.name LIKE :search OR sites.name LIKE :search OR categories.name LIKE :search OR sizes.name LIKE :search",
          {:search => '%' + params[:search] + '%'}
        ])
    else
      @batches = Batch.includes([:site, :category, :crop, :size])
    end
    @search = params[:search]

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @photos }
    end
  end
end
