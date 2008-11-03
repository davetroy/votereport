-- 
-- Clear statistics for this hour, on this day
-- In case we're re-running this stat
DELETE FROM statistics WHERE DATE(created_at) = UTC_DATE() AND HOUR(created_at) = HOUR(UTC_TIMESTAMP());

-- ----------------------------------------------------------
-- reporters count total
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'reporters-count-all', UTC_TIMESTAMP(), count(*) 
FROM reporters;

-- ----------------------------------------------------------
-- reporters total twitter
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'reporters-count-twitter', UTC_TIMESTAMP(), count(*) 
FROM reporters
WHERE type = 'TwitterReporter';

-- ----------------------------------------------------------
-- reporters total sms
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'reporters-count-sms', UTC_TIMESTAMP(), count(*) 
FROM reporters
WHERE type = 'SmsReporter';

-- ----------------------------------------------------------
-- reporters-iphone count total
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'reporters-count-iphone', UTC_TIMESTAMP(), count(*) 
FROM reporters
WHERE type = 'IphoneReporter';

-- ----------------------------------------------------------
-- reporters-phone count total
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'reporters-count-telephone', UTC_TIMESTAMP(), count(*) 
FROM reporters
WHERE type = 'PhoneReporter';

-- ----------------------------------------------------------
-- reporters-android count total
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'reporters-count-android', UTC_TIMESTAMP(), count(*) 
FROM reporters
WHERE type = 'AndroidReporter';

-- ----------------------------------------------------------
-- reports count total
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'reports-count-all', UTC_TIMESTAMP(), count(*) 
FROM reports;

-- ----------------------------------------------------------
-- reports count sms
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'reports-count-sms', UTC_TIMESTAMP(), count(*) 
FROM reports r
WHERE r.source = 'SMS';

-- ----------------------------------------------------------
-- reports count twitter
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'reports-count-twitter', UTC_TIMESTAMP(), count(*) 
FROM reports r
WHERE r.source = 'TWT';

-- ----------------------------------------------------------
-- reports count telephone
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'reports-count-telephone', UTC_TIMESTAMP(), count(*) 
FROM reports r
WHERE r.source = 'TEL';

-- ----------------------------------------------------------
-- reports count iphone
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'reports-count-iphone', UTC_TIMESTAMP(), count(*) 
FROM reports r
WHERE r.source = 'IPH';

-- ----------------------------------------------------------
-- reports count android
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'reports-count-android', UTC_TIMESTAMP(), count(*) 
FROM reports r
WHERE r.source = 'ADR';

-- ----------------------------------------------------------
-- reports created in last hour
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'reports-lasthour-all', UTC_TIMESTAMP(), count(*) 
FROM reports r
WHERE r.created_at > UTC_TIMESTAMP() - INTERVAL 1 DAY;

-- ----------------------------------------------------------
-- sms reports created in last hour
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'reports-lasthour-sms', UTC_TIMESTAMP(), count(*) 
FROM reports r
WHERE 
  r.created_at > UTC_TIMESTAMP() - INTERVAL 1 DAY AND
  r.source = 'SMS';
  
-- ----------------------------------------------------------
-- twitter reports created in last hour
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'reports-lasthour-twitter', UTC_TIMESTAMP(), count(*) 
FROM reports r
WHERE 
  r.created_at > UTC_TIMESTAMP() - INTERVAL 1 DAY AND
  r.source = 'TWT';
  
-- ----------------------------------------------------------
-- iphone reports created in last hour
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'reports-lasthour-iphone', UTC_TIMESTAMP(), count(*) 
FROM reports r
WHERE 
  r.created_at > UTC_TIMESTAMP() - INTERVAL 1 DAY AND
  r.source = 'IPH';
  
-- ----------------------------------------------------------
-- telephone reports created in last hour
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'reports-lasthour-telephone', UTC_TIMESTAMP(), count(*) 
FROM reports r
WHERE 
  r.created_at > UTC_TIMESTAMP() - INTERVAL 1 DAY AND
  r.source = 'TEL';
  
-- ----------------------------------------------------------
-- android reports created in last hour
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'reports-lasthour-android', UTC_TIMESTAMP(), count(*) 
FROM reports r
WHERE 
  r.created_at > UTC_TIMESTAMP() - INTERVAL 1 DAY AND
  r.source = 'ADR';
  
-- ----------------------------------------------------------
-- all reports lacking location
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'reports-nolocation-all', UTC_TIMESTAMP(), count(*) 
FROM reports r
WHERE 
  r.location_id IS NULL;
  
-- ----------------------------------------------------------
-- reports lacking location last hour
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'reports-nolocation-lasthour', UTC_TIMESTAMP(), count(*) 
FROM reports r
WHERE 
  r.created_at > UTC_TIMESTAMP() - INTERVAL 1 DAY AND
  r.location_id IS NULL;
  
-- ----------------------------------------------------------
-- precentage reports lacking location
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, decimal_value)
SELECT 
  'reports-nolocation-percent', UTC_TIMESTAMP(), 
  count(*) / (select count(*) from reports) * 100.0 
FROM reports r
WHERE 
  r.location_id IS NULL;
  
-- ----------------------------------------------------------
-- reports reviewed total
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'reviewed-all', UTC_TIMESTAMP(), count(*) 
FROM reports r
WHERE 
  r.reviewed_at IS NOT NULL;
  
-- ----------------------------------------------------------
-- reports reviewed lasthour
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'reviewed-lasthour', UTC_TIMESTAMP(), count(*) 
FROM reports r
WHERE 
  r.reviewed_at > UTC_TIMESTAMP() - INTERVAL 1 DAY;
  
-- ----------------------------------------------------------
-- precentage reports reviewed
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, decimal_value)
SELECT 
  'reviewed-percent', UTC_TIMESTAMP(), 
  count(*) / (select count(*) from reports) * 100.0 
FROM reports r
WHERE 
  r.reviewed_at IS NOT NULL;  

-- ----------------------------------------------------------
-- precentage reports dismissed
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, decimal_value)
SELECT 
  'reviewed-dismissed-percent', UTC_TIMESTAMP(), 
  count(*) / (select count(*) from reports) * 100.0 
FROM reports r
WHERE 
  r.dismissed_at IS NOT NULL AND r.reviewed_at IS NOT NULL;
  
-- ----------------------------------------------------------
-- precentage reports confirmed
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, decimal_value)
SELECT 
  'reviewed-confirmed-percent', UTC_TIMESTAMP(), 
  count(*) / (select count(*) from reports) * 100.0 
FROM reports r
WHERE r.dismissed_at IS NULL AND r.reviewed_at IS NOT NULL;
  
-- ----------------------------------------------------------
-- total leader board
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, string_value, integer_value)
SELECT 
  'reporters-leaders-alltime', UTC_TIMESTAMP(), 
  CONCAT(src.uniqueid,':',src.screen_name), count(r.id)
  FROM reporters src INNER JOIN reports r ON r.reporter_id = src.id
GROUP BY src.uniqueid,src.screen_name
ORDER BY count(r.id) DESC
LIMIT 10;

-- ----------------------------------------------------------
-- last-hour leader board
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, string_value, integer_value)
SELECT 
  'reporters-leaders-lasthour', UTC_TIMESTAMP(), 
  CONCAT(src.uniqueid,':',src.screen_name), count(r.id)
  FROM reporters src INNER JOIN reports r ON r.reporter_id = src.id
WHERE
  r.created_at > UTC_TIMESTAMP() - INTERVAL 1 HOUR
GROUP BY src.uniqueid,src.screen_name
ORDER BY count(r.id) DESC
LIMIT 10;

-- ----------------------------------------------------------
-- percent of reports sms
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, decimal_value)
SELECT 
  'source-percent-sms', UTC_TIMESTAMP(),
  count(*) / (select count(*) from reports) * 100.0 
FROM reports r WHERE r.source = 'SMS';

-- ----------------------------------------------------------
-- percent of reports twitter
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, decimal_value)
SELECT 
  'source-percent-twitter', UTC_TIMESTAMP(),
  count(*) / (select count(*) from reports) * 100.0 
FROM reports r WHERE r.source = 'TWT';

-- ----------------------------------------------------------
-- percent of reports iphone
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, decimal_value)
SELECT 
  'source-percent-iphone', UTC_TIMESTAMP(),
  count(*) / (select count(*) from reports) * 100.0 
FROM reports r WHERE r.source = 'IPH';

-- ----------------------------------------------------------
-- percent of reports telephone
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, decimal_value)
SELECT 
  'source-percent-telephone', UTC_TIMESTAMP(),
  count(*) / (select count(*) from reports) * 100.0 
FROM reports r WHERE r.source = 'TEL';

-- ----------------------------------------------------------
-- percent of reports android
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, decimal_value)
SELECT 
  'source-percent-android', UTC_TIMESTAMP(),
  count(*) / (select count(*) from reports) * 100.0 
FROM reports r WHERE r.source = 'ADR';

-- ----------------------------------------------------------
-- SELECT out our stats!!!
-- ----------------------------------------------------------
SELECT name, string_value, integer_value, decimal_value
FROM statistics
WHERE DATE(created_at) = UTC_DATE()
ORDER BY name, sort  
;
