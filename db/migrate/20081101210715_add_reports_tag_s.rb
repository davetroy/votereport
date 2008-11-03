class AddReportsTagS < ActiveRecord::Migration
  def self.up
    add_column :reports, :tag_s, :string
  end

  def self.down
    remove_column :reports, :tag_s
  end
end
