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
        result = save_iphone_report(params)
        render :text => result and return true
      end
    end
  end
  
  private
  # Store an iPhone-generated report given a hash of parameters
  # Check for a valid iPhone UDID
  def save_iphone_report(info)
    raise unless info[:reporter][:uniqueid][/^[\d\-A-F]{36}$/]
    if loc = Location.geocode(info[:location][:latlon])
      location_name = loc.address || info[:reporter][:profile_location]
      loc.update_attribute(:address,location_name) if location_name
    end
    location_id = loc ? loc.id : nil
    reporter = IphoneReporter.update_or_create(info[:reporter].merge(:location_id => location_id))
    reporter.reports.create(info[:report].merge(:location_id => location_id))
    "OK"
  rescue => e
    logger.info "*** ERROR: #{e.class}: #{e.message}\n\t#{e.backtrace.first}"
    "ERROR"
  end
end
