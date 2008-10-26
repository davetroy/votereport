class Reporter < ActiveRecord::Base
  has_many :reports, :dependent => :destroy
  belongs_to :location

  validates_presence_of :uniqueid
  validates_uniqueness_of :uniqueid, :scope => :type, :allow_blank => false
  
  # Takes a hash of reporter data
  # Adds to database if it's new to us, otherwise finds record and returns it
  def self.update_or_create(fields)
    fields = fields.delete_if { |k,v| !self.column_names.include?(k) }
    if reporter = find_by_uniqueid(fields['uniqueid'])
      reporter.update_attributes(fields)
    else
      reporter = create(fields)
    end
    reporter
  end
end
