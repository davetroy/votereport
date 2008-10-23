class ReportFilter < ActiveRecord::Base
  belongs_to :report
	belongs_to :filter
end
