class CreateReviewerAlerts < ActiveRecord::Migration
  def self.up
    create_table :reviewer_alerts do |t|
      t.string :text
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :reviewer_alerts
  end
end
