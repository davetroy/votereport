module Geo
  class Google < Geocoder
  
    def self.geocode(text)
      url = "http://maps.google.com/maps/geo?q=#{URI.encode(text)}&key=#{GMAPS_API_KEY}&output=kml"
      loc = ExtractableHash.new.merge(Hash.from_xml(open(url).read)['kml']['Response'])
      return nil unless loc.extract('Status') && loc.extract('Status code').to_i == 200
      point = loc.extract('Placemark Point coordinates').split(',')
      point = Point.from_x_y(point[0].to_f, point[1].to_f)
      loc = loc.transform( :address => 'Placemark address',
        :country_code => 'Placemark AddressDetails Country CountryNameCode',
        :administrative_area => 'Placemark AddressDetails Country AdministrativeArea AdministrativeAreaName',
        :sub_administrative_area => 'Placemark AddressDetails Country AdministrativeArea SubAdministrativeArea SubAdministrativeAreaName',
        :locality => 'Placemark AddressDetails Country AdministrativeArea Locality LocalityName',
        :thoroughfare => 'Placemark AddressDetails Country AdministrativeArea Locality Thoroughfare ThoroughfareName',
        :postal_code => 'Placemark AddressDetails Country AdministrativeArea Locality PostalCode PostalCodeNumber' )
      loc[:locality] = loc[:sub_administrative_area] unless loc[:locality]
      loc.merge(:point => point, :geo_source_id => 1)
    rescue
      nil
    end
  end
end

# name: 2551 Riva Rd, Annapolis, MD
# Status: 
#   code: "200"
#   request: geocode
# Placemark: 
#   AddressDetails: 
#     Country: 
#       AdministrativeArea: 
#         Locality: 
#           LocalityName: Annapolis
#           Thoroughfare: 
#             ThoroughfareName: 2551 Riva Rd
#           PostalCode: 
#             PostalCodeNumber: "21401"
#         AdministrativeAreaName: MD
#       CountryNameCode: US
#     Accuracy: "8"
#   id: p1
#   Point: 
#     coordinates: -76.550921,38.977724,0
#   address: 2551 Riva Rd, Annapolis, MD 21401, USA

#{"AddressDetails"=>{"Country"=>{"AdministrativeArea"=>{"SubAdministrativeArea"=>{"Locality"=>{"LocalityName"=>"Arnold", "Thoroughfare"=>{"ThoroughfareName"=>"1424 Ridgeway E"}, 
# "PostalCode"=>{"PostalCodeNumber"=>"21012"}}, "SubAdministrativeAreaName"=>"Anne Arundel"}, "AdministrativeAreaName"=>"MD"}, "CountryNameCode"=>"US"}, 
# "Accuracy"=>"8", "xmlns"=>"urn:oasis:names:tc:ciq:xsdschema:xAL:2.0"}, "id"=>"p1", "Point"=>{"coordinates"=>"-76.511004,39.024739,0"}, "address"=>"1424 Ridgeway E, Arnold, MD 21012, USA"}


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

#http://maps.google.com/maps/geo?q=Munich&key=ABQIAAAAzMUFFnT9uH0xq39J0Y4kbhTJQa0g3IQ9GZqIMmInSLzwtGDKaBR6j135zrztfTGVOm2QlWnkaidDIQ&output=json