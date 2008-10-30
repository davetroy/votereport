class AddReportReviewAttrs < ActiveRecord::Migration
  def self.up
    # assigned_at, reviewed_at, reviewer_id
    transaction do
      add_column :reports, :assigned_at, :datetime
      add_column :reports, :reviewed_at, :datetime
      add_column :reports, :reviewer_id, :integer
      add_index :reports, :reviewer_id
    end
  end

  def self.down
    remove_column :reports, :assigned_at
    remove_column :reports, :reviewed_at
    remove_column :reports, :reviewer_id
  end
end
