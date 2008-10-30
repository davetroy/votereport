require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @valid_attributes = {
      :first_name => 'Joe',
      :last_name => 'Public',
      :password => 'nodule'
    }
  end
  
  def test_user_is_valid
    user_attributes = @valid_attributes.merge(:url=> "http://foo.com", :email => "foo@bar.com")
    assert User.new(user_attributes).valid?, "User should be valid with valid attrs"
  end
  
  def test_new_user
    user = User.create(@valid_attributes.merge(:url => "http://example.com/", :email => "foo@example.com"))

    assert user.reload
    assert_equal 'Joe Public', user.name
    assert_equal 'http://example.com/', user.url
    assert_equal 'foo@example.com', user.email
    assert !user.activated
  end
  
  def test_user_verification
    user = User.create(@valid_attributes.merge(:url =>"http://api.com", :email =>"foo@api.com"))

    # User receives verification email and submits api_key for verification
    assert User.find_by_api_key(user.api_key).verify(user.api_key)
    assert user.reload
    assert user.verified
    assert user.activated
  
    # check default values
    %w(day_query_count day_update_count query_count update_count).each { |a| assert_zero user.send(a) }
    assert_equal DEFAULT_QUERY_LIMIT, user.day_query_limit
    assert_equal DEFAULT_UPDATE_LIMIT, user.day_update_limit
  end
  
  def test_authentication
    user = User.create(@valid_attributes.merge(:url => "http://authentication.com", :email => "foo@auth.com"))
    
    # check to be sure authentication works
    assert_equal user.id, User.authenticate(:email => 'foo@auth.com', :password => 'nodule')
  end
  
  def test_valid_email
    valid_attributes_with_url = @valid_attributes.merge(:url => "http://example2.com")
    
    invalid_emails = ["asdf","", "abc[at]foo.com", "@xyz.com"]
    
    invalid_emails.each do |invalid_email|
      assert !User.new(valid_attributes_with_url.merge(:email =>invalid_email)).valid?,
        "User should not be valid w/ invalid email"
    end
  end
  
end