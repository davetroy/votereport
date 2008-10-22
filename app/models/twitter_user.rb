class TwitterUser < ActiveRecord::Base
  has_many :reports, :dependent => :destroy
  belongs_to :location
  
  validates_uniqueness_of :tid
  
  before_save :set_location
  
  # Takes a hash of Twitter user data
  # Adds to database if it's new to us, otherwise finds record and returns it
  def self.add(user_info)
    user_info = user_info.delete_if { |k,v| !self.column_names.include?(k) }
    if user = find_by_tid(user_info['tid'])
      user.update_attributes(user_info)
    else
      user = create(user_info)
    end
    user
  end

  private
  def set_location
    if location_id.nil? || (self.profile_location!=attributes['profile_location'])
      self.location = Location.geocode(attributes['profile_location'])
    end
  end

end
