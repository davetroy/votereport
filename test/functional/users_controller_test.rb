require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < ActionController::TestCase
  fixtures :users

  def test_should_allow_signup
    assert_difference 'User.count' do
      create_user(:email => "abc@xyz.com")
      assert_response :redirect
    end
  end

  def test_should_require_email_on_signup
    assert_no_difference 'User.count' do
      create_user(:email => nil)
      assert assigns(:user).errors.on(:email)
      assert_response :success
    end
  end

  def test_should_require_password_on_signup
    assert_no_difference 'User.count' do
      create_user(:password => nil, :email => "need-pass@pass.com")
      assert assigns(:user).errors.on(:password)
      assert_response :success
    end
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference 'User.count' do
      create_user(:password_confirmation => nil)
      assert assigns(:user).errors.on(:password_confirmation)
      assert_response :success
    end
  end
  
  def test_should_activate_user_immediately_upon_sign_up
    create_user(:email => "activate@activate.com")
    assigns(:user).reload
    assert assigns(:user).active?
  end
  
  def test_should_login_user_upon_sign_up
    create_user(:email => "login@signup.com")
    assigns(:user).reload
    assert session[:user_id] == assigns(:user).id
  end

  protected
    def create_user(options = {})
      get :new
      assert session[:captcha_num_1]
      assert session[:captcha_num_2]
      fakeasscaptcha = session[:captcha_num_1] + session[:captcha_num_2]
      post :create, :fakeasscaptcha => fakeasscaptcha,
                    :user => { :first_name => "Sir",
                          :last_name => "Quire",
                          :email => 'quire@example.com', 
                          :password => 'quire69', 
                          :password_confirmation => 'quire69',
                          :url => 'http://quire.com' }.merge(options)
    end
end
