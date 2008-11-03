class CreateStatistics < ActiveRecord::Migration
  def self.up
    create_table :statistics, :options=>'ENGINE=MyISAM' do |t|
      t.string      :name
      t.datetime    :created_at
      t.integer     :sort, :default => 0
      t.string      :string_value
      t.integer     :integer_value
      t.decimal     :decimal_value
    end
  end

  def self.down
    drop_table :statistics
  end
end
