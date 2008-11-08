class AddPollingPlaceName < ActiveRecord::Migration
  def self.up
    add_column :reports, :polling_place_name, :string
  end

  def self.down
    remove_column :reports, :polling_place_name
  end
end
