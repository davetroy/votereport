require File.dirname(__FILE__) + '/../test_helper'

class LocationAliasTest < ActiveSupport::TestCase
  fixtures :locations, :location_aliases
  
  def test_multiple_locations
    ids = ['New York', 'NY', 'NYC', 'NY, NY', 'New York City'].map { |l| LocationAlias.locate(l).id }
    ids.each { |id| assert_equal ids.first, id }
  end
end
