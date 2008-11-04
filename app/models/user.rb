class User < ActiveRecord::Base
  require 'digest/sha1'
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  ##########################################################################
  ###########                     VALIDATIONS                   ############
  ##########################################################################
  
  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, 
                                       :message => Authentication.bad_email_message

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation, :url

  validates_presence_of :first_name, :last_name, :email
  validates_uniqueness_of :email
  
  ##########################################################################
  ###########                     CALLBACKS                     ############
  ##########################################################################
  
  before_create :make_activation_code 
  before_create :assign_api_key
  before_validation_on_create :set_api_limits, :fix_url

  ##########################################################################
  ###########                     ASSOCIATIONS                   ###########
  ##########################################################################

  has_many :reviewer_alerts, # as the creator, only applies to admins
           :dependent => :nullify
  has_many :alert_viewings,
           :dependent => :destroy
           
  has_many :reviewed_reports, 
    :class_name => "Report", 
    :foreign_key => "reviewer_id", 
    :conditions => "reviewed_at IS NOT NULL"

  ##########################################################################
  ###########                       METHODS                      ###########
  ##########################################################################


  # These are alerts for this reviewer that he has not yet dismissed
  def unviewed_alerts
    ReviewerAlert.find(:all, 
                       :joins => "LEFT JOIN alert_viewings ON alert_viewings.reviewer_alert_id = reviewer_alerts.id AND alert_viewings.user_id = #{self.id}",
                       :conditions => "alert_viewings.reviewer_alert_id IS NULL",
                       :order => "reviewer_alerts.created_at desc", :limit => 10)
  end
  
  def viewed_alert!(reviewer_alert)
    AlertViewing.create!(:user => self, :reviewer_alert => reviewer_alert)
  end

  # override the +is_admin+ attribute to allow us to specify email addresses
  # that belong to those working on the site
  # (This way we don't have a chicken-or-egg issue to set the first admin)
  ADMIN_EMAIL_ADDRESSES = 
    ["cory.forsyth@gmail.com",  # cory forsyth
     "wgray@zetetic.net",       # billy gray
     "nancyscola@gmail.com",    # nancy scola
     "davetroy@gmail.com"       # dave troy
     ]
  def is_admin?
    super || ADMIN_EMAIL_ADDRESSES.include?(email)
  end

  def assign_api_key
    self.api_key = Digest::SHA1.hexdigest(Time.now.to_s + self.email)
  end
  
  def set_api_limits
    self.day_query_limit = DEFAULT_QUERY_LIMIT
    self.day_update_limit = DEFAULT_UPDATE_LIMIT
  end
  
  def fix_url
    self.url = "http://#{url}" if !self.url.blank? && self.url !~ /http:\/\//
  end
  
  def verify(submitted_key)
    return unless submitted_key == api_key
    self.verified = true
    self.authorized = true  # skipping an explicit authorization step
    save
  end
  
  def name
    "#{first_name} #{last_name}"
  end
  
  # Activates the user in the database.
  def activate!
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save(false)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end
  
  def active?
    # the existence of an activation code means they have not activated yet
    activation_code.nil?
  end
  
  def authorized_for_api?
    verified? && authorized?
  end
  
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(email, password)
    return nil if email.blank? || password.blank?
    u = find :first, :conditions => ['email = ? and activated_at IS NOT NULL', email] # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  def record_query_stats
    self.query_count += 1
    self.day_query_count = 0 if last_query_at.nil? || (last_query_at < Time.today)
    self.day_query_count += 1
    self.last_query_at = Time.now
    self.save
    raise VoteReport::APIError, "Exceeded query limit!" if (self.day_query_count > self.day_query_limit)  
  end

  def record_update_stats
    self.update_count += 1
    self.day_update_count = 0 if last_query_at.nil? || (last_query_at < Time.today)
    self.day_update_count += 1
    self.last_update_at = Time.now
    self.save
    raise VoteReport::APIError, "Exceeded update limit!" if (self.day_query_count > self.day_query_limit)  
  end
  
  def terminate!
    # 1. reverse password hash
    self.crypted_password.reverse!
    # 2. set is_terminated = true
    self.is_terminated = true
    self.save!
  end
  
  def unterminate!
    raise "User was not previously terminated" unless self.is_terminated?
    # 1. reverse password hash
    self.crypted_password.reverse!
    # 2. set is_terminated = false
    self.is_terminated = false
    self.save!
  end
  
  def update_reports_count!
    self.increment!(:reports_count)
  end
  
  def has_access?
    !self.is_terminated?
  end

  protected
    
  def make_activation_code
      self.activation_code = self.class.make_token
  end

end
