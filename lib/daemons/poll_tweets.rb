ENV["RAILS_ENV"] ||= 'production'

FEED = "http://twittervision.com/votereport.json"
EXTRACTOR = Regexp.new(/^(\w+?):\s(.*)$/m)

require File.dirname(__FILE__) + "/../../config/environment"
require 'json'
require 'open-uri'

$running = true
Signal.trap("TERM") do 
  $running = false
end

while($running) do
  tweets = JSON.parse(open(FEED).read)
  tweets.each do |entry|
    user_info = entry['source']['author']
    {'twitter_id' => 'tid', 'location' => 'profile_location'}.each do |k,v|
      user_info[v] = user_info.delete(k)
    end
    next unless user = TwitterUser.add(user_info)
    
    screen_name, text = entry['title'].match(EXTRACTOR).captures
    report = { :text => text, :tid => entry['status_id'], :input_source_id => 1 }
    user.reports.create(report)
  end
  sleep 10
end

