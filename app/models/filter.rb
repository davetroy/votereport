class Filter < ActiveRecord::Base
  belongs_to :center,
             :class_name => 'Location',
             :foreign_key => 'center_location_id'

  has_many :report_filters, :dependent => :destroy
  has_many :reports, :through => :report_filters

	validates_uniqueness_of :name, :title

  def self.get_list_for_location(location)
    find(:all).map do |f|
      next if f.conditions && !location.instance_eval(f.conditions)
      next if f.radius && !location.within_radius_of?(f.center, f.radius)
     f.id
   end.compact.join(',')
  end
  
  def self.get
    find(:all).map { |f| {:id => f.id, :name => f.name } }
  end
end
