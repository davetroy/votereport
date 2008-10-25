class IphoneReporter < Reporter
  attr_accessor(:udid)
  before_save :massage_fields
  
  def source; "IPH"; end
  def source_name; "VoteReport iPhone App"; end
  def icon; "/images/iphone_icon.png"; end
  
  private
  def massage_fields
    self.uniqueid = @udid
  end
end
