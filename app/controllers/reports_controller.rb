class ReportsController < ApplicationController

  # GET /reports
  def index
    @page = params[:page] || 1
    @reports = Report.find(:all).paginate :page => @page, :per_page => 20
    respond_to do |format|
      format.kml
      format.html
    end
  end
end