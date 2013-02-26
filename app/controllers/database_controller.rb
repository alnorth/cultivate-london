class DatabaseController < ApplicationController
  def index
    @batches = Batch.includes([:site, :category, :crop, :size])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @photos }
    end
  end
end
