class VoteReport
  add_call_context :as => :call

  def initialize
    @zip = nil
    @report_type_id = nil
  end
  
  def start
    report = Report.new :reporterid => call.callerid, :uniqueid => call.uniqueid
    
    collect_zip
    report.zip = @zip
    
    get_report_type
    report.report_type_id = @report_type_id
    
    record_audio_message?
    
    # TODO: Add wait_time column
    enter_wait_time
    report.wait_time = @wait_time
    
    # TODO: Add polling_location_rating column
    enter_polling_location_rating
    report.rating = @rating
    
    call.play 'thank-you', 'vm-goodbye'
  ensure
    report.save
  end
  
  def enter_wait_time
    @wait_time = get_digits 3, "enter-your-wait-time-in-minutes-and-press-pound"
    # Do any input verification?
  end
  
  def enter_polling_location_rating
    @rating = get_digits 1, "enter-your-wait-time-in-minutes-and-press-pound"
    @rating == "0" ? enter_polling_location_rating : @rating
  end
  
  def record_audio_message?
    record_audio = get_digits(1, 'press-1-to-record-an-audio-message')
    if (record_audio=='1')
      call.record("#{call.uniqueid}.gsm", :beep => true)
    end
  end
  
  def get_report_type
    confirm do
      @report_type_id = get_digits(1, 'please-select-report-type')
      call.play %W(you-entered #{@report_type_id})
    end
  end
  
  def get_digits(num, file)
    begin
      digits = call.input(num, :play => file)
    end until digits.length==num
    digits
  end

  def collect_zip
    confirm do
      @zip = get_digits(5, 'welcome-please-enter-zipcode')
      call.play 'you-entered'
      call.say_digits @zip
      call.play "zips/#{@zip}"
    end
  end
  
  def confirm
    begin
      yield
    	confirmed = call.input(1, :play => 'press-1-to-confirm')      
    end until confirmed == '1'
  end
end

# 1 vote suppression or interference
# 2 excessive delays
# 3 disorderly operations
