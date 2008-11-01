class ReviewerAlertsController < ApplicationController
  ADMIN_ACTIONS = %w(new create)
  
  before_filter :login_required, :except => ADMIN_ACTIONS
  before_filter :admin_required, :only => ADMIN_ACTIONS
  
  def new
    @reviewer_alert = ReviewerAlert.new
  end
  
  def create
    @reviewer_alert = ReviewerAlert.new(params[:reviewer_alert])
    @reviewer_alert.user = current_user
    @reviewer_alert.save!
    
    flash[:notice] = "Saved this alert"
    redirect_to :action => :new
  end
  
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