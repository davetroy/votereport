class User < ActiveRecord::Base
  require 'digest/sha1'

  validates_presence_of :name, :url, :api_key, :password_hash, :email
  validates_uniqueness_of :api_key, :email, :url, :name

  attr_accessor(:password)
  
  def before_validation_on_create
    %w(url email password).each { |a| self.errors.add(a, "can't be blank!") if self.send(a).blank? }
    return false unless self.errors.empty?
    self.api_key = Digest::SHA1.hexdigest(self.url+self.email).reverse
    self.password_hash = Digest::SHA1.hexdigest(self.password+self.api_key)
    self.authorized = true                            # skip an approval step
    self.day_query_limit = DEFAULT_QUERY_LIMIT
    self.day_update_limit = DEFAULT_UPDATE_LIMIT
    self.url = "http://#{url}" if !self.url.blank? && self.url !~ /http:\/\//
    true
  rescue
    self.errors.add_to_base("Error creating record!")
    false
  end
    
  def verify(submitted_key)
    return false unless (submitted_key==api_key)
    update_attribute(:verified, true)
    true
  end
  
  def activated
    verified && authorized
  end

  def record_query_stats
    self.query_count += 1
    self.day_query_count = 0 if last_query_at.nil? || (last_query_at < Time.today)
    self.day_query_count += 1
    self.last_query_at = Time.now
    self.save
    raise OpenLocation::APIError, "Exceeded query limit!" if (self.day_query_count > self.day_query_limit)  
  end

  def record_update_stats
    self.update_count += 1
    self.day_update_count = 0 if last_query_at.nil? || (last_query_at < Time.today)
    self.day_update_count += 1
    self.last_update_at = Time.now
    self.save
    raise OpenLocation::APIError, "Exceeded update limit!" if (self.day_query_count > self.day_query_limit)  
  end

  # Locate and authenticate a user
  def self.authenticate(p)
    return false unless user = find_by_email(p[:email])
    pwtest = Digest::SHA1.hexdigest(p[:password]+user.api_key)
    (pwtest == user.password_hash) && (p[:email] == user.email) ? user[:id] : nil
  end
end
