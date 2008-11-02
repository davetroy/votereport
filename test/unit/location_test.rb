require File.dirname(__FILE__) + '/../test_helper'

class LocationTest < ActiveSupport::TestCase
  fixtures :locations, :location_aliases, :filters
  
  def setup
    @l = {  :dc => 'Washington, DC',
            :ny => 'New York',
            :balt => 'Baltimore',
            :paris => 'Paris',
            :annapolis => 'Annapolis, MD' }
    @l.each { |k, v| @l[k] = Location.geocode(v) }
  end
  
  def test_distance_measurement
    assert_equal 22, @l[:annapolis].distance_to(@l[:balt]).to_miles.to_i  # 22 mi Annap to Balt
    assert_equal 35, @l[:dc].distance_to(@l[:balt]).to_miles.to_i         # 35 mi DC to Balt
    assert_in_delta 172.42.to_km, @l[:ny].distance_to(@l[:balt]), 1.0     # 172.42 mi NY to Balt
    assert_in_delta 6125, @l[:balt].distance_to(@l[:paris]), 1.0          # 6116 km Balt to Paris
    assert_equal 206, @l[:dc].distance_to(@l[:ny]).to_miles.to_i          # 206 mi DC to NY
    assert_equal 206, @l[:ny].distance_to(@l[:dc]).to_miles.to_i          # 206 mi NY to DC
  end
  
  def test_find_within_radius
    places = @l[:annapolis].find_within_radius(40)
    assert_equal 3, places.size
    assert places.include?(@l[:annapolis])
  end
  
  def test_find_within_box
    places = @l[:annapolis].find_within_box(80)
    assert_equal 4, places.size
    assert_equal 3, (places & [@l[:annapolis], @l[:balt], @l[:dc]]).size
  end
  
  def test_bounding_box
    assert @l[:dc].box_around.is_a?(GeoRuby::SimpleFeatures::Envelope)  # Be sure we can create a valid bounding box
    assert @l[:ny].box_around.as_kml                                    # Be sure we can express as KML
  end

end
