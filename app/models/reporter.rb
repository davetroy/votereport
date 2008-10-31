class Reporter < ActiveRecord::Base
  has_many :reports, :dependent => :destroy
  belongs_to :location

  validates_presence_of :uniqueid
  validates_uniqueness_of :uniqueid, :scope => :type, :allow_blank => false
    
  cattr_accessor :public_fields
  @@public_fields = [:name]
 
  alias_method :ar_to_json, :to_json
  def to_json(options = {})
    options[:only] = @@public_fields
    # options[:include] = [ ]
    # options[:except] = [ ]
    options[:methods] = [ :icon ].concat(options[:methods]||[]) #lets us include current_items from feeds_controller#show
    options[:additional] = {:page => options[:page] }
    ar_to_json(options)
  end  

  # Takes a hash of reporter data
  # Adds to database if it's new to us, otherwise finds record and returns it
  def self.update_or_create(fields)
    fields = fields.delete_if { |k,v| !self.column_names.include?(k) }
    if reporter = self.find_by_uniqueid(fields['uniqueid'])
      reporter.update_attributes(fields)
    else
      reporter = self.create(fields)
    end
    reporter
  end
end
