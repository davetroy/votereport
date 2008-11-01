class AddUsersIsTerminated < ActiveRecord::Migration
  def self.up
    add_column :users, :is_terminated, :boolean, :default => false
  end

  def self.down
    remove_column :users, :is_terminated
  end
end
