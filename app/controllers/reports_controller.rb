class ReportsController < ApplicationController
  def show
    d = Date.today
    @week_number = d.cweek
    @batches = Batch.includes([:site, :category, :crop, :size])
      .where(:year => Date.today.year)
    @stages = Stage.ordered.map { |s| {
      :id => s.name.demodulize.downcase,
      :title => s.title,
      :field => s.field
    }}
  end

  def update
    params[:values].each do |batch_id, new_stage|
      batch = Batch.find(batch_id)
      batch.update_attribute(:stage, new_stage)
    end

    respond_to do |format|
      format.json { render json: { :success => true }}
    end
  end
end
