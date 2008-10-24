require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  def test_new_user
    # User is brand new
    User.connection.execute('TRUNCATE TABLE users')
    myuser = User.create(:first_name => 'Joe',
                        :last_name => 'Public',
                        :url => 'http://foo.com',
                        :password => 'nodule',
                        :email => 'foo@bar.com')
    assert myuser.reload
    assert_equal 'Joe Public', myuser.name
    assert_equal 'http://foo.com', myuser.url
    assert_equal 'foo@bar.com', myuser.email
    assert !myuser.activated

    # User receives verification email and submits api_key for verification
    assert User.find_by_api_key(myuser.api_key).verify(myuser.api_key)
    assert myuser.reload
    assert myuser.verified
    assert myuser.activated
    
    # check default values
    %w(day_query_count day_update_count query_count update_count).each { |a| assert_zero myuser.send(a) }
    assert_equal DEFAULT_QUERY_LIMIT, myuser.day_query_limit
    assert_equal DEFAULT_UPDATE_LIMIT, myuser.day_update_limit
    
    # check to be sure authentication works
    assert_equal myuser.id, User.authenticate(:email => 'foo@bar.com', :password => 'nodule')
  end
  
end