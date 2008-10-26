require File.dirname(__FILE__) + '/../test_helper'

class ReporterTest < ActiveSupport::TestCase
  def test_twitter_reporter_creation
    reporter = TwitterReporter.create(:uniqueid => 1234, :name => "Bob", :screen_name => 'nitro', :followers_count => 3, :profile_location => '90210')
    assert_equal 3, reporter.followers_count
    assert_equal "Twitter", reporter.source_name
    assert_equal "Beverly Hills, CA 90210, USA", reporter.location.address
    assert_equal "TwitterReporter", reporter.type
    report = reporter.reports.create(:uniqueid => '29292929', :text => 'chilling in l:80303')
    assert_equal 1, reporter.reports.size
    assert_equal "Boulder, CO 80303, USA", report.location.address
  end
  
  def test_iphone_reporter_creation
    reporter = IphoneReporter.create(:udid => '00000000-0000-1000-8000-0017F20429CC', :name => "Fred J")
    assert_nil reporter.followers_count
    assert_equal "VoteReport iPhone App", reporter.source_name
    report = reporter.reports.create(:uniqueid => '829388202', :text => 'all is well in l:New York')
    assert_equal 1, reporter.reports.size
    assert_equal "New York, NY, USA", report.location.address
  end
  
  def test_sms_reporter_creation
    reporter = SmsReporter.create(:uniqueid => '59849943976')
    assert_equal "SMS", reporter.source_name
    report = reporter.reports.create(:uniqueid => '28932389029822', :text => 'whatever you like zip#35216')
    assert_equal 1, reporter.reports.size
    assert_equal "Alabama 35216, USA", report.location.address
  end
  
  def test_phone_reporter_creation
    reporter = PhoneReporter.create(:uniqueid => '4105705739')
    assert_equal "Telephone", reporter.source_name
    report = reporter.reports.create(:uniqueid => '1199998692.10', :zip => '80303')
    assert_equal 1, reporter.reports.size
  end
end