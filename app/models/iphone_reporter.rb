class IphoneReporter < Reporter
  before_create :set_location

  attr_accessor(:latlon)
  self.column_names << 'latlon'
    
  def source; "IPH"; end
  def source_name; "VoteReport iPhone App"; end
  def icon; "/images/iphone_icon.png"; end
  
  private
  def set_location
    logger.info "*** geocoding #{self.latlon}"
    if self.location = Location.geocode(self.latlon)
      self.profile_location = self.location.address if self.profile_location.nil?
    end
  end
end
