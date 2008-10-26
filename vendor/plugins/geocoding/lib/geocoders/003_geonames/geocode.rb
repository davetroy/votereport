module Geo
  class Geonames < Geocoder
  
    def self.geocode(text)
      grab_data("http://ws.geonames.org/searchJSON?q=#{URI.encode(text)}")
    end

    def self.reverse_geocode(latlon)
      latlon[/([\-\d\.]+),\s*([\-\d\.]+)/]
      grab_data("http://ws.geonames.org/findNearbyPlaceNameJSON?lat=#{$1}&lng=#{$2}&radius=5")
    end
    
    private
    def self.grab_data(url)
      loc = ExtractableHash.new.merge(JSON.parse(open("#{url}&maxRows=10").read)['geonames'].first)
      point = Point.from_x_y(loc['lng'], loc['lat'])
      loc = loc.transform(:locality => 'name',
                          :country_code => 'countryCode',
                          :administrative_area => 'adminCode1')
      loc[:address] = "#{loc[:locality]}, #{loc[:administrative_area]}, #{loc[:country_code]}"
      loc.merge(:point => point, :geo_source_id => 3)
    rescue
      nil
    end
  end
end
