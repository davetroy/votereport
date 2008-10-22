class ReportsController < ApplicationController

  # GET /reports
  def index
    @reports = Report.find(:all)
  end
end