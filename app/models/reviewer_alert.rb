class ReviewerAlert < ActiveRecord::Base
  belongs_to :user  # this is the person who created the alert
end
