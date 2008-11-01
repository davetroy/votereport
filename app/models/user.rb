class User < ActiveRecord::Base
  require 'digest/sha1'
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message

  before_create :make_activation_code 

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation, :url

  validates_presence_of :first_name, :last_name, :email
  validates_uniqueness_of :email
  
  before_create :assign_api_key
  before_validation_on_create :set_api_limits, :fix_url
  
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
    self.authorized = true
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
  
  # Skipping the explicit authorization step for now
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

  protected
    
  def make_activation_code
      self.activation_code = self.class.make_token
  end
  
  public
  
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

end
