SELECT 
	'2014-10-11'::date -'2014-10-10'::date = 1 AS "date Subtraction", 
	'2014-09-01 23:30:00'::timestamptz -'2014-09-01 22:00:00'::timestamptz= Interval '1 hour, 30 minutes' AS "Time stamp subtraction";

