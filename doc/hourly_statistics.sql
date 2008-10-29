-- 
-- Clear statistics for this hour, on this day
-- In case we're re-running this stat
DELETE FROM statistics WHERE DATE(created_at) = UTC_DATE() AND HOUR(created_at) = HOUR(UTC_TIMESTAMP());

-- ----------------------------------------------------------
-- reporters count total
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'Reporters-all_count', UTC_TIMESTAMP(), count(*) 
FROM reporters;

-- ----------------------------------------------------------
-- reporters-twitter count total
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'TwitterReporters-all_count', UTC_TIMESTAMP(), count(*) 
FROM reporters
WHERE type = 'TwitterReporter';

-- ----------------------------------------------------------
-- reporters-sms count total
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'SmsReporters-all_count', UTC_TIMESTAMP(), count(*) 
FROM reporters
WHERE type = 'SmsReporter';

-- ----------------------------------------------------------
-- reporters-iphone count total
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'IphoneReporters-all_count', UTC_TIMESTAMP(), count(*) 
FROM reporters
WHERE type = 'IphoneReporter';

-- ----------------------------------------------------------
-- reporters-phone count total
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'PhoneReporters-all_count', UTC_TIMESTAMP(), count(*) 
FROM reporters
WHERE type = 'PhoneReporter';

-- ----------------------------------------------------------
-- reports count total
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'Reports-all_count', UTC_TIMESTAMP(), count(*) 
FROM reports;

-- ----------------------------------------------------------
-- reports count sms
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'Reports-sms_count', UTC_TIMESTAMP(), count(*) 
FROM reports r
WHERE r.source = 'SMS';

-- ----------------------------------------------------------
-- reports count twitter
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'Reports-twt_count', UTC_TIMESTAMP(), count(*) 
FROM reports r
WHERE r.source = 'TWT';

-- ----------------------------------------------------------
-- reports count telephone
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'Reports-telephone_count', UTC_TIMESTAMP(), count(*) 
FROM reports r
WHERE r.source = 'TEL';

-- ----------------------------------------------------------
-- reports count iphone
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'Reports-iphone_count', UTC_TIMESTAMP(), count(*) 
FROM reports r
WHERE r.source = 'IPH';

-- ----------------------------------------------------------
-- reports created in last hour
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'Reports-last_hour_all', UTC_TIMESTAMP(), count(*) 
FROM reports r
WHERE r.created_at > UTC_TIMESTAMP() - INTERVAL 1 DAY;

-- ----------------------------------------------------------
-- sms reports created in last hour
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'Reports-last_hour_sms', UTC_TIMESTAMP(), count(*) 
FROM reports r
WHERE 
  r.created_at > UTC_TIMESTAMP() - INTERVAL 1 DAY AND
  r.source = 'SMS';
  
-- ----------------------------------------------------------
-- twitter reports created in last hour
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'Reports-last_hour_twitter', UTC_TIMESTAMP(), count(*) 
FROM reports r
WHERE 
  r.created_at > UTC_TIMESTAMP() - INTERVAL 1 DAY AND
  r.source = 'TWT';
  
-- ----------------------------------------------------------
-- iphone reports created in last hour
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'Reports-last_hour_iphone', UTC_TIMESTAMP(), count(*) 
FROM reports r
WHERE 
  r.created_at > UTC_TIMESTAMP() - INTERVAL 1 DAY AND
  r.source = 'IPH';
  
-- ----------------------------------------------------------
-- telephone reports created in last hour
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'Reports-last_hour_telephone', UTC_TIMESTAMP(), count(*) 
FROM reports r
WHERE 
  r.created_at > UTC_TIMESTAMP() - INTERVAL 1 DAY AND
  r.source = 'TEL';
  
-- ----------------------------------------------------------
-- all reports lacking location
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'Reports-all_NullLocation', UTC_TIMESTAMP(), count(*) 
FROM reports r
WHERE 
  r.location_id = NULL;
  
-- ----------------------------------------------------------
-- reports lacking location last hour
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'Reports-last_hour_NullLocation', UTC_TIMESTAMP(), count(*) 
FROM reports r
WHERE 
  r.created_at > UTC_TIMESTAMP() - INTERVAL 1 DAY AND
  r.location_id = NULL;
  
-- ----------------------------------------------------------
-- total leader board
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, string_value, integer_value)
SELECT 
  'reporters-leaders-all_count', UTC_TIMESTAMP(), 
  src.uniqueid, count(r.id)
  FROM reporters src INNER JOIN reports r ON r.reporter_id = src.id
GROUP BY src.uniqueid
ORDER BY count(r.id) DESC
LIMIT 20;

-- ----------------------------------------------------------
-- last-hour leader board
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, string_value, integer_value)
SELECT 
  'reporters-leaders-all_count', UTC_TIMESTAMP(), 
  src.uniqueid, count(r.id)
  FROM reporters src INNER JOIN reports r ON r.reporter_id = src.id
WHERE
  r.created_at > UTC_TIMESTAMP() - INTERVAL 1 HOUR
GROUP BY src.uniqueid
ORDER BY count(r.id) DESC
LIMIT 20;

-- ----------------------------------------------------------
-- percent of reports sms
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, decimal_value)
SELECT 
  'reports-sms_percent', UTC_TIMESTAMP(),
  count(*) / (select count(*) from reports) * 100.0 
FROM reports r WHERE r.source = 'SMS';

-- ----------------------------------------------------------
-- percent of reports twitter
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, decimal_value)
SELECT 
  'reports-twitter_percent', UTC_TIMESTAMP(),
  count(*) / (select count(*) from reports) * 100.0 
FROM reports r WHERE r.source = 'TWT';

-- ----------------------------------------------------------
-- percent of reports iphone
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, decimal_value)
SELECT 
  'reports-iphone_percent', UTC_TIMESTAMP(),
  count(*) / (select count(*) from reports) * 100.0 
FROM reports r WHERE r.source = 'IPH';

-- ----------------------------------------------------------
-- percent of reports telephone
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, decimal_value)
SELECT 
  'reports-telephone_percent', UTC_TIMESTAMP(),
  count(*) / (select count(*) from reports) * 100.0 
FROM reports r WHERE r.source = 'TEL';

-- ----------------------------------------------------------
-- SELECT out our stats!!!
-- ----------------------------------------------------------
SELECT name, string_value, integer_value, decimal_value
FROM statistics
WHERE DATE(created_at) = UTC_DATE()
ORDER BY name, sort  
;
