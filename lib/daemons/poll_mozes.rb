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
  # perform magic here, being careful not to introduce duplicates
  messages = open(FEED).read
  sleep 10
end

