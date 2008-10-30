class ReportsController < ApplicationController
  protect_from_forgery :except => :create
  before_filter :filter_from_params, :only => [ :index, :chart ]
  
  # GET /reports
  def index
    respond_to do |format|
      format.kml do
        @per_page = params[:count] || 20
        @reports = Report.with_location.paginate :page => @page, :per_page => @per_page, :order => 'created_at DESC'
        case params[:live]
        when /1/
          render :template => "reports/reports.kml.builder"
        else
          render :template => "reports/index.kml.builder"
        end
      end
      format.json do 
        @reports = Report.paginate :page => @page, :per_page => @per_page, :order => 'created_at DESC'
        render :json => @reports.to_json, :callback => params[:callback]
      end      
      format.atom do
        @reports = Report.with_location.paginate :page => @page, :per_page => @per_page, :order => 'created_at DESC'
      end
      format.html do
        @reports = Report.find_with_filters(@filters)
      end
    end
  end
  
  def map  
  end
  
  def chart 
    @reports = Report.with_wait_time.find_with_filters(@filters)     
  end
  
  # POST /reports
  # Used by iPhone app and API users
  def create
    respond_to do |format|
      format.iphone do
        result = save_iphone_report(params)
        render :text => result and return true
      end
      format.android do
        result = save_android_report(params)
        render :text => result and return true
      end
    end
  end
  
  private
  # Store an iPhone-generated report given a hash of parameters
  # Check for a valid iPhone UDID
  def save_iphone_report(info)
    raise "Invalid UDID" unless info[:reporter][:uniqueid][/^[\d\-A-F]{36,40}$/i]
    reporter = IphoneReporter.update_or_create(info[:reporter])
    polling_place = PollingPlace.match_or_create(info[:polling_place][:name], reporter.location)
    report = reporter.reports.create(info[:report].merge(:polling_place => polling_place))
    "OK"
  rescue => e
    logger.info "*** IPHONE ERROR: #{e.class}: #{e.message}\n\t#{e.backtrace.first}"
    "ERROR"
  end
  
  # Store an Android-generated report given a hash of parameters
  # Check for a valid Android IMEI
  def save_android_report(info)
    raise "Invalid IMEI" unless info[:reporter][:uniqueid][/^\d{14,16}/]
    reporter = AndroidReporter.update_or_create(info[:reporter])
    polling_place = PollingPlace.match_or_create(info[:polling_place][:name], reporter.location)
    report = reporter.reports.create(info[:report].merge(:polling_place => polling_place))
    "OK"
  rescue => e
    logger.info "*** ANDROID ERROR: #{e.class}: #{e.message}\n\t#{e.backtrace.first}"
    "ERROR"
  end
end
