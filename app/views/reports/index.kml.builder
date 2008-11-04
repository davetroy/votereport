xml.kml("xmlns" => "http://earth.google.com/kml/2.2", 
    "xmlns:atom" => "http://www.w3.org/2005/Atom") do
  xml.tag! "Document" do
    xml.name "#votereport"
    xml.description "Voting Reports for the 2008 election"
    xml.tag! "LookAt" do # look at the bounds of the US (approximately)
      xml.longitude -98
      xml.latitude 39
      xml.altitude 8900000
    end    
    xml.tag! "NetworkLink" do
      xml.name "#votereport live updating"
      xml.tag! "Link" do
        xml.href kml_feed_url(:count => 4000)
        xml.refreshMode "onInterval"
        xml.refreshInterval 60
        xml.viewRefreshMode "onStop"
        xml.viewRefreshTime 30
      end
    end
  end
end