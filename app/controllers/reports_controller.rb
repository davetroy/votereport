class ReportsController < ApplicationController
  protect_from_forgery :except => :create
  
  # GET /reports
  def index
    @per_page = params[:count] || 10
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
        @reports = Report.with_location.paginate :page => @page, :per_page => @per_page
      end
      format.html do
        @reports = Report.paginate :page => @page, :per_page => @per_page, :order => 'created_at DESC'
      end
    end
  end
  
  def map  
  end
  
  # POST /reports
  # Used by iPhone app and API users
  def create
    respond_to do |format|
      format.iphone do
        if params[:reporter][:udid][/^[\d\-A-F]{36}$/]
          result = save_iphone_report(params)
          render :text => result and return true
        end
      end
    end
  end
  
  private
  def save_iphone_report(info)
    if loc = Location.geocode(info[:location][:latlon])
      loc.update_attribute(:address,info[:reporter][:profile_location]) if loc.address.nil? && info[:reporter][:profile_location]
    end
    location_id = loc ? loc.id : nil
    reporter = IphoneReporter.update_or_create(info[:reporter].merge(:location_id => location_id))
    reporter.reports.create(info[:report].merge(:location_id => location_id))
    "OK"
  rescue => e
    logger.info "*** ERROR: #{e.class}: #{e.message} #{e.backtrace.first}"
    "ERROR"
  end
end
