class CreateReports < ActiveRecord::Migration

  def self.up
    create_table "reports" do |t|
      t.integer  "input_source_id"                    # 1 = twitter, 2 = sms, 3 = iPhone, 4 = asterisk
      t.integer  "location_id"
      t.integer  "twitter_user_id"
      t.string   "text"                               # Text of the report from Twitter, SMS or otherwise
      t.integer  "score"                              # Overall "score" of this report (0=no problems)
      t.string   "callerid",       :limit => 20       # Telephone Caller ID or Mozes Unique User ID
      t.string   "uniqueid",       :limit => 20       # Unique identifier for Twitter, SMS, Asterisk
      t.string   "zip",            :limit => 5        # Extracted zip associated with report
      t.integer  "wait_time"                          # Extracted wait time associated with report
      t.timestamps
    end

    add_index "reports", ["uniqueid","input_source_id"], :name => "index_reports_on_uniqueid_and_input_source_id", :unique => true

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
    drop_table :report_filters
  end
end
