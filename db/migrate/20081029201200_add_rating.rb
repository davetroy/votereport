class AddRating < ActiveRecord::Migration
  def self.up
    add_column :reports, :rating, :integer
    add_column :reports, :location_accuracy, :integer
    add_column :reporters, :location_accuracy, :integer
    
  end
  
  def self.down
    remove_column :reports, :rating
    remove_column :reports, :location_accuracy
  end
end