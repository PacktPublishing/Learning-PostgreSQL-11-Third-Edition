BEGIN;

CREATE TABLE char_size_test (
  size CHAR(10)
);
CREATE TABLE varchar_size_test(
  size varchar(10)
);
WITH test_data AS (
  SELECT substring(md5(random()::text), 1, 5) FROM generate_series (1, 1000000)
),char_data_insert AS (
  INSERT INTO char_size_test SELECT * FROM test_data
)INSERT INTO varchar_size_test SELECT * FROM test_data;

\dt+ varchar_size_test
\dt+ char_size_test

ROLLBACK;
