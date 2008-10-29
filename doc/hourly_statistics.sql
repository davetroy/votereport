-- 
-- Clear statistics for this hour, on this day
-- In case we're re-running this stat
DELETE FROM statistics WHERE DATE(created_at) = CURDATE() AND HOUR(created_at) = HOUR(now());

-- ----------------------------------------------------------
-- reporters count total
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'Reporters-all_count', NOW(), count(*) 
FROM reporters;

-- ----------------------------------------------------------
-- reporters-twitter count total
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'TwitterReporters-all_count', NOW(), count(*) 
FROM reporters
WHERE type = 'TwitterReporter';

-- ----------------------------------------------------------
-- reporters-sms count total
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'SmsReporters-all_count', NOW(), count(*) 
FROM reporters
WHERE type = 'SmsReporter';

-- ----------------------------------------------------------
-- reporters-iphone count total
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'IphoneReporters-all_count', NOW(), count(*) 
FROM reporters
WHERE type = 'IphoneReporter';

-- ----------------------------------------------------------
-- reporters-phone count total
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'PhoneReporters-all_count', NOW(), count(*) 
FROM reporters
WHERE type = 'PhoneReporter';

-- ----------------------------------------------------------
-- reports count total
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'Reports-all_count', NOW(), count(*) 
FROM reports;

-- ----------------------------------------------------------
-- reports count total
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'Reports-all_count', NOW(), count(*) 
FROM reports;

-- ----------------------------------------------------------
-- reports count sms
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'Reports-sms_count', NOW(), count(*) 
FROM reports r
WHERE r.source = 'SMS';

-- ----------------------------------------------------------
-- reports count twitter
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'Reports-twt_count', NOW(), count(*) 
FROM reports r
WHERE r.source = 'TWT';

-- ----------------------------------------------------------
-- reports count telephone
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'Reports-telephone_count', NOW(), count(*) 
FROM reports r
WHERE r.source = 'TEL';

-- ----------------------------------------------------------
-- reports count iphone
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'Reports-iphone_count', NOW(), count(*) 
FROM reports r
WHERE r.source = 'IPH';

-- ----------------------------------------------------------
-- reports created in last hour
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'Reports-last_hour_all', NOW(), count(*) 
FROM reports r
WHERE r.created_at > NOW() - INTERVAL 1 DAY;

-- ----------------------------------------------------------
-- sms reports created in last hour
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'Reports-last_hour_sms', NOW(), count(*) 
FROM reports r
WHERE 
  r.created_at > NOW() - INTERVAL 1 DAY AND
  r.source = 'SMS';
  
-- ----------------------------------------------------------
-- twitter reports created in last hour
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'Reports-last_hour_twitter', NOW(), count(*) 
FROM reports r
WHERE 
  r.created_at > NOW() - INTERVAL 1 DAY AND
  r.source = 'TWT';
  
-- ----------------------------------------------------------
-- iphone reports created in last hour
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'Reports-last_hour_iphone', NOW(), count(*) 
FROM reports r
WHERE 
  r.created_at > NOW() - INTERVAL 1 DAY AND
  r.source = 'IPH';
  
-- ----------------------------------------------------------
-- telephone reports created in last hour
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'Reports-last_hour_telephone', NOW(), count(*) 
FROM reports r
WHERE 
  r.created_at > NOW() - INTERVAL 1 DAY AND
  r.source = 'TEL';
  
-- ----------------------------------------------------------
-- all reports lacking location
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'Reports-all_NullLocation', NOW(), count(*) 
FROM reports r
WHERE 
  r.location_id = NULL;
  
-- ----------------------------------------------------------
-- reports lacking location last hour
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, integer_value)
SELECT 
  'Reports-last_hour_NullLocation', NOW(), count(*) 
FROM reports r
WHERE 
  r.created_at > NOW() - INTERVAL 1 DAY AND
  r.location_id = NULL;
  
-- ----------------------------------------------------------
-- total leader board
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, string_value, integer_value)
SELECT 
  'reporters-leaders-all_count', NOW(), 
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
  'reporters-leaders-all_count', NOW(), 
  src.uniqueid, count(r.id)
  FROM reporters src INNER JOIN reports r ON r.reporter_id = src.id
WHERE
  r.created_at > NOW() - INTERVAL 1 HOUR
GROUP BY src.uniqueid
ORDER BY count(r.id) DESC
LIMIT 20;

-- ----------------------------------------------------------
-- percent of reports sms
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, decimal_value)
SELECT 
  'reports-sms_percent', NOW(),
  count(*) / (select count(*) from reports) * 100.0 
FROM reports r WHERE r.source = 'SMS';

-- ----------------------------------------------------------
-- percent of reports twitter
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, decimal_value)
SELECT 
  'reports-twitter_percent', NOW(),
  count(*) / (select count(*) from reports) * 100.0 
FROM reports r WHERE r.source = 'TWT';

-- ----------------------------------------------------------
-- percent of reports iphone
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, decimal_value)
SELECT 
  'reports-iphone_percent', NOW(),
  count(*) / (select count(*) from reports) * 100.0 
FROM reports r WHERE r.source = 'IPH';

-- ----------------------------------------------------------
-- percent of reports telephone
-- ----------------------------------------------------------
INSERT INTO statistics (name, created_at, decimal_value)
SELECT 
  'reports-telephone_percent', NOW(),
  count(*) / (select count(*) from reports) * 100.0 
FROM reports r WHERE r.source = 'TEL';

-- ----------------------------------------------------------
-- SELECT out our stats!!!
-- ----------------------------------------------------------
SELECT name, string_value, integer_value, decimal_value
FROM statistics
WHERE DATE(created_at) = CURDATE()
ORDER BY name, sort  
;
