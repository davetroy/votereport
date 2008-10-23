class Report < ActiveRecord::Base
  validates_uniqueness_of :tid

  belongs_to :location
  belongs_to :twitter_user
  has_many :report_tags, :dependent => :destroy
  has_many :tags, :through => :report_tags

  before_save :detect_location, :assign_tags

  private
  def detect_location
    LOCATION_PATTERNS.find { |p| self.text =~ p }
    self.location = Location.geocode($1) if $1
    self.zip = location.postal_code if location && location.postal_code
    self.location = twitter_user.location if !self.location && twitter_user && twitter_user.location
  end
  
  def assign_tags
    Tag.find(:all).each do |t|
      if self.text[/#?#{t.pattern}/i]
        self.tags << t
        self.wait_time = $1 if t.pattern.starts_with?('wait')
      end
    end
    self.score = self.tags.inject(0) { |sum, t| sum+t.score }
  end

end
