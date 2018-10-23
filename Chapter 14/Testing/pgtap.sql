-- Isolate test scenario in its own transaction
BEGIN;
-- report 2 tests will be run
SELECT plan(5);
-- Validate the schema
SELECT has_table('counter_table');
SELECT has_column('counter_table', 'counter');
SELECT has_function('increment_counter');
-- Test 1. Call the increment function
SELECT lives_ok('SELECT increment_counter()','Call increment function');
-- Test 2. The results are correct
SELECT is( (SELECT ARRAY [COUNT(*), MAX(counter)]::text FROM counter_table), ARRAY [1, 0]::text,'The results are correct');
-- Report finish
SELECT finish();
-- Rollback changes made by the test
ROLLBACK;