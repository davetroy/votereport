module Geo
  class Yahoo < Geocoder
  
    def self.geocode(text)

      # appid is for twittervotereport.com
      # street, city, state, zip, location
      params = { :appid => "7zB1A8vV34HtY3rO5riLV8pY_P.I6CvzsgjLF8uBJvfu70W8CMRaesjRadNDE9rImA--",
                 :output => 'xml',
                 :location => text }
                 
      pstring = params.map { |k,v| "#{k}=#{URI.encode(v)}" }.join('&')
      url = "http://api.local.yahoo.com/MapsService/V1/geocode?#{pstring}"
      loc = ExtractableHash.new.merge(Hash.from_xml(open(url).read))
      return nil unless loc.extract('ResultSet City')
      
      point = Point.from_x_y(loc.extract('ResultSet Result Longitude').to_f, loc.extract('ResultSet Result Latitude').to_f)
      loc = loc.transform( :thoroughfare => 'ResultSet Result Address',
        :country_code => 'ResultSet Result Country',
        :administrative_area => 'ResultSet Result State',
        :locality => 'ResultSet Result City',
        :postal_code => 'ResultSet Result Zip')
      loc[:address] = "#{loc[:thoroughfare]}, #{loc[:locality]}, #{loc[:postal_code]} #{loc[:country_code]}"
      loc.merge(:point => point, :geo_source_id => 2)
      
    rescue
      nil
    end

  end
end
