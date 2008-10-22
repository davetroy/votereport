class ReportsController < ApplicationController

  # GET /reports
  def index
    @reports = Report.find(:all).paginate :page => @page, :total_entries => 200, :per_page => 20
  end
end