require File.dirname(__FILE__) + '/../test_helper'

class ReviewerAlertTest < ActiveSupport::TestCase
  def test_viewing_an_alert_should_hide_it_from_that_user
    user = users(:quentin)
    alert = reviewer_alerts(:alert_1)
    
    assert user.unviewed_alerts.include?(alert)
    
    user.viewed_alert!(alert)
    user.reload
    assert !user.unviewed_alerts.include?(alert)
  end
end
