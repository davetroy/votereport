# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20081029201200) do

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
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  create_table "invalid_locations", :options=>'ENGINE=MyISAM', :force => true do |t|
    t.column "text", :string, :limit => 80
    t.column "unknown", :boolean
  end

  add_index "invalid_locations", ["text"], :name => "index_invalid_locations_on_text", :unique => true

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
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  add_index "locations", ["point"], :name => "index_locations_on_point", :spatial=> true 

  create_table "polling_places", :force => true do |t|
    t.column "location_id", :integer
    t.column "name", :string, :limit => 80
    t.column "address", :string, :limit => 80
    t.column "city", :string, :limit => 80
    t.column "state", :string, :limit => 2
    t.column "zip", :string, :limit => 10
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  create_table "report_filters", :options=>'ENGINE=MyISAM', :force => true do |t|
    t.column "report_id", :integer
    t.column "filter_id", :integer
  end

  add_index "report_filters", ["report_id"], :name => "index_report_filters_on_report_id"
  add_index "report_filters", ["filter_id"], :name => "index_report_filters_on_filter_id"

  create_table "report_tags", :force => true do |t|
    t.column "report_id", :integer
    t.column "tag_id", :integer
  end

  add_index "report_tags", ["report_id"], :name => "index_report_tags_on_report_id"
  add_index "report_tags", ["tag_id"], :name => "index_report_tags_on_tag_id"

  create_table "reporters", :force => true do |t|
    t.column "location_id", :integer
    t.column "type", :string, :limit => 30
    t.column "uniqueid", :string, :limit => 80
    t.column "name", :string, :limit => 80
    t.column "screen_name", :string, :limit => 80
    t.column "profile_location", :string, :limit => 80
    t.column "profile_image_url", :string, :limit => 200
    t.column "followers_count", :integer
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
    t.column "location_accuracy", :integer
  end

  add_index "reporters", ["uniqueid", "type"], :name => "index_reports_on_uniqueid_and_type", :unique => true

  create_table "reports", :force => true do |t|
    t.column "source", :string, :limit => 3
    t.column "reporter_id", :integer
    t.column "location_id", :integer
    t.column "uniqueid", :string, :limit => 20
    t.column "text", :string
    t.column "score", :integer
    t.column "zip", :string, :limit => 5
    t.column "wait_time", :integer
    t.column "polling_place_id", :integer
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
    t.column "rating", :integer
    t.column "location_accuracy", :integer
  end

  add_index "reports", ["created_at"], :name => "index_reports_on_created_at"

  create_table "tags", :force => true do |t|
    t.column "pattern", :string, :limit => 30
    t.column "description", :string, :limit => 80
    t.column "score", :integer
  end

  create_table "users", :options=>'ENGINE=MyISAM', :force => true do |t|
    t.column "first_name", :string, :limit => 80
    t.column "last_name", :string, :limit => 80
    t.column "url", :string, :limit => 120
    t.column "api_key", :string, :limit => 40
    t.column "password_hash", :string, :limit => 40
    t.column "email", :string, :limit => 80
    t.column "verified", :boolean
    t.column "authorized", :boolean
    t.column "day_query_limit", :integer
    t.column "day_update_limit", :integer
    t.column "day_query_count", :integer, :default => 0
    t.column "day_update_count", :integer, :default => 0
    t.column "query_count", :integer, :default => 0
    t.column "update_count", :integer, :default => 0
    t.column "last_query_at", :datetime
    t.column "last_update_at", :datetime
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  add_index "users", ["api_key"], :name => "index_users_on_api_key", :unique => true

end
