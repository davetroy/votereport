class Tag < ActiveRecord::Base
  has_many :report_tags, :dependent => :destroy
  has_many :reports, :through => :report_tags
  
  def self.listing
    Tag.find(:all, :order => 'pattern DESC')
  end
end