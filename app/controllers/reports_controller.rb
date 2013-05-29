class ReportsController < ApplicationController
  def show
    d = Date.today
    @week_number = d.cweek
    @batches = Batch.includes([:site, :category, :crop, :size])
      .where(:year => Date.today.year)
  end

  def update_stage
    stage = params[:stage]

    params[:values].each do |batch_id, new_stage|
      batch = Batch.find(batch_id)
      batch.update_attribute(:stage, new_stage)
    end

    respond_to do |format|
      format.json { render json: { :success => true }}
    end
  end
end
