class SetupLocations < ActiveRecord::Migration
  class Filter < ActiveRecord::Base; end

  def self.up
    create_table "location_aliases", :options=>'ENGINE=MyISAM', :force => true do |t|
      t.column "text", :string, :limit => 80
      t.column "location_id", :integer
    end

    add_index "location_aliases", ["text"], :name => "index_location_aliases_on_text", :unique => true
    add_index "location_aliases", ["location_id"], :name => "index_location_aliases_on_location_id"

    create_table "locations", :options=>'ENGINE=MyISAM', :force => true do |t|
      t.column "address", :string
      t.column "country_code", :string, :limit => 10
      t.column "administrative_area", :string, :limit => 80
      t.column "sub_administrative_area", :string, :limit => 80
      t.column "locality", :string, :limit => 80
      t.column "thoroughfare", :string, :limit => 80
      t.column "postal_code", :string, :limit => 25
      t.column "point", :point, :null => false
      t.column "geo_source_id", :integer
      t.column "filter_list", :string
      t.timestamps
    end

    add_index "locations", ["point"], :name => "index_locations_on_point", :spatial=> true

    create_table "filters", :options=>'ENGINE=MyISAM', :force => true do |t|
      t.column "name", :string, :limit => 80
      t.column "aliases", :string
      t.column "title", :string, :limit => 80
      t.column "center_location_id", :integer
      t.column "radius", :integer
      t.column "conditions", :text
      t.column "zoom_level", :integer
      t.column "state", :string, :limit => 2
      t.column "country_code", :string, :limit => 2
      t.timestamps
    end

    # Import filter set and reset centers; this is touchy, beware!
    Filter.connection.execute(File.read(File.dirname(__FILE__) + '/../filters.sql'))
    Filter.connection.execute(File.read(File.dirname(__FILE__) + '/../locations.sql'))
    #Filter.find(:all).each { |f| f.update_attribute(:center_location_id, Location.geocode(f.title).id) }

    create_table "invalid_locations", :options=>'ENGINE=MyISAM', :force => true do |t|
      t.column "text", :string, :limit => 80
      t.column "unknown", :boolean
    end

    add_index "invalid_locations", ["text"], :name => "index_invalid_locations_on_text", :unique => true
  end

  def self.down
    drop_table :location_aliases
    drop_table :locations
    drop_table :filters
    drop_table :invalid_locations
  end  
end
