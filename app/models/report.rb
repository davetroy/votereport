class Report < ActiveRecord::Base
  
  validates_presence_of :reporter_id
  validates_uniqueness_of :uniqueid, :scope => :source, :allow_blank => true, :message => 'already processed'
  
  validates_inclusion_of :rating, :in => ("1".."9").to_a + (1..9).to_a, :allow_nil => true
  validates_numericality_of :wait_time, :allow_nil => true
  
  attr_accessor :latlon, :tag_string   # virtual field supplied by iphone/android
  
  belongs_to :location
  belongs_to :reporter
  belongs_to :polling_place
  
  has_many :report_tags, :dependent => :destroy
  has_many :tags, :through => :report_tags
  has_many :report_filters, :dependent => :destroy
  has_many :filters, :through => :report_filters

  before_validation :set_source
  before_create :detect_location, :append_tags
  after_save :check_uniqueid
  after_create :assign_tags, :assign_filters
  
  named_scope :with_location, :conditions => 'location_id IS NOT NULL'
  named_scope :with_wait_time, :conditions => 'wait_time IS NOT NULL'

  cattr_accessor :public_fields
  @@public_fields = [:id,:source,:text,:score,:zip,:wait_time,:created_at,:updated_at]

  def name
    self.reporter.name
  end
  
  # DCT - pls document this
  alias_method :ar_to_json, :to_json
  def to_json(options = {})
    options[:only] = @@public_fields
    # options[:include] = [ :reporter, :polling_place ]
    # options[:except] = [ ]
    options[:methods] = [ :reporter, :polling_place, :location ].concat(options[:methods]||[]) #lets us include current_items from feeds_controller#show
    # options[:additional] = {:page => options[:page] }
    ar_to_json(options)
  end    

    
  def self.find_with_filters(filters = {})
    conditions = ["",filters]
    if filters.include?(:dtstart)
      conditions[0] << "created_at >= :dtstart"
    end
    if filters.include?(:dtend)
      conditions[0] << "created_at <= :dtend"
    end

    # TODO put in logic here for doing filtering by appropriate parameters
    Report.paginate( :page => filters[:page] || 1, :per_page => filters[per_page] || 10, 
                      :order => 'created_at DESC',
                      :conditions => conditions)
  end
  
  def field_text
    [wait_time     ? "#{wait_time} minute wait time" : nil,
     rating        ? "rating #{rating}" : nil,
     polling_place ? "polling place: #{polling_place.name}" : nil].compact.join(', ')    
  end
  
  def audio_file
    "#{uniqueid}." + (self.source=='IPH' ? 'caf' : 'gsm')
  end

  private
  def set_source
    self.source = self.reporter.source
  end

  def check_uniqueid
    update_attribute(:uniqueid, "#{Time.now.to_i}.#{self.id}") if self.uniqueid.nil?
  end
  
  # Detect and geocode any location information present in the report text
  def detect_location
    if self.text
      LOCATION_PATTERNS.find { |p| self.text[p] }
      self.location = Location.geocode($1) if $1
      self.zip = location.postal_code if self.location && location.postal_code
    end
    self.location = self.reporter.location if !self.location && self.reporter && self.reporter.location
    ll, self.location_accuracy = self.latlon.split(/:/) if self.latlon
    true
  end
  
  # append tag_string to report text if supplied (iphone, android)
  def append_tags
    self.text += (" "+self.tag_string) if !self.tag_string.blank?
    true
  end
  
  # What tags are associated with this report?
  # Find them and store for easy reference later
  def assign_tags
    if self.text
      Tag.find(:all).each do |t|
        if self.text[/#?#{t.pattern}/i]
          self.tags << t
          self.wait_time = $1 if t.pattern.starts_with?('wait')
        end
      end
      self.score = self.tags.inject(0) { |sum, t| sum+t.score }
    end
    true
  end
  
  # What location filters apply to this report?  US, MD, etc?
  def assign_filters
    if self.location_id && self.location.filter_list
			values = self.location.filter_list.split(',').map { |f| "(#{f},#{self.id})" }.join(',')
      self.connection.execute("INSERT DELAYED INTO report_filters (filter_id,report_id) VALUES #{values}") if !values.blank?
		end
		true
  end
end
