class DatabaseController < ApplicationController
  def index
    @year = params[:year] || Date.today.year
    @search = params[:search]
    @batches = get_batches(@year, @search)
    @stages = Stage.ordered.map { |s| { :id => s.name.demodulize.downcase, :title => s.title }}

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @batches }
    end
  end

  def get_batches(year, search = nil)
    batches = Batch.includes([:site, :category, :crop, :size])
      .where(:year => year)

    if not search.nil?
      batches = batches.where([
        "crops.name LIKE :search OR sites.name LIKE :search OR categories.name LIKE :search OR sizes.name LIKE :search",
        {:search => '%' + params[:search] + '%'}
      ])
    end

    batches
  end
end
