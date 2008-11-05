require File.dirname(__FILE__) + '/../test_helper'

class ReportTest < ActiveSupport::TestCase
  fixtures :reports, :users, :tags
  
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
    goodreport.reload
    assert_equal 12, goodreport.wait_time
    assert_equal 0, goodreport.score
    assert_equal 2, goodreport.tags.size
    epreport = @twitter_reporter.reports.create(:text => 'being #challenges here #EPOH l:cincinnati oh')
    epreport.reload
    assert_equal 2, epreport.tags.size
    # FIXM - figure out how to get EPXX back into the tag_s, all we have is the pattern here
    #assert epreport.tag_s.split(' ').include?('EPOH'), "has tag_s: #{epreport.tag_s}"
  end
  
  def test_reviewed_arent_reassigned
    report = reports(:reports_022)
    report.confirm! # confirms without user_id
    report.reload
    assert report.is_confirmed?
    assert_not_nil report.reviewed_at
    assert !Report.unassigned.include?(report)

    report = reports(:reports_001)
    report.confirm!(users(:quentin))
    report.reload
    assert report.is_confirmed?
    assert_not_nil report.reviewed_at
    assert !Report.unassigned.include?(report)
  end
  
  def test_tag_assignment_by_string
    report = @twitter_reporter.reports.create(:text => 'all is well in 94107')
    assert report.tags.empty?, "there should be no tags at this point"
    report.tag_s = "registration machine challenges bogus ballots good bad"
    report.save!
    assert !report.tags.empty?, "tags should not be empty"
    assert_equal 6, report.tags.size, "there should be six tags"
    # make sure the bogus tag wasn't included
    assert !report.tag_s.split(' ').include?('bogus')
  end
  
  def test_tag_cache
    report = @twitter_reporter.reports.create(:text => 'no problems #good overall, #wait12')
    assert_equal 'good', report.tag_s, "'wait' tag should be excluded from cache"
  end
  
  def test_unusual_wait_tag_assignment
    # test negatives
    assert_nil create_report("there were long lines. #wait-30").wait_time
    assert_nil create_report("there were negative lines. wait:-30").wait_time
  end
  
  def test_excessive_wait_times
    # test 4-digit numbers
    assert_equal Report::MAXIMUM_WAIT_TIME,
      create_report("insanely long waits of 5000 minutes").wait_time

    # test numbers larger than the cap
    assert_equal Report::MAXIMUM_WAIT_TIME, 
      create_report("insanely long waits of #{Report::MAXIMUM_WAIT_TIME + 30} minutes").wait_time
  end
  
  def test_wait_tag_assignment
    minutes = [0,5,12,120]

    # #waitNUM is parsed
    minutes.each do |number|
      assert_equal number, create_report("no problems, #wait#{number}").wait_time
    end

    # wait:NUM is parsed
    minutes.each do |number|
      assert_equal number, create_report("no problems, wait:#{number}").wait_time
    end

    # #wait NUM is parsed
    minutes.each do |number|
      assert_equal number, create_report("no problems, #wait #{number}").wait_time
    end

    # NUM minutes is parsed
    minutes.each do |number|
      noun = (number == 1) ? "minute" : "minutes"
      assert_equal number, create_report("no problems, but a wait of #{number} #{noun}").wait_time
    end
    
    # #wait:NUM is parsed
    minutes.each do |number|
      assert_equal number, create_report("L:city hall san francisco ca #wait:#{number} #early #good No problems. Saw pollworkers help 2 disabled people.").wait_time
    end
    

    # NUM-minutes is parsed
    minutes.each do |number|
      noun = (number == 1) ? "minute" : "minutes"
      assert_equal number, create_report("no problems, but a #{number}-#{noun} wait. ouch").wait_time
    end
    
    # *wait NUM* is parsed
    minutes.each do |number|
      assert_equal number, create_report("in #11211 #votereport #good *wait #{number}* pass it on").wait_time
    end
    
    # NUM hour(s) is parsed
    [0,1,2].each do |number|
      noun = (number == 1) ? "hour" : "hours"
      assert_equal number * 60, 
        create_report("no problems, but a wait of #{number} #{noun}").wait_time
    end
    
    # NUM-hour(s) is parsed
    [0,1,2].each do |number|
      noun = (number == 1) ? "hour" : "hours"
      assert_equal number * 60, 
        create_report("no problems, but a #{number}-#{noun} wait. yikes!").wait_time
    end
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
    reports = Report.unassigned.assign(users(:quentin))
    assert_equal 10, reports.size
    reports.each do |r|
      assert_equal users(:quentin), r.reviewer
    end
    assert_equal reports.size, Report.assigned(users(:quentin)).size
  end
  
  def test_reviewed_arent_reassigned
    report = reports(:reports_022)
    report.confirm! # confirms without user_id
    report.reload
    assert report.is_confirmed?
    assert_not_nil report.reviewed_at
    assert !Report.unassigned.include?(report)

    report = reports(:reports_001)
    report.confirm!(users(:quentin))
    report.reload
    assert report.is_confirmed?
    assert_not_nil report.reviewed_at
    assert !Report.unassigned.include?(report)
  end
  
  
  def test_auto_review
    new_report = @twitter_reporter.reports.create(:text => 'i got #early #reg #challenges #wait:10 some tags 11222')
    new_report.reload # check that the value is actually saved to the model
    assert_not_nil new_report.reviewed_at
    assert !Report.unassigned.include?(new_report)
  end
  
  ##########################
  
  def create_report(text)
    @twitter_reporter.reports.create(:text => text)
  end
end
