class ReportsController < ApplicationController

  # GET /reports
  def index
    @reports = Report.find(:all).paginate :page => @page, :per_page => 20
  end
end