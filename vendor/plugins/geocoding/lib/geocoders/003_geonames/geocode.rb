module Geo
  class Geonames < Geocoder
  
    def self.geocode(text)
      if text =~ /([\-\d\.]+),\s*([\-\d\.]+)/
        url = "http://ws.geonames.org/findNearbyPlaceNameJSON?lat=#{$1}&lng=#{$2}&radius=5"
      else
        url = "http://ws.geonames.org/searchJSON?q=#{URI.encode(text)}"
      end
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

# create_table "locations", :options=>'ENGINE=MyISAM', :force => true do |t|
#   t.column "address", :string
#   t.column "country_code", :string, :limit => 10
#   t.column "administrative_area", :string, :limit => 80
#   t.column "sub_administrative_area", :string, :limit => 80
#   t.column "locality", :string, :limit => 80
#   t.column "dependent_locality", :string, :limit => 80
#   t.column "thoroughfare", :string, :limit => 80
#   t.column "postal_code", :string, :limit => 25
#   t.column "point", :point, :null => false
#   t.column "geo_source_id", :integer
#   t.column "created_at", :datetime
#   t.column "updated_at", :datetime
# end