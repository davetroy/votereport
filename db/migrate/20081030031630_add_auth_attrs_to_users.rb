class AddAuthAttrsToUsers < ActiveRecord::Migration
  def self.up
    # add columns for restful auth
    add_column :users, :crypted_password,           :string, :limit => 40
    add_column :users, :salt,                       :string, :limit => 40
    add_column :users, :remember_token,             :string, :limit => 40
    add_column :users, :remember_token_expires_at,  :datetime
    add_column :users, :activation_code,            :string, :limit => 40
    add_column :users, :activated_at,               :datetime

    # remove unused columns from previous data model
    remove_column :users, :password_hash

    add_index :users, :email, :unique => true
  end

  def self.down
    # remove restful auth columns
    remove_column :users, :crypted_password
    remove_column :users, :salt
    remove_column :users, :remember_token
    remove_column :users, :remember_token_expires_at
    remove_column :users, :activation_code
    remove_column :users, :activated_at
    
    # re-add old columns
    add_column :users, :password_hash, :string, :limit => 80
  end
end