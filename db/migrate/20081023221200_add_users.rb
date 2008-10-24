class AddUsers < ActiveRecord::Migration
  def self.up
    create_table :users, :options=>'ENGINE=MyISAM' do |t|
      t.string :first_name, :limit => 80
      t.string :last_name, :limit => 80
      t.string :url, :limit => 120
      t.string :api_key, :limit => 40
      t.string :password_hash, :limit => 40
      t.string :email, :limit => 80
      t.boolean :verified
      t.boolean :authorized
      t.integer :day_query_limit
      t.integer :day_update_limit
      t.integer :day_query_count, :default => 0
      t.integer :day_update_count, :default => 0
      t.integer :query_count, :default => 0
      t.integer :update_count, :default => 0
      t.datetime :last_query_at
      t.datetime :last_update_at
      t.timestamps
    end

    add_index "users", ["api_key"], :name => "index_users_on_api_key", :unique => true
    
  end

  def self.down
    drop_table :users
  end
end