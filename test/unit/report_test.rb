require File.dirname(__FILE__) + '/../test_helper'

class ReportTest < ActiveSupport::TestCase
  fixtures :reports, :users
  
  def setup
    @twitter_reporter = reporters(:reporters_001)
    @sms_reporter = reporters(:reporters_011)
  end
  
  # Tests to be sure that locations are detected properly
  def test_location_detection
    assert_equal "80303", @twitter_reporter.reports.create(:text => 'Long wait in #80303').location.postal_code
    assert_equal "Boston, MA 02130, USA", @twitter_reporter.reports.create(:text => 'Insane lines at #zip-02130').location.address
    assert_equal "90 Church Rd, Arnold, MD 21012, USA", @twitter_reporter.reports.create(:text => 'L:90 Church Road, Arnold, MD: bad situation').location.address
    assert_equal "21804", @twitter_reporter.reports.create(:text => '#zip21804 weird stuff happening').location.postal_code
    assert_equal "Church Hill", @twitter_reporter.reports.create(:text => 'Things are off in L:Church Hill, MD').location.locality
    assert_equal "94107", @twitter_reporter.reports.create(:text => 'No 94107 worries!').location.postal_code
    assert_equal "21012", @twitter_reporter.reports.create(:text => 'going swimmingly l:21012-2423').zip
    assert_equal "Severna Park, 21146 US", @twitter_reporter.reports.create(:text => 'Long lines at l:severna park senior HS').location.address
    assert_equal "New York 11215, USA", @twitter_reporter.reports.create(:text => 'wait:105 in Park Slope, Brooklyn zip11215 #votereport').location.address
    assert_equal "Courthouse, Virginia, USA", @twitter_reporter.reports.create(:text => 'no joy and long wait in l:courthouse, va').location.address
    # with mis-spelling:
    assert_equal "Boulder, CO, USA", @twitter_reporter.reports.create(:text => 'long lines at courthouse L:Bolder CO').location.address
  end
  
  # Tests to be sure that tags are properly assigned to a given report
  # and that reports are scored correctly
  def test_tag_assignment
    assert_equal 2, @twitter_reporter.reports.create(:text => 'my #machine is #good').tags.size
    assert_equal 7, @twitter_reporter.reports.create(:text => 'many #challenges here, #bad').score
    goodreport = @twitter_reporter.reports.create(:text => 'no problems #good overall, #wait12')
    assert_equal 12, goodreport.wait_time
    assert_equal 0, goodreport.score
    assert_equal 2, goodreport.tags.size
  end
  
  # Tests to be sure that a report made in a particular location
  # is asoociated with the correct geographical filters - subject to fixtures
  def test_filter_creation
    md_report = @twitter_reporter.reports.create(:text => 'here in #21108')
    assert_equal 5, (md_report.filters & %w(annapolis baltimore maryland northamerica unitedstates).map { |c| Filter.find_by_name(c) }).size
    ca_report = @twitter_reporter.reports.create(:text => 'all is well in 94107')
    assert_equal 4, (ca_report.filters & %w(sanfrancisco california northamerica unitedstates).map { |c| Filter.find_by_name(c) }).size
  end
  
  def test_review_assignment
    @reports = Report.unassigned.assign(users(:bob))
    assert_equal 10, @reports.size
    @reports.each do |r|
      assert_equal users(:bob), r.reviewer
    end
  end
end
