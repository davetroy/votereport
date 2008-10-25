ENV["RAILS_ENV"] ||= defined?(Daemons) ? 'production' : 'development'

FEED = 'http://www.mozes.com/_/rss?keyword_id=1031894'
STAMPFILE = '/tmp/poll_mozes_tstamp'

require File.dirname(__FILE__) + "/../../config/environment"
require 'hpricot'
require 'open-uri'

$running = true
Signal.trap("TERM") do 
  $running = false
end

$stdout.sync=true

def debug(msg)
  puts "[poll_mozes] [debug] #{msg}" if RAILS_ENV == 'development'
end

while($running) do
  since = Time.parse(File.read(STAMPFILE)) rescue 1.hour.ago
  begin
    debug "Pulling XML feed..."
    doc = Hpricot.XML(open(FEED))
    
    (doc/:item).each do |item|
      begin        
        # only process items posted after our last check...
        # item_tstamp = Time.parse((item/:pubDate).inner_text)
        # if item_tstamp < since
        #   debug "skipping item: #{item_tstamp} before #{since}"
        #   next
        # end
                
        # create the report
        debug "creating report..."
        Report.create!(:text => (item/:description).inner_text.gsub(/<a.*?\/a>/, '').strip,
                       :callerid => (item/'mozes:mozesUserId').inner_text.strip, 
                       :uniqueid => (item/:guid).inner_text.strip,
                       :input_source_id => Report::SOURCE_MOZES)
        
      rescue ActiveRecord::RecordInvalid => e
        puts "[poll_mozes] Error while creating report from feed item: #{e.class}: #{e.message}"
      end
    end
  rescue Exception => e
    puts "[poll_mozes] Uncaught exception during loop: \n#{e.class}: #{e.message}\n\t#{e.backtrace.join("\n")} "
  end
  File.open(STAMPFILE, "w") { |f| f.print time.to_s }
  sleep 10
end

