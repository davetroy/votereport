ENV["RAILS_ENV"] ||= 'production'

FEED = 'http://www.mozes.com/_/rss?keyword_id=1031894'

require File.dirname(__FILE__) + "/../../config/environment"
require 'hpricot'
require 'open-uri'

$running = true
Signal.trap("TERM") do 
  $running = false
end

# for chucking errors about bad data
class PollMozesException < StandardError
end

while($running) do
  begin
  # DO NOT populate these fields for this dataset
    # report.uniqueid = nil                 (asterisk ONLY)
    # report.tid = nil                      (twitter ONLY)
    # report.twitter_user_id = nil          (twitter ONLY)
    
    doc = Hpricot.XML(open(FEED))
    
    (doc/:item).each do |item|
      begin
        user = MozesUser.find_or_create_by_mozes_id( (item/'mozes:mozesUserId').inner_html.strip )
        
        throw PollMozesException.new("No Mozes User ID for this item, pubDate: #{(item/:pubDate)}") if user.new_record?
        
        # Populate these fields ONLY
        # report.text = description body (exclude <a><img>*</a>)
        # report.callerid = mozes:mozesUserId
        # report.input_source_id = 2
        user.reports.create! { 
          :text => (item/:description).inner_text, 
          :mozes_user_id => user.id, 
          :mozes_feed_id => nil,
          :input_source_id => REPORT::SOURCE_MOZES 
        }
        
      rescue ActiveRecord::InvalidRecord => e
        puts "Error while creating report from Mozes feed: #{e.class}: #{e.message}"
      end
    end
  rescue Exception => e
    puts "Uncaught exception during loop: \n#{e.class}: #{e.message}\n\t#{e.backtrace.join("\n")} "
  end
  #messages = open(FEED).read
  sleep 10
end

