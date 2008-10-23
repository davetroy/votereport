xml.kml("xmlns" => "http://earth.google.com/kml/2.2", 
    "xmlns:atom" => "http://www.w3.org/2005/Atom") do
  xml.tag! "Document" do
    xml.name "#votereport"
    xml.description "Voting Reports for the 2008 election"
    xml.tag! "Link" do
      xml.href url_for(:controller => :reports, :action => :index, :only_path => false, :live => 1  )
    end
  end
end