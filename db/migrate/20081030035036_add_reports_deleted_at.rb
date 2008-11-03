class AddReportsDeletedAt < ActiveRecord::Migration
  def self.up
    add_column :reports, :deleted_at, :datetime
  end

  def self.down
    remove_column :reports, :deleted_at
  end
end
