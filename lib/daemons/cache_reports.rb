ENV["RAILS_ENV"] ||= defined?(Daemons) ? 'production' : 'development'

if ENV["RAILS_ENV"] == 'development'
  # Dev
  URL = "http://localhost:3000/reports/reload"
  PATH_TO_CACHED_FILE = "public/cached_reports.html"
  CURL = "/opt/local/bin/curl"
else
  # Prod
  URL = "http://votereport.us/reports/reload"
  PATH_TO_CACHED_FILE = "/home/votereport/current/public/cached_reports.html"
  CURL = "/usr/bin/curl"
end

$running = true
Signal.trap("TERM") do 
  $running = false
end

while($running) do
  `#{CURL} #{URL} > #{PATH_TO_CACHED_FILE}.tmp`
  File.rename("#{PATH_TO_CACHED_FILE}.tmp", PATH_TO_CACHED_FILE)
  sleep 30
end
