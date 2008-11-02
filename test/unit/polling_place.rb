require File.dirname(__FILE__) + '/../test_helper'

class PollingPlaceTest < ActiveSupport::TestCase
  def test_matching_by_name
    loc = Location.geocode('39.024,-76.511')
    place = PollingPlace.match_or_create('Arnold Elementary', loc)
    assert_equal polling_places(:arnoldelem), place
    loc = Location.geocode('Dallas')
    newplace = PollingPlace.match_or_create('Jones HS', loc)
    assert_equal "Jones HS", newplace.name
  end
end
