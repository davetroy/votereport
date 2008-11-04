# These regexes are used to extract location from text bodies no matter the input source
LOCATION_PATTERNS = [
  Regexp.compile(/#?zip[\s\:\-]?(\d{5})/i),                   # #zip 00000
  Regexp.compile(/[\s#]?(\d{5}-?\d{0,4})/),                   # #94107, 02130, 21012-2423
  Regexp.compile(/^l:\s*([^:]+).*$/im),                       # L: at start
  Regexp.compile(/[\s,]l:\s*([^:]+).*$/im),                   # L: in tweet
]

# Natural lanaguage location patterns; used by sweeper interface
# to take a stab at deriving location
# See ReportHelper#suggest_location
NL_LOCATION_PATTERNS = [
  [Regexp.compile(/.+((at|in)(.*)$)/), 3]                     # makes an attempt at catching the last "in/at <some place>"
]

# Default limits for API usage; can be overridden case-by-case
DEFAULT_QUERY_LIMIT = 50_000
DEFAULT_UPDATE_LIMIT = 50_000

 US_STATES = { 	
'AL' 		=> 		'alabama', 
'AK' 		=> 		'alaska',
'AZ' 		=> 		'arizona',
'AR' 		=> 		'arkansas', 
'CA' 		=> 		'california', 
'CO' 		=> 		'colorado', 
'CT' 		=> 		'connecticut', 
'DE' 		=> 		'delaware', 
'DC' 		=> 		'washingtondc', 
'FL' 		=> 		'florida',
'GA' 		=> 		'georgia',
'HI' 		=> 		'hawaii', 
'ID' 		=> 		'idaho', 
'IL' 		=> 		'illinois', 
'IN' 		=> 		'indiana', 
'IA' 		=> 		'iowa', 
'KS' 		=> 		'kansas', 
'KY' 		=> 		'kentucky', 
'LA' 		=> 		'louisiana', 
'ME' 		=> 		'maine', 
'MD' 		=> 		'maryland', 
'MA' 		=> 		'massachusetts', 
'MI' 		=> 		'michigan', 
'MN' 		=> 		'minnesota',
'MS' 		=> 		'mississippi', 
'MO' 		=> 		'missouri', 
'MT' 		=> 		'montana', 
'NE' 		=> 		'nebraska', 
'NV' 		=> 		'nevada', 
'NH' 		=> 		'newhampshire', 
'NJ' 		=> 		'newjersey', 
'NM' 		=> 		'newmexico', 
'NY' 		=> 		'newyork', 
'NC' 		=> 		'northcarolina', 
'ND' 		=> 		'northdakota', 
'OH' 		=> 		'ohio', 
'OK' 		=> 		'oklahoma', 
'OR' 		=> 		'oregon', 
'PA' 		=> 		'pennsylvania', 
'RI' 		=> 		'rhodeisland', 
'SC' 		=> 		'southcarolina', 
'SD' 		=> 		'southdakota', 
'TN' 		=> 		'tennessee', 
'TX' 		=> 		'texas', 
'UT' 		=> 		'utah', 
'VT' 		=> 		'vermont', 
'VA' 		=> 		'virginia', 
'WA' 		=> 		'washington', 
'WV' 		=> 		'westvirginia', 
'WI' 		=> 		'wisconsin', 
'WY' =>  'wyoming'}