class LocationAlias < ActiveRecord::Base
  
  belongs_to :location
  
  def self.locate(location_text)
    location_alias = LocationAlias.find_by_text(location_text)
    return location_alias.location if location_alias
    unless loc = Geo::Geocoder.geocode(location_text)
      InvalidLocation.create(:text => location_text) rescue nil
      return nil
    end
    db_location = Location.find_by_point(loc[:point]) || Location.create(loc)
    create(:text => location_text, :location_id => db_location.id)
    db_location
  end
  
end
