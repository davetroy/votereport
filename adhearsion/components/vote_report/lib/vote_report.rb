class VoteReport
  add_call_context :as => :call
    
  TAGS = %w(#good #machine #registration #challenges #hava #ballots #other)
  CALL_AUDIO_PATH = "/home/votereport/audio"
  TVR_AUDIO_PATH = "/home/votereport/current/adhearsion/tvr-audio"
  ZIP_AUDIO_PATH = "/home/votereport/zips"
  
  def initialize
  end
  
  def start
    reporter = PhoneReporter.update_or_create(:uniqueid => call.callerid || call.uniqueid, :profile_location => call.calleridname.capitalize_words)
    report = reporter.reports.new(:uniqueid => call.uniqueid)

    #play 'thank-you-for-calling-votereport'
    report.zip = enter_zip
    reporter.location = Location.geocode(report.zip)
    report.wait_time = enter_wait_time
    report.rating = enter_polling_location_rating
    report.text = get_problems
    record_audio_message
    report.has_audio = true
    
    play 'thank-you-for-calling-goodbye'
  rescue => e
    puts "#{e.message} #{e.backtrace.first}"
  ensure
    reporter.save
    report.save
  end

  def enter_zip
    confirm do
      zip = get_digits(5, 'enter-zipcode')
      play 'you-entered'
      call.say_digits zip
      call.play "#{ZIP_AUDIO_PATH}/#{zip}"
    end
    zip
  end
  
  def enter_wait_time
    confirm do
      wait_time = get_digits 3, "enter-your-wait-time-in-minutes-and-press-pound"
      play 'you-entered'
      call.say_number wait_time
    end
    wait_time
  end
  
  def enter_polling_location_rating
    rating = confine(1..9) { get_digits(1, "rate-your-polling-place") }
    (( (rating-1) / 8.0) * 100).to_i
  end
  
  def get_problems
    problem = confine(0..6) { get_digits(1, 'special-conditions') }
    TAGS[problem.to_i]
  end
  
  def record_audio_message
    play 'record-message'
    confirm do
      call.record("#{CALL_AUDIO_PATH}/#{call.uniqueid}.gsm", :beep => true)
      play "please-review-recording"
      call.play "#{CALL_AUDIO_PATH}/#{call.uniqueid}"
    end
  end
  
  # Helper functions
  def play(file)
    call.play "#{TVR_AUDIO_PATH}/#{file}"
  end
  
  def get_digits(num, file)
    begin
      digits = call.input(num, :play => "#{TVR_AUDIO_PATH}/#{file}")
    end until digits.length==num
    digits
  end

  def confine(limit_range=nil)
    value = nil
    begin
      value = yield.to_i
      play "please-try-again"
    end until limit_range===value
    value
  end
  
  def confirm
    begin
      yield
    	confirmed = call.input(1, :play => "#{TVR_AUDIO_PATH}/press-1-to-confirm")      
    end until confirmed == '1'
  end
end

