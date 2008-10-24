class CreateReports < ActiveRecord::Migration

  class Filter < ActiveRecord::Base; end

  def self.up
    create_table "reports" do |t|
      t.integer  "input_source_id"                    # 1 = twitter, 2 = sms, 3 = iPhone, 4 = asterisk
      t.integer  "location_id"
      t.integer  "twitter_user_id"
      t.integer  "tid"                                # Twitter internal ID
      t.string   "text"                               # Text of the report from Twitter, SMS or otherwise
      t.integer  "score"                              # Overall "score" of this report (0=no problems)
      t.string   "callerid",       :limit => 20       # Telephone Caller ID or Mozes Unique User ID
      t.string   "uniqueid",       :limit => 20       # Unique call identifier for Asterisk
      t.string   "zip",            :limit => 5        # Extracted zip associated with report
      t.integer  "wait_time"                          # Extracted wait time associated with report
      t.timestamps
    end

    add_index "reports", ["tid"], :name => "index_reports_on_tid", :unique => true

    create_table "twitter_users" do |t|
      t.integer "tid"                                 # Twitter internal ID
      t.string  "name", :limit => 80
      t.string  "screen_name", :limit => 80
      t.string  "profile_location", :limit => 80
      t.string  "profile_image_url", :limit => 200
      t.integer "followers_count"
      t.integer "location_id"
      t.timestamps
    end
    
    add_index "twitter_users", ["tid"], :name => "index_twitter_users_on_tid", :unique => true
    
    create_table "report_tags" do |t|
      t.integer "report_id"
      t.integer "tag_id"
    end
    
    add_index "report_tags", ["report_id"], :name => "index_report_tags_on_report_id"
    add_index "report_tags", ["tag_id"], :name => "index_report_tags_on_tag_id"

    create_table "tags" do |t|
      t.string "pattern", :limit => 30
      t.string "description", :limit => 80
      t.integer "score"
    end
    
    
    # Location-related tables
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
    Filter.find(:all).each { |f| f.update_attribute(:center_location_id, Location.geocode(f.title).id) }

    create_table "invalid_locations", :options=>'ENGINE=MyISAM', :force => true do |t|
      t.column "text", :string, :limit => 80
      t.column "unknown", :boolean
    end

    add_index "invalid_locations", ["text"], :name => "index_invalid_locations_on_text", :unique => true

    create_table "report_filters", :options => 'ENGINE=MyISAM' do |t|
      t.column "report_id",   :integer
      t.column "filter_id",   :integer
    end

    add_index "report_filters", ["report_id"], :name => "index_report_filters_on_report_id"
    add_index "report_filters", ["filter_id"], :name => "index_report_filters_on_filter_id"

  end

  def self.down
    drop_table :reports
    drop_table :twitter_users
    drop_table :report_tags
    drop_table :tags
    drop_table :location_aliases
    drop_table :locations
    drop_table :filters
    drop_table :report_filters
    drop_table :invalid_locations
  end
end
