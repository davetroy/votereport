require 'georuby_json'
class Location < ActiveRecord::Base
  has_many :aliases, :class_name => 'LocationAlias'
  before_validation :review_address
  after_create :set_filters
  validates_presence_of :address
  has_many :reports
  #validate that point really does not exist on create; we are already sort of doing this

  def self.geocode(location_text)
    return nil if location_text.blank?
    Timeout.timeout(20) { LocationAlias.locate(location_text) }
  rescue Timeout::Error => e
    return nil
  end
    
  def latitude
    point.y.to_f
  end

  def longitude
    point.x.to_f
  end
  
  def latlon
    "#{point.y}, #{point.x}"
  end
  
  # find locations within a distance in kilometers
  # return just one property of location if specified
  def find_within_radius(distance, property=nil)
    locations = find_within_box(distance).delete_if { |l| self.distance_to(l) > distance }
		property ? locations.map(&property.to_sym) : locations
  end

  # make a box of distance*2 km square centered on the location
  # and find locations within that box
  def find_within_box(distance, property=nil)
    degrees = (distance/111.0)
    locations = Location.find_all_by_point(self.box_around(degrees))
		property ? locations.map(&property.to_sym) : locations
  end

  # See if a location is within radius distance from center
  def within_radius_of?(center, radius)
    return false unless center
    (self.point == center.point) || (center.distance_to(self) <= radius)
  end

  # find the distance from self to another location
  # distance is in km and based on the WGS84 ellipsoid
  def distance_to(loc2)
    self.point.ellipsoidal_distance(loc2.point)/1000
  end

  # return a bounding box (in degrees) around a given point
  def box_around(degrees=1)
    x1 = self.longitude - degrees
    x1 = x1 < -180 ? x1 + 180 : x1
    y1 = self.latitude + degrees
    y1 = y1 > 90 ? 90 : y1
    x2 = self.longitude + degrees
    x2 = x2 > 180 ? x2 - 180 : x2
    y2 = self.latitude - degrees
    y2 = y2 < -90 ? -90 : y2

    Envelope.from_coordinates([[x1, y1], [x2, y2]])
  end
  
  private
  def review_address
    self.address = [locality, sub_administrative_area, administrative_area, country_code].compact.join(', ') if self.address.blank?
    self.address.gsub!(/^[\s,]+/,'')
    self.address = [administrative_area, country_code].compact.join(', ') if self.address.length==1
    return true
  end
  
  def set_filters
    self.filter_list = Filter.get_list_for_location(self)
  end
end
