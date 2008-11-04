xml.kml("xmlns" => "http://earth.google.com/kml/2.2", 
"xmlns:atom" => "http://www.w3.org/2005/Atom") do
  xml.tag! "Document" do
    xml.name "#votereport"
    xml.description "Voting Reports for the 2008 election"
    xml.atom :link, :href => formatted_reports_path(:format => "atom", :only_path => false ), :rel => "alternate", :type => "application/atom+xml"
    xml.atom :link, :href => url_for(:controller => :reports, :only_path => false ), :rel => "alternate", :type => "text/html"
    xml.tag! "LookAt" do # look at the bounds of the US (approximately)
      xml.longitude -98
      xml.latitude 39
      xml.altitude 8900000
    end
    @reports.each do |report| # render :partial => @reports - doesn't work in builder?
      xml.tag! "Placemark", :id => "votereport:report:#{report.id}" do
        xml.name report.reporter.name if report.reporter.name
        xml.description "#{h(report.text)} in #{h(report.location.address)}"
        xml.tag! "Style" do
          xml.tag! "IconStyle" do
            xml.tag! "Icon" do
              xml.href rating_icon(report.rating)
            end
          end unless report.reporter.nil?
          xml.tag! "LabelStyle" do
            xml.color "ff00aaff"
          end
          xml.tag! "BalloonStyle" do
            # this is ugly, but faster than calling a partial a lot
            balloonText = render(:partial => "balloon.html.erb", :locals => {:report => report})
              # balloonText = "$[description] by $[screen_name]"
              # balloonText << "<br />Rating: <img src='#{rating_icon(report.rating)}' /> (#{report.rating}%)" unless report.rating.nil?
            xml.text balloonText
            xml.textColor "ff084156"
            xml.color "ffffffff"
          end
        end
        xml.atom :author do
          xml.atom :name, report.reporter.name
        end unless report.reporter.nil?
        xml.atom( :link, :href => report_url(:id => report, :only_path => false ), :rel => "alternate", :type => "text/html")
        xml.tag! "ExtendedData" do
          %w{wait_time score rating}.each do |attribute|
            xml.tag! "Data", :name => attribute do
              xml.value report.send(attribute) 
            end
          end
          %w{screen_name}.each do |attribute|
            xml.tag! "Data", :name => attribute do
              xml.value report.reporter.send(attribute) 
            end
          end          
        end
        xml.address report.location.address unless report.location.address.blank?          
        xml.tag! "TimeStamp" do
          xml.when report.created_at.iso8601
        end unless report.created_at.nil?
        xml << report.location.point.as_kml
      end        
    end
  end
end
