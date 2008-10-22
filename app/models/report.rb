class Report < ActiveRecord::Base
  validates_uniqueness_of :tid
  belongs_to :location
  belongs_to :twitter_user
  
  before_save :detect_location

  private
  def detect_location
    LOCATION_PATTERNS.find { |p| self.text =~ p }
    self.location = Location.geocode($1) if $1
    self.zip = location.postal_code if location && location.postal_code
    self.location = twitter_user.location if !self.location && twitter_user && twitter_user.location
  end

end
