module ReportHelper

  # Use natural language scan to suggest intended location names
  # Here are some test cases to use against this method
  def suggest_location(text)
    # Use NL_LOCATION_PATTERNS for this (see config/initializers/votereport.rb)
    # assert_equal "Boulder, CO, USA", @twitter_reporter.reports.create(:text => 'taking forever in Boulder CO').location.address
    # assert_equal "Boulder, CO, USA", @twitter_reporter.reports.create(:text => 'long lines in courthouse at Boulder, CO').location.address
    # false positive matches - these cases need addressed:
    # assert_equal "Los Angeles, CA, USA", @twitter_reporter.reports.create(:text => 'waited at the poll for 1hr in LA, now in a bad mood').location.address
    # assert_equal "Annapolis, MD, USA", @twitter_reporter.reports.create(:text => 'all day in Annapolis at the school they told me I could not vote here').location.address
    # assert_equal "San Francisco, CA, USA", @twitter_reporter.reports.create(:text => 'waiting in San Francisco at the poll in line forever').location.address
  end

end