class PhoneReporter < Reporter
  def source; "TEL"; end
  def source_name; "Telephone"; end
  def icon; "/images/voice_icon.png"; end
  
  private
  def detect_location
  end
end
