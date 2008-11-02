class TwitterReporter < Reporter
  before_save :set_location

  def source; "TWT"; end
  def source_name; "Twitter"; end
  def icon; profile_image_url; end
  
  def profile
    "http://twitter.com/#{screen_name}"
  end

  private
  def set_location
    if location_id.nil? || (self.profile_location!=attributes['profile_location'])
      self.location = Location.geocode(attributes['profile_location'])
    end
  end  
end
