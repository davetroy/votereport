# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  include AuthenticatedSystem

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'd5feb8525b287ec306f7d88ee9a9af83'
  
  def filter_from_params
    @per_page = params[:count] ||= params[:per_page] || 10
    @page = params[:page] ||= 1
    
    @filters = {:page => @page, :per_page => @per_page}
    [:q, :name, :wait_time, :dtstart, :dtend, :rating, :filter, :zip, :postal, :city, :state].each do |p|
      @filters[p] = params[p] if params[p]
    end
  end
  
  def admin_required
    (authorized? && current_user.is_admin?) || access_denied
  end
    
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
end
