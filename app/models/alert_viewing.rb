class AlertViewing < ActiveRecord::Base
  belongs_to :user
  belongs_to :reviewer_alert
end
