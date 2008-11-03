class ReviewerAlertsController < ApplicationController
  NON_ADMIN_ACTIONS = %w(dismiss)
  layout "admin"
  
  before_filter :login_required, :only => NON_ADMIN_ACTIONS
  before_filter :admin_required, :except => NON_ADMIN_ACTIONS
  
  def index
    @reviewer_alerts = ReviewerAlert.paginate( 
          :page => params[:page] || 1,
          :per_page => 10,
          :order => "created_at DESC")
  end
  
  # GET /reviewer_alerts/new
  def new
    @reviewer_alert = ReviewerAlert.new
  end
  
  # POST /reviewer_alerts/create
  def create
    @reviewer_alert = ReviewerAlert.new(params[:reviewer_alert])
    @reviewer_alert.user = current_user
    @reviewer_alert.save!
    
    flash[:notice] = "Saved this alert"
    redirect_to :action => :new
  end
  
  # DELETE /reviewer_alerts/:id
  def destroy
    reviewer_alert = ReviewerAlert.find_by_id(params[:id]).destroy
    respond_to do |format|
      format.js {
        render :update do |page|
          page["reviewer_alert_#{reviewer_alert.id}"].visual_effect :fade
        end
      }
    end
  end
  
  # POST /reviewer_alerts/:id/dismiss
  def dismiss
    reviewer_alert = ReviewerAlert.find(params[:id])
    current_user.viewed_alert!(reviewer_alert)
    
    respond_to do |format|
      format.js {
        render :update do |page|
          page["reviewer_alert_#{reviewer_alert.id}"].visual_effect :fade
        end
      }
      format.any { render :nothing => true }
    end
  end
end