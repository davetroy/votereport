require 'rubygems'
require 'json'
require 'geo_ruby'
require 'test/unit'
require 'active_support'
require "#{File.dirname(__FILE__)}/../init"

include GeoRuby::SimpleFeatures

# localhost API key
GMAPS_API_KEY = "ABQIAAAAzMUFFnT9uH0xq39J0Y4kbhTJQa0g3IQ9GZqIMmInSLzwtGDKaBR6j135zrztfTGVOm2QlWnkaidDIQ"

class GeocoderTest < Test::Unit::TestCase
  
  def test_geocoding
    l = Geo::Geocoder.geocode('21012')
    assert_equal 'MD', l[:administrative_area]
    assert_equal 39, l[:point].y.to_i
    assert_equal -76, l[:point].x.to_i
  end
  
  def test_google_geocoder
    l = Geo::Google.geocode('2551 Riva Rd, Annapolis, MD')
    assert_equal 'US', l[:country_code]
    assert_equal 'MD', l[:administrative_area]
    assert_equal 'Annapolis', l[:locality]
    assert_equal '2551 Riva Rd', l[:thoroughfare]
    assert_equal '21401', l[:postal_code]
    assert_equal Point.from_x_y(-76.550921, 38.977724), l[:point]
    assert_equal 1, l[:geo_source_id]
    assert l[:address]
  end
  
  def test_yahoo_geocoder
    l = Geo::Yahoo.geocode('2551 Riva Rd, Annapolis, MD')
    assert_equal 'US', l[:country_code]
    assert_equal 'MD', l[:administrative_area]
    assert_equal 'Annapolis', l[:locality]
    assert_equal '2551 Riva Rd', l[:thoroughfare]
    assert_equal '21401-7435', l[:postal_code]
    assert_equal Point.from_x_y(-76.550744, 38.977869), l[:point]
    assert_equal 2, l[:geo_source_id]
    assert l[:address]
  end

  def test_geonames_geocoder
    l = Geo::Geonames.geocode('Annapolis, Maryland')
    assert_equal 'US', l[:country_code]
    assert_equal 'MD', l[:administrative_area]
    assert_equal 'Annapolis', l[:locality]
    assert_equal Point.from_x_y(-76.4921829, 38.9784453), l[:point]
    assert_equal 3, l[:geo_source_id]
    assert l[:address]
  end
  
  def test_all_available_geocoders
    Geo::Geocoder.send(:subclasses).each do |subclass|
      prague, london, huntsville = ['Praha', 'London', 'Huntsville'].map { |l| subclass.geocode(l) }
      assert_equal 'CZ', prague[:country_code] if prague
      assert_equal 'GB', london[:country_code] if london
      assert_equal 'US', huntsville[:country_code] if huntsville
    end
  end
  
  def test_detailed_street_addresses
		['10114 Boxing Pass, San Antonio, TX 78251', '307 Knights Cross, San Antonio, TX 78258'].each do |l|
			loc = Geo::Geocoder.geocode(l)
			p loc
			assert_equal 'TX', loc[:administrative_area]
		end
		
		loc = Geo::Geocoder.geocode('2551 Riva Rd, Annapolis MD')
    assert_equal '21401', loc[:postal_code]
	end
	
	def test_invalid_location
    l = Geo::Geocoder.geocode('Your ass, blogosphere')
    assert_nil(l)
  end
  
  def test_unicode_characters
    loc = Geo::Google.geocode('Munich, Germany')
    assert_equal 'Munich', loc[:locality]
  end
  
  def test_reverse_geocoding
    loc = Geo::Geocoder.geocode('39.024,-76.511')
    assert_equal ['Arnold', 'MD', 'US'], [loc[:locality], loc[:administrative_area], loc[:country_code]]
    loc = Geo::Geocoder.geocode('37.332,-122.031')
    assert_equal ['Cupertino', 'CA', 'US'], [loc[:locality], loc[:administrative_area], loc[:country_code]]
  end
  
end