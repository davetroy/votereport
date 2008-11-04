class AddCachedReportsCountToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :reports_count, :integer, :default => 0
    
    User.find(:all).each do |user|
      user.update_attribute(:reports_count, user.reviewed_reports.size)
    end
  end

  def self.down
    remove_column :users, :reports_count
  end
end
