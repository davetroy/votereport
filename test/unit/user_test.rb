require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures :users

  def test_new_user
    user = create_user(:first_name => "Joe", :last_name => "Public",
                       :url => "http://example.com/", :email => "foo@example.com")
  
    assert user.reload
    assert_equal 'Joe Public', user.name
    assert_equal 'http://example.com/', user.url
    assert_equal 'foo@example.com', user.email
    assert !user.api_key.nil?
    assert !user.active?
  end

  def test_user_verification
    user = create_user(:url =>"http://api.com", :email =>"foo@api.com")
  
    # User receives verification email and submits api_key for verification
    assert User.find_by_api_key(user.api_key).verify(user.api_key)
    assert user.reload
    assert user.authorized_for_api?
  
    # check default values
    %w(day_query_count day_update_count query_count update_count).each { |a| assert_zero user.send(a) }
    assert_equal DEFAULT_QUERY_LIMIT, user.day_query_limit
    assert_equal DEFAULT_UPDATE_LIMIT, user.day_update_limit
  end

  def test_authentication
    user = create_user(:url => "http://authentication.com", 
                       :email => "foo@auth.com")
    
    user.password = "nodule"
    user.password_confirmation = "nodule"
    user.save!
    user.activate!

    # check to be sure authentication works
    assert_equal user, User.authenticate('foo@auth.com', 'nodule')
  end
  
  def test_user_is_not_admin_by_default
    user = create_user(:email => "non-admin@admin.com")
    assert !user.is_admin?
  end
  
  def test_is_admin_email_address_overrides
    user = create_user(:email => User::ADMIN_EMAIL_ADDRESSES.first)
    
    assert user.is_admin?
  end
  
  def test_valid_email
    valid_attributes = {
      :first_name => "Sir",
      :last_name => "Quire",
      :password => 'quire69', 
      :password_confirmation => 'quire69',
      :url => 'http://emails.com'
    }
    
    invalid_emails = ["asdf","", "abc[at]foo.com", "@xyz.com"]
    
    invalid_emails.each do |invalid_email|
      assert !User.new(valid_attributes.merge(:email =>invalid_email)).valid?,
        "User should not be valid w/ invalid email '#{invalid_email}'"
    end
  end
  
  def test_should_create_user
    assert_difference 'User.count' do
      user = create_user(:email => "new_user@example.com", :url => "http://xyz.com")
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end
  
  def test_should_create_api_key
    assert_difference 'User.count' do
      user = create_user(:email => "api_key@example.com")
      assert !user.api_key.nil?
    end
  end

  def test_should_initialize_activation_code_upon_creation
    user = create_user(:email => "initialize@example.com", :url => "http://activeate_code.com")
    user.reload
    assert_not_nil user.activation_code
  end

  def test_should_reset_password
    u = users(:quentin)
    u.update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal users(:quentin), User.authenticate(u.email, 'new password')
  end
  
  def test_should_not_rehash_password
    users(:quentin).update_attributes(:email => "quentin2@quentin.com")
    assert_equal users(:quentin), User.authenticate('quentin2@quentin.com', 'monkey')
  end

  def test_should_authenticate_user
    assert_equal users(:quentin), User.authenticate('quentin@example.com', 'monkey')
  end

  def test_should_set_remember_token
    users(:quentin).remember_me
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
  end

  def test_should_unset_remember_token
    users(:quentin).remember_me
    assert_not_nil users(:quentin).remember_token
    users(:quentin).forget_me
    assert_nil users(:quentin).remember_token
  end

  def test_should_remember_me_for_one_week
    before = 1.week.from_now.utc
    users(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert users(:quentin).remember_token_expires_at.between?(before, after)
  end

  def test_should_remember_me_until_one_week
    time = 1.week.from_now.utc
    users(:quentin).remember_me_until time
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert_equal users(:quentin).remember_token_expires_at, time
  end

  def test_should_remember_me_default_two_weeks
    before = 2.weeks.from_now.utc
    users(:quentin).remember_me
    after = 2.weeks.from_now.utc
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert users(:quentin).remember_token_expires_at.between?(before, after)
  end
  
  def test_user_termination
    u = users(:quentin)
    h = u.crypted_password
    u.terminate!
    u.reload
    assert u.is_terminated?
    assert !u.has_access?
    assert_not_equal h, u.crypted_password
    u.unterminate!
    assert !u.is_terminated?
    assert u.has_access?
    assert_equal h, u.crypted_password
  end

protected
  def create_user(options = {})
    record = User.new({ :first_name => "Sir",
                        :last_name => "Quire",
                        :email => 'quire@example.com', 
                        :password => 'quire69', 
                        :password_confirmation => 'quire69',
                        :url => 'http://quire.com' }.merge(options))
    record.save!
    record
  end

  
end