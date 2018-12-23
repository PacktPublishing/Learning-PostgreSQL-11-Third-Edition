-- We are not allowed to insert, update, or delete data in read only mode. Also we can not create table
SET default_transaction_read_only to on;
CREATE TABLE test_readonly AS SELECT 1;
