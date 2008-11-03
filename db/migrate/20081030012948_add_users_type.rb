class AddUsersType < ActiveRecord::Migration
  def self.up
    transaction do
      add_column :users, :type, :string, :limit => 30
      add_index :users, :type
    end
  end

  def self.down
    remove_column :users, :type
  end
end
