class CreateAlertViewings < ActiveRecord::Migration
  def self.up
    create_table :alert_viewings do |t|
      t.integer :user_id
      t.integer :reviewer_alert_id
      t.timestamps
    end
    
    add_index :alert_viewings, :user_id
  end

  def self.down
    drop_table :alert_viewings
  end
end
