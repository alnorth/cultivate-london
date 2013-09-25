class DatabaseController < ApplicationController
  def index
    authorize! :manage, Batch

    @year = params[:year] || Date.today.year
    @search = params[:search]
    @batches = get_batches(@year, @search)
    @staticData = {
      stages: Stage.ordered.map { |s| { :id => s.name.demodulize.downcase, :title => s.title }},
      sites: Site.uniq.pluck(:name),
      categories: Category.uniq.pluck(:name),
      crops: Crop.uniq.pluck(:name),
      types: Type.uniq.pluck(:name),
      sizes: Size.uniq.pluck(:name)
    }


    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @batches }
    end
  end

  def get_batches(year, search = nil)
    authorize! :manage, Batch
    
    batches = Batch.includes([:site, :category, :crop, :size])
      .where(:year => year)
      .order(["sites.name", "categories.name", "crops.name", "sizes.name", "generation"])

    if not search.nil?
      batches = batches.where([
        "crops.name LIKE :search OR sites.name LIKE :search OR categories.name LIKE :search OR sizes.name LIKE :search",
        {:search => '%' + params[:search] + '%'}
      ])
    end

    batches
  end
end
