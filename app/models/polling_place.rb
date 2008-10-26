class PollingPlace < ActiveRecord::Base
  has_many :reports
  has_many :reporters, :through => :reports
  belongs_to :location
  
  # Attempts to match to a known polling place given
  # a name and a location
  def self.match_or_create(name, loc = nil)
    # First try to find by name match and distance
    place = self.find_by_name(name)
    return place if place && place.location.distance_to(loc) < 10
    
    # Then try to find by proximity (get id's within ~5 km)
    if nearby_locations = loc.find_within_box(5, :id)
      place = self.find(:first, :conditions => "location_id IN (#{nearby_locations.join(',')})" )
    end
    place
  end
end