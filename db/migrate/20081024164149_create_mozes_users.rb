class CreateMozesUsers < ActiveRecord::Migration
  def self.up
    transaction do
      create_table :mozes_users do |t|
        t.integer :mozes_id, :null => false

        t.timestamps
      end
      add_index :mozes_users, :mozes_id
    end
  end

  def self.down
    drop_table :mozes_users
  end
end
