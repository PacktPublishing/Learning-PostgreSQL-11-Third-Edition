BEGIN;
CREATE TABLE customer (
  customer_id SERIAL
);
\echo Describe the table, note the Type and the Deafult 
\d+ customer
\echo Describe the sequence created by using serial 
\ds customer_customer_id_seq
ROLLBACK;

