class ReportTag < ActiveRecord::Base
  belongs_to :report
  belongs_to :tag
end