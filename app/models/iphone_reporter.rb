class IphoneReporter < Reporter
  attr_accessor(:password)
  
  def source; "IPH"; end
  def source_name; "VoteReport iPhone App"; end
  def icon; "/images/iphone_icon.png"; end
  
end
