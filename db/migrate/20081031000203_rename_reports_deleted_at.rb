class RenameReportsDeletedAt < ActiveRecord::Migration
  def self.up
    rename_column :reports, :deleted_at, :dismissed_at
  end

  def self.down
    rename_column :reports, :dismissed_at, :deleted_at
  end
end
