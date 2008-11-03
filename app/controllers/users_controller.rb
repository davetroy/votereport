class UsersController < ApplicationController
  layout "admin"
  
  # render new.rhtml
  def new
    generate_captcha()
    
    @user = User.new
  end
 
  def create
    logout_keeping_session!
    @user = User.new(params[:user])

    # simple captcha
    unless validate_captcha()
      @user.errors.add_to_base("Please answer the simple math question to verify you are human!")
      raise ActiveRecord::RecordInvalid.new(@user)
    end
    
    success = @user && @user.save
    if success && @user.errors.empty?
      @user.activate! # auto-activate
      self.current_user = @user # login
      
      redirect_back_or_default('/reports/review')
      flash[:notice] = "Thanks for signing up!"
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      generate_captcha()
      render :action => 'new'
    end
  rescue ActiveRecord::RecordInvalid => e
    generate_captcha()
    render :action => 'new'
  end
    
  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      flash[:notice] = "Signup complete! Please sign in to continue."
      redirect_to '/login'
    when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default('/')
    else 
      flash[:error]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default('/')
    end
  end
  
  private
  
  def generate_captcha
    # generate simple captcha
    session[:captcha_num_1] = @captcha_num_1 = rand(8).to_i
    session[:captcha_num_2] = @captcha_num_2 = rand(8).to_i
  end
  
  def validate_captcha
    if session[:captcha_num_1].blank? || session[:captcha_num_2].blank?
      return false
    elsif params[:fakeasscaptcha].blank?
      return false
    else
      params[:fakeasscaptcha].to_i == session[:captcha_num_1] + session[:captcha_num_2]
    end
  end
  
end
