class ReportsController < ApplicationController
  def show
    d = Date.today
    @week_number = d.cweek
    @batches = Batch.includes([:site, :category, :crop, :size])
  end
end
