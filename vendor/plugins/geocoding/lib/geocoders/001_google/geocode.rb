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
  
    # Hacks google local search to find stuff near latlon
    def self.reverse_geocode(latlon)
      begin
        tries = 0
        latlon.gsub!(/ /, '')
        url = "http://ajax.googleapis.com/ajax/services/search/local?v=1.0&q=a%7c1&near=#{latlon}"
        results = JSON.parse(open(url).read)['responseData']['results']
        results = results.map do |r|
          country_code = r['country']=='United States' ? 'US' : nil
          { :locality => r['city'], :administrative_area => r['region'], :country_code => country_code }
        end.uniq
        return nil if results.empty?
        loc = results.first
        point = latlon.split(',')
        loc.merge(:point => Point.from_x_y(point[1].to_f, point[0].to_f), :geo_source_id => 1)
      rescue => e
        logger.info "#{e.message}"
        tries += 1
        retry if tries<3
        loc = nil
      end
    end

  end

end
