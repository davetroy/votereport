ENV["RAILS_ENV"] ||= defined?(Daemons) ? 'production' : 'development'

# Dev
#URL = "http://localhost:3000/reports/reload"
#PATH_TO_CACHED_FILE = "public/cached_tweets.html"

# Prod
URL = "http://votereport.us/reports/reload"
PATH_TO_CACHED_FILE = "cached_tweets.html"  # I don't know what this should be?

$running = true
Signal.trap("TERM") do 
  $running = false
end

while($running) do
  `curl #{URL} > #{PATH_TO_CACHED_FILE}`
  sleep 30
end
