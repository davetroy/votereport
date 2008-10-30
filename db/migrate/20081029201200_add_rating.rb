class AddRating < ActiveRecord::Migration
  # Misc fields needed in reports for iPhone and Voice
  def self.up
    add_column :reports, :rating, :integer
    add_column :reports, :location_accuracy, :integer
    add_column :reports, :has_audio, :boolean
  end
  
  def self.down
    remove_column :reports, :rating
    remove_column :reports, :location_accuracy
    remove_column :reports, :has_audio
  end
end