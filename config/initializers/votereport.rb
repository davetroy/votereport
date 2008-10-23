# These regexes are used to extract location from text bodies no matter the input source
LOCATION_PATTERNS = [
  Regexp.compile(/#?zip[\s\:\-]?(\d{5})/i),                   # #zip 00000
  Regexp.compile(/[\s#]?(\d{5}-?\d{0,4})/),                   # #94107, 02130, 21012-2423
  Regexp.compile(/^l:\s*([^:]+).*$/im),                       # L: at start
  Regexp.compile(/[\s,]l:\s*([^:]+).*$/im)                    # L: in tweet
]
