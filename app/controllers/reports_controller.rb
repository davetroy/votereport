class ReportsController < ApplicationController

  # GET /reports
  def index
    respond_to do |format|
      format.kml do
        @reports = Report.with_location.find(:all)
      end
      format.html do
        @page = params[:page] || 1
        @reports = Report.find(:all).paginate :page => @page, :per_page => 20
      end
    end
  end
end