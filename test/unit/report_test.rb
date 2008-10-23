require File.dirname(__FILE__) + '/../test_helper'

class ReportTest < ActiveSupport::TestCase
  
  # Tests to be sure that locations are detected properly
  def test_location_detection
    assert_equal "80303", Report.create(:tid => 1, :text => 'Long wait in #80303').location.postal_code
    assert_equal "Boston, MA 02130, USA", Report.create(:tid => 2, :text => 'Insane lines at #zip-02130').location.address
    assert_equal "90 Church Rd, Arnold, MD 21012, USA", Report.create(:tid => 3, :text => 'L:90 Church Road, Arnold, MD: bad situation').location.address
    assert_equal "21804", Report.create(:tid => 4, :text => '#zip21804 weird stuff happening').location.postal_code
    assert_equal "Church Hill, MD, USA", Report.create(:tid => 5, :text => 'Things are off in L:Church Hill, MD').location.address
    assert_equal "94107", Report.create(:tid => 6, :text => 'No 94107 worries!').location.postal_code
    assert_equal "21012", Report.create(:tid => 7, :text => 'going swimmingly l:21012-2423').zip
    assert_equal "Severna Park, 21146 US", Report.create(:tid => 8, :text => 'Long lines at l:severna park senior HS').location.address
    assert_equal "New York 11215, USA", Report.create(:tid => 9, :text => 'wait:105 in Park Slope, Brooklyn zip11215 #votereport').location.address
    assert_equal "Courthouse, Virginia, USA", Report.create(:tid => 10, :text => 'no joy and long wait in l:courthouse, va').location.address
  end
  
  # Tests to be sure that tags are properly assigned to a given report
  # and that reports are scored correctly
  def test_tag_assignment
    assert_equal 2, Report.create(:tid => 1, :text => 'my #machine is #good').tags.size
    assert_equal 7, Report.create(:tid => 2, :text => 'many #challenges here, #bad').score
    goodreport = Report.create(:tid => 3, :text => 'no problems #good overall, #wait:12')
    assert_equal 12, goodreport.wait_time
    assert_equal 0, goodreport.score
  end
  
  # Tests to be sure that a report made in a particular location
  # is asoociated with the correct geographical filters
  def test_filter_creation
    md_report = Report.create(:tid => 1, :text => 'here in #21108')
    assert_equal 5, (md_report.filters & %w(annapolis baltimore maryland northamerica unitedstates).map { |c| Filter.find_by_name(c) }).size
    ca_report = Report.create(:tid => 2, :text => 'all is well in 94107')
    assert_equal 4, (ca_report.filters & %w(sanfrancisco california northamerica unitedstates).map { |c| Filter.find_by_name(c) }).size
  end
end
