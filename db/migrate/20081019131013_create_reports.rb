class CreateReports < ActiveRecord::Migration

  def self.up
    create_table "reports" do |t|
      t.string   "source",         :limit => 3       # Short string to identify source; needed for uniqueid validation
      t.integer  "reporter_id"
      t.integer  "location_id"
      t.string   "uniqueid",       :limit => 20       # Unique identifier string for Twitter, SMS, Asterisk
      t.string   "text"                               # Text of the report from Twitter, SMS or otherwise
      t.integer  "score"                              # Overall "score" of this report (0=no problems)
      t.string   "zip",            :limit => 5        # Extracted zip associated with report
      t.integer  "wait_time"                          # Extracted wait time associated with report
      t.integer  "polling_place_id"                   # To attach to a polling place
      t.timestamps
    end

    add_index "reports", ["created_at"], :name => "index_reports_on_created_at"

    create_table "reporters" do |t|
      t.integer "location_id"
      t.string  "type", :limit => 30                  # TwitterReporter, IPhoneReporter, SmsReporter, PhoneReporter
      t.string  "uniqueid", :limit => 80
      t.string  "name", :limit => 80
      t.string  "screen_name", :limit => 80
      t.string  "profile_location", :limit => 80
      t.string  "profile_image_url", :limit => 200
      t.integer "followers_count"
      t.timestamps
    end

    add_index "reporters", ["uniqueid","type"], :name => "index_reports_on_uniqueid_and_type", :unique => true    
    
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
    
    create_table "report_filters", :options => 'ENGINE=MyISAM' do |t|
      t.integer "report_id"
      t.integer "filter_id"
    end

    add_index "report_filters", ["report_id"], :name => "index_report_filters_on_report_id"
    add_index "report_filters", ["filter_id"], :name => "index_report_filters_on_filter_id"

    create_table "polling_places" do |t|
      t.integer "location_id"
      t.string  "name", :limit => 80
      t.string  "address", :limit => 80
      t.string  "city", :limit => 80
      t.string  "state", :limit => 2
      t.string  "zip", :limit => 10
      t.timestamps
    end
  end

  def self.down
    drop_table :reports
    drop_table :reporters
    drop_table :report_tags
    drop_table :tags
    drop_table :report_filters
    drop_table :polling_places
  end
end
