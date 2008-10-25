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

# for chucking errors about bad data
class PollMozesException < StandardError
end

def debug(msg) 
  puts "[poll_mozes] [debug] #{msg}" if RAILS_ENV == 'development'
end

def write_tstamp(time = Time.now)
  file = File.new(STAMPFILE, "w")
  file.print time.to_s
  file.close
end

def read_tstamp
  stamps = []
  stamps = IO.readlines(STAMPFILE) if File.exists? STAMPFILE
  stamps[0].nil? ? (Time.now - 1.hour) : Time.parse(stamps[0])
end

while($running) do
  since = read_tstamp
  begin
    
    debug "Pulling XML feed..."
    doc = Hpricot.XML(open(FEED))
    
    (doc/:item).each do |item|
      begin        
        only process items posted after our last check...
        item_tstamp = Time.parse((item/:pubDate).inner_text)
        if item_tstamp < since
          debug "skipping item #{item_id}, #{item_tstamp} before #{since}"
          next
        end
                
        # create the report
        debug "creating report..."
        Report.create!({ 
          :text => (item/:description).inner_text.gsub(/<a.*?\/a>/, '').strip,
          :callerid => (item/'mozes:mozesUserId').inner_text.strip, 
          :uniqueid => (item/:guid).inner_text.strip,
          :input_source_id => Report::SOURCE_MOZES 
        })
        
      rescue ActiveRecord::RecordInvalid => e
        puts "[poll_mozes] Error while creating report from feed item: #{item_id} : #{e.class}: #{e.message}"
      end
    end
  rescue Exception => e
    puts "[poll_mozes] Uncaught exception during loop: \n#{e.class}: #{e.message}\n\t#{e.backtrace.join("\n")} "
  end
  write_tstamp
  sleep 10
end

