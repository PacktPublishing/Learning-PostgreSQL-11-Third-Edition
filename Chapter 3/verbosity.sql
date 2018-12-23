\set VERBOSITY 'verbose'
CREATE TABLE user AS SELECT 1;
BEGIN;
	\echo this will work 
	CREATE TABLE "user" AS SELECT 1;
ROLLBACK;
