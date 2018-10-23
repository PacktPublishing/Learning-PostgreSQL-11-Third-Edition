CREATE TABLE counter_table(counter int);

CREATE FUNCTION increment_counter() RETURNS void AS $$
BEGIN
  INSERT INTO counter_table SELECT count(*) FROM counter_table;
END;
$$ LANGUAGE plpgsql;

----------------------------------------------------------------

CREATE PROCEDURE test_increment() AS $$
DECLARE
  c int; m int;
BEGIN
  RAISE NOTICE '1..2';
  -- Test 1. Call the increment function
  BEGIN
    PERFORM increment_counter();
    RAISE NOTICE 'ok 1 - Call increment function';
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'not ok 1 - Call increment function';
  END;
  -- Test 2. The results are correct
  BEGIN
    SELECT COUNT(*), MAX(counter) INTO c, m FROM counter_table;
    IF NOT (c = 1 AND m = 0) THEN
      RAISE EXCEPTION 'Test 2: wrong values in output data';
    END IF;
    RAISE NOTICE 'ok 2 - Results are correct';
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'not ok 2 - Results are correct';
  END;
  ROLLBACK;
END;
$$ LANGUAGE plpgsql;

----------------------------------------------------------------

CALL test_increment();

----------------------------------------------------------------

ALTER TABLE counter_table ADD insert_time timestamp with time zone NOT NULL;

----------------------------------------------------------------

CALL test_increment();

----------------------------------------------------------------

CREATE OR REPLACE FUNCTION increment_counter() RETURNS void AS $$
BEGIN
  INSERT INTO counter_table SELECT count(*), now() FROM counter_table;
END;
$$ LANGUAGE plpgsql;

----------------------------------------------------------------

CALL test_increment();

----------------------------------------------------------------

CREATE OR REPLACE PROCEDURE test_increment() AS $$
DECLARE
  c int; m int;
  msg_text text; exception_detail text; exception_hint text;
BEGIN
  RAISE NOTICE '1..3';
  -- Test 1. Call increment function
  BEGIN
    PERFORM increment_counter();
    RAISE NOTICE 'ok 1 - Call increment function';
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'not ok 1 - Call increment function';
    GET STACKED DIAGNOSTICS 
      msg_text = MESSAGE_TEXT,
      exception_detail = PG_EXCEPTION_DETAIL,
      exception_hint = PG_EXCEPTION_HINT;        
    RAISE NOTICE 'Exception: % % %', msg_text, exception_detail, exception_hint;
  END;
  -- Test 2. The results are correct for the first record
  BEGIN
    SELECT COUNT(*), MAX(counter) INTO c, m FROM counter_table;
    IF NOT (c = 1 AND m = 0) THEN
      RAISE EXCEPTION 'Test 2: wrong values in output data for the first record';
    END IF;
    RAISE NOTICE 'ok 2 - The results are correct for the first record';
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'not ok 2 - The results are correct for the first record';
    GET STACKED DIAGNOSTICS 
      msg_text = MESSAGE_TEXT,
      exception_detail = PG_EXCEPTION_DETAIL,
      exception_hint = PG_EXCEPTION_HINT;        
    RAISE NOTICE 'Exception: % % %', msg_text, exception_detail, exception_hint;
  END;
  -- Test 3. The results are correct for the second record
  BEGIN
    PERFORM increment_counter();
    SELECT COUNT(*), MAX(counter) INTO c, m FROM counter_table;
    IF NOT (c = 2 AND m = 1) THEN
      RAISE EXCEPTION 'Test 3: wrong values in output data for the second record';
    END IF;
    RAISE NOTICE 'ok 3 - The results are correct for the second record';
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'not ok 3 - The results are correct for the second record';
    GET STACKED DIAGNOSTICS 
      msg_text = MESSAGE_TEXT,
      exception_detail = PG_EXCEPTION_DETAIL,
      exception_hint = PG_EXCEPTION_HINT;        
    RAISE NOTICE 'Exception: % % %', msg_text, exception_detail, exception_hint;
  END;
  ROLLBACK;
END;
$$ LANGUAGE plpgsql;

----------------------------------------------------------------

CREATE EXTENSION pgtap;

\t
\i pgtap.sql
\t

----------------------------------------------------------------

SET role postgres;
\c postgres
DROP DATABASE IF EXISTS  car_portal_new;
CREATE DATABASE car_portal_new TEMPLATE car_portal OWNER car_portal_app;
\c car_portal_new

----------------------------------------------------------------

ALTER TABLE car_portal_app.car ADD insert_date timestamp with time zone DEFAULT now();

----------------------------------------------------------------

CREATE EXTENSION postgres_fdw ;

----------------------------------------------------------------

CREATE SERVER car_portal_original FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host 'localhost', dbname 'car_portal');

----------------------------------------------------------------

CREATE USER MAPPING FOR CURRENT_USER SERVER car_portal_original;

----------------------------------------------------------------

CREATE FOREIGN TABLE car_portal_app.car_orignal (car_id int, number_of_owners int, registration_number text, 
    manufacture_year int, number_of_doors int, car_model_id int, mileage int) 
  SERVER car_portal_original OPTIONS (table_name 'car');

----------------------------------------------------------------

SELECT car_id FROM car_portal_app.car_orignal limit 1;

----------------------------------------------------------------

WITH n AS (
  SELECT car_id, number_of_owners, registration_number, manufacture_year, number_of_doors, 
      car_model_id, mileage
    FROM car_portal_app.car),
o AS (SELECT * FROM car_portal_app.car_orignal)
SELECT 'new', * FROM (SELECT * FROM n EXCEPT ALL SELECT * FROM o) a
UNION ALL
SELECT 'old', * FROM (SELECT * FROM o EXCEPT ALL SELECT * FROM n) b;

----------------------------------------------------------------

\c car_portal
SET ROLE car_portal_app;

----------------------------------------------------------------

\timing
SELECT count(*) FROM car_portal_app.car;
