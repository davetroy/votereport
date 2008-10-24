class MozesUser < ActiveRecord::Base
  has_many :reports, :dependent => :destroy
  
  validates_presence_of :mozes_id
  validates_uniqueness_of :mozes_id
end
