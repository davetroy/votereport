ENV["RAILS_ENV"] ||= defined?(Daemons) ? 'production' : 'development'

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
    {'twitter_id' => 'uniqueid', 'location' => 'profile_location'}.each do |k,v|
      user_info[v] = user_info.delete(k)
    end
    next unless reporter = TwitterReporter.update_or_create(user_info)

    screen_name, text = entry['title'].match(EXTRACTOR).captures
    reporter.reports.create(:text => text,
                        :uniqueid => entry['status_id'],
                        :created_at => entry['published'])
  end
  sleep 10
end

