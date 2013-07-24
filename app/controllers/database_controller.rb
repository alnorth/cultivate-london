class DatabaseController < ApplicationController
  def index
    @year = params[:year] || Date.today.year
    @search = params[:search]
    @batches = get_batches(@year, @search)
    @staticData = {
      stages: Stage.ordered.map { |s| { :id => s.name.demodulize.downcase, :title => s.title }},
      sites: Site.all.map { |c| c.name },
      categories: Category.all.map { |c| c.name },
      crops: Crop.all.map { |c| c.name },
      types: Type.all.map { |c| c.name },
      sizes: Size.all.map { |c| c.name }
    }


    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @batches }
    end
  end

  def get_batches(year, search = nil)
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
