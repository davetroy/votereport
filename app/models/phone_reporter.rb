class PhoneReporter < Reporter
  before_save :set_location

  def source; "TEL"; end
  def source_name; "Telephone"; end
  def icon; "/images/phone_icon.jpg"; end
  def audio_path; "http://calls.votereport.us/audio"; end
  
  private
  def set_location
    if location_id.nil? || (self.profile_location!=attributes['profile_location'])
      self.location = Location.geocode(attributes['profile_location'])
    end
  end
end
