ENV["RAILS_ENV"] ||= 'production'

# TODO: this needs completed!  Only a skeleton right now!
# See mozes_sample.xml for contents of feed

FEED = "http://www.mozes.com/_/rss?keyword_id=1031894"

require File.dirname(__FILE__) + "/../../config/environment"
require 'json'
require 'open-uri'

$running = true
Signal.trap("TERM") do 
  $running = false
end

while($running) do
  # Populate these fields ONLY
    # report.text = description body (exclude <a><img>*</a>)
    # report.callerid = mozes:mozesUserId
    # report.input_source_id = 2

  # DO NOT populate these fields for this dataset
    # report.uniqueid = nil                 (asterisk ONLY)
    # report.tid = nil                      (twitter ONLY)
    # report.twitter_user_id = nil          (twitter ONLY)
    
  
  messages = open(FEED).read
  sleep 10
end

