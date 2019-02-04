\echo get the time in Jerusalem
SET timezone TO 'Asia/jerusalem';
SELECT now();

\echo figure out conversion between timestamp with and without time zone
SHOW timezone;
\x
SELECT 
now() AS "Return current timestap in Jerusalem",
now()::timestamp AS "Return current timestap in Jerusalem with out time zone information", 
now() AT TIME ZONE 'CST' AS "Return current time in Central Standard Time without time zone information", 
'2018-08-19:00:00:00'::timestamp AT TIME ZONE 'CST' AS "Convert the time in CST to  Jerusalem time zone";
