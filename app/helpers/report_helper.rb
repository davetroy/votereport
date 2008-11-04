module ReportHelper

      US_STATES = [ 	
	['Select a State', 'None'],
	['Alabama', 'AL'], 
	['Alaska', 'AK'],
	['Arizona', 'AZ'],
	['Arkansas', 'AR'], 
	['California', 'CA'], 
	['Colorado', 'CO'], 
	['Connecticut', 'CT'], 
	['Delaware', 'DE'], 
	['District Of Columbia', 'DC'], 
	['Florida', 'FL'],
	['Georgia', 'GA'],
	['Hawaii', 'HI'], 
	['Idaho', 'ID'], 
	['Illinois', 'IL'], 
	['Indiana', 'IN'], 
	['Iowa', 'IA'], 
	['Kansas', 'KS'], 
	['Kentucky', 'KY'], 
	['Louisiana', 'LA'], 
	['Maine', 'ME'], 
	['Maryland', 'MD'], 
	['Massachusetts', 'MA'], 
	['Michigan', 'MI'], 
	['Minnesota', 'MN'],
	['Mississippi', 'MS'], 
	['Missouri', 'MO'], 
	['Montana', 'MT'], 
	['Nebraska', 'NE'], 
	['Nevada', 'NV'], 
	['New Hampshire', 'NH'], 
	['New Jersey', 'NJ'], 
	['New Mexico', 'NM'], 
	['New York', 'NY'], 
	['North Carolina', 'NC'], 
	['North Dakota', 'ND'], 
	['Ohio', 'OH'], 
	['Oklahoma', 'OK'], 
	['Oregon', 'OR'], 
	['Pennsylvania', 'PA'], 
	['Rhode Island', 'RI'], 
	['South Carolina', 'SC'], 
	['South Dakota', 'SD'], 
	['Tennessee', 'TN'], 
	['Texas', 'TX'], 
	['Utah', 'UT'], 
	['Vermont', 'VT'], 
	['Virginia', 'VA'], 
	['Washington', 'WA'], 
	['West Virginia', 'WV'], 
	['Wisconsin', 'WI'], 
	['Wyoming', 'WY']]
        
  # TODO: DCT - commented this out because object cannot be found; need a gem or a lib?
  #include BumpsparkHelper 

  def state_select(current = "")
    select(:filter, :state, US_STATES)
  end
  
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
  
  def audio_link(report)
    "<embed src='#{report.reporter.audio_path}/#{report.audio_file}' width='100' height='20' AUTOPLAY='false'/>" if report.has_audio
  end

  def rating_icon(rating)
    if(rating.nil?)
      rating_icon = "rating_none.png"
    elsif(rating <= 30)
      rating_icon = "rating_bad.png"
    elsif (rating <= 70)
      rating_icon = "rating_medium.png"
    else
      rating_icon = "rating_good.png"
    end    
    "http://votereport.us/images/#{rating_icon}"
  end
  
  def bumpspark2( results )
     white, red, grey = 0, 16, 32
     padding = 3 - ( results.length - 1 ) % 4
     ibmp = results.inject([]) do |ary, r|
         ary << [white]*15
         ary.last[r/9,4] = [(r > 50 and red or grey)]*4
         ary
     end.transpose.map do |px|
         px.pack("C#{px.length}x#{padding}")
     end.join
     ["BM", ibmp.length + 66, 0, 0, 66, 40,
       results.length * 2, 15, 1, 4, 0, 0, 0, 0, 3, 0,
       0xFFFFFF, 0xFF0000, 0x999999 ].
       pack("A2Vv2V4v2V9") + ibmp
  end
 
  def display(val, default='Undefined')
    (val.blank?) ? default : val.to_s.strip
  end
end