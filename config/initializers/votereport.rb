# These regexes are used to extract location from text bodies no matter the input source
LOCATION_PATTERNS = [
  Regexp.new(/#zip[\s\:\-]?(\d{5})/i),              # #zip 00000
  Regexp.new(/#(\d{5})/),                           # #00000
  Regexp.new(/^l:\s*([^:]+).*$/im),                 # L: at start of text
  Regexp.new(/[\s,]l:\s*([^:]+).*$/im),             # L: in text after space
  Regexp.new(/\s(\d{5})\s?/)                        # 00000 anywhere in text
]