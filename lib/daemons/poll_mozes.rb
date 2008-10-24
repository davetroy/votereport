ENV["RAILS_ENV"] ||= 'production'

FEED = 'http://www.mozes.com/_/rss?keyword_id=1031894'

require "#{RAILS_ROOT}/config/environment"
require 'hpricot'
require 'open-uri'

$running = true
Signal.trap("TERM") do 
  $running = false
end

$stdout.sync=true

# for chucking errors about bad data
class PollMozesException < StandardError
end

def debug(msg) 
  puts "[poll_mozes] [debug] #{msg}" if RAILS_ENV == 'development'
end

while($running) do
  begin
  # DO NOT populate these fields for this dataset
    # report.uniqueid = nil                 (asterisk ONLY)
    # report.tid = nil                      (twitter ONLY)
    # report.twitter_user_id = nil          (twitter ONLY)
    
    debug "Pulling XML feed..."
    doc = Hpricot.XML(open(FEED))
    
    (doc/:item).each do |item|
      begin
        # pull an identifier
        item_id = (item/:guid).inner_text
        debug "found item: #{item_id}"
        
        # create a user if not already extant
        mozes_id = (item/'mozes:mozesUserId').inner_text.strip
        debug "JIT user creation for #{mozes_id}"
        user = MozesUser.find_or_create_by_mozes_id( mozes_id )
        unless user.valid?
          raise PollMozesException.new("[poll mozes] No Mozes User ID for item: #{item_id}")
        end
        
        # create the report
        debug "creating report..."
        user.reports.create!({ 
          :text => (item/:description).inner_text, 
          :mozes_user_id => user.id, 
          :mozes_feed_id => item_id,
          :input_source_id => Report::SOURCE_MOZES 
        })
        
      rescue ActiveRecord::RecordInvalid => e
        puts "[poll_mozes] Error while creating report from feed item: #{item_id} : #{e.class}: #{e.message}"
      end
    end
  rescue Exception => e
    puts "[poll_mozes] Uncaught exception during loop: \n#{e.class}: #{e.message}\n\t#{e.backtrace.join("\n")} "
    return
  end
  sleep 10
end

