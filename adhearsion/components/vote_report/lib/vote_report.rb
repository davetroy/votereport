class VoteReport
  add_call_context :as => :call
  
  def format_did(btn) btn.match(/^(\d{3})(\d{3})(\d{4})/).captures.join('-') end
    
  TAGS = %w(#good #machine #registration #challenges #hava #ballots #bad)
  CALL_AUDIO_PATH = "/home/votereport/audio"
  TVR_AUDIO_PATH = "/home/votereport/current/adhearsion/tvr-audio"
  ZIP_AUDIO_PATH = "/home/votereport/zips"
  MAX_TRIES = 3

  def initialize
    @reporter = PhoneReporter.update_or_create('uniqueid' => call.callerid || call.uniqueid, 'profile_location' => call.calleridname)
    @report = @reporter.reports.build(:uniqueid => call.uniqueid, :text => "Telephone report to #{format_did(call.dnid)} ")
  end
  
  def start
    play 'thank-you-for-calling-votereport'

    @report.zip = enter_zip
    @report.wait_time = enter_wait_time
    @report.rating = enter_polling_location_rating
    @report.text += get_problems
    record_audio_message
    @report.has_audio = true
    @reoport.save
    
    play 'thank-you-for-calling-goodbye'
  rescue => e
    puts "#{e.message} #{e.backtrace.first}"
  ensure
    @report.save
  end

  def enter_zip
    zip = nil
    confirm do
      zip = get_digits(5, 'enter-zipcode')
      play 'you-entered'
      call.say_digits zip
      call.play "#{ZIP_AUDIO_PATH}/#{zip}"
    end
    zip
  end
  
  def enter_wait_time
    wait_time = nil
    confirm do
      wait_time = get_digits(nil, "enter-waittime")
      play 'you-entered'
      call.play wait_time.to_i
      call.play 'minutes'
    end
    wait_time
  end
  
  def enter_polling_location_rating
    rating = nil
    confirm do
      rating = confine(1..9) { get_digits(1, "rate-your-polling-place") }.to_i
      play 'you-entered'
      call.say_digits rating
    end
    rating ? (( (rating-1) / 8.0) * 100).to_i : nil
  end
  
  def get_problems
    problem = nil
    confirm do
      problem = confine(0..6) { get_digits(1, 'special-conditions') }
      play 'you-entered'
      call.say_digits problem
    end
    TAGS[problem.to_i]
  end
  
  def record_audio_message
    play 'record-message'
    confirm do
      call.record("#{CALL_AUDIO_PATH}/#{call.uniqueid}.gsm # 60 BEEP s=5")
      play "please-review-recording"
      call.play "#{CALL_AUDIO_PATH}/#{call.uniqueid}"
    end
  end
  
  # Helper functions
  def play(file)
    call.play "#{TVR_AUDIO_PATH}/#{file}"
  end
  
  def get_digits(num, file)
    call.input(num, :play => "#{TVR_AUDIO_PATH}/#{file}")
  end

  def confine(limit_range=nil)
    value = nil
    tries = 1
    begin
      value = yield.to_i
      play "please-try-again" if !(limit_range===value)
      tries += 1
    end until limit_range===value || (tries>MAX_TRIES)
    value
  end
  
  def confirm
    tries = 1
    begin
      yield
    	confirmed = call.input(1, :play => "#{TVR_AUDIO_PATH}/press-1-to-confirm")      
      tries += 1
    end until confirmed == '1' || (tries>MAX_TRIES)
  end
end
