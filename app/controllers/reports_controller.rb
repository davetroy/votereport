class ReportsController < ApplicationController

  # GET /reports
  def index
    @per_page = params[:count] || 4
    @page = params[:page] || 1
    
    respond_to do |format|
      format.kml do
        @reports = Report.with_location.find(:all)
        case params[:live]
        when /1/
          render :template => "reports/reports.kml.builder"
        else
          render :template => "reports/index.kml.builder"
        end
      end
      format.atom do
        @reports = Report.with_location.find(:all).paginate :page => @page, :per_page => @per_page
      end
      format.html do
        @reports = Report.find(:all).paginate :page => @page, :per_page => @per_page
      end
    end
  end
end