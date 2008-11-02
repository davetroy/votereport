class AddReviewerAlertIdIndexToAlertViewings < ActiveRecord::Migration
  def self.up
    add_index :alert_viewings, :reviewer_alert_id
  end

  def self.down
    remove_index :alert_viewings, :reviewer_alert_id
  end
end
