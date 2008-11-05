class AddReportsIsChatter < ActiveRecord::Migration
  def self.up
    add_column :reports, :is_chatter, :boolean, :default => false
  end

  def self.down
    remove_column :reports, :is_chatter
  end
end
