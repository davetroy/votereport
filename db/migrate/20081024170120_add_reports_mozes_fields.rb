class AddReportsMozesFields < ActiveRecord::Migration
  def self.up
    transaction do
      add_column :reports, :mozes_user_id, :integer
      add_column :reports, :mozes_feed_id, :integer
      add_index :reports, :mozes_user_id
      add_index :reports, :mozes_feed_id
    end
  end

  def self.down
    remove_column :reports, :mozes_user_id
    remove_column :reports, :mozes_feed_id
  end
end
