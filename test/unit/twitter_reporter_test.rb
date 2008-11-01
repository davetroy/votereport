require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  def test_profile_name
    reporter = TwitterReporter.new :screen_name => "vote_report"
    assert_equal("http://twitter.com/vote_report", reporter.profile)
  end
end