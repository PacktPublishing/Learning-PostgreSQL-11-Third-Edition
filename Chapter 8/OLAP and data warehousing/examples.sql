---------------------------------------------------

CREATE TABLE dwh.access_log
(
  ts timestamp with time zone, 
  remote_address text,
  remote_user text,
  url text,
  status_code int,
  body_size int,
  http_referer text,
  http_user_agent text
);

---------------------------------------------------

\copy dwh.access_log FROM 'access.log' WITH csv delimiter ';'

---------------------------------------------------

ALTER TABLE dwh.access_log ADD car_id int;

---------------------------------------------------

UPDATE dwh.access_log SET car_id = (SELECT regexp_matches(url, '/api/cars/(\d+)\W'))[1]::int WHERE url like '%/api/cars/%';

---------------------------------------------------

CREATE TABLE dwh.access_log_partitioned (ts timestamptz, url text, status_code int) 
PARTITION BY RANGE (ts);

---------------------------------------------------

CREATE TABLE dwh.access_log_2018_07 PARTITION OF dwh.access_log_partitioned 
FOR VALUES FROM ('2018-07-01') TO ('2018-08-01');

CREATE TABLE dwh.access_log_2018_08 PARTITION OF dwh.access_log_partitioned 
FOR VALUES FROM ('2018-08-01') TO ('2018-09-01');

CREATE TABLE dwh.access_log_2018_09 PARTITION OF dwh.access_log_partitioned 
FOR VALUES FROM ('2018-09-01') TO ('2018-10-01');

---------------------------------------------------
-- expected to FAIL
INSERT INTO dwh.access_log_partitioned values ('2018-02-01', '/test', 404);

---------------------------------------------------

CREATE TABLE dwh.access_log_min PARTITION OF dwh.access_log_partitioned 
FOR VALUES FROM (MINVALUE) TO ('2018-07-01');

---------------------------------------------------

CREATE TABLE dwh.access_log_default PARTITION OF dwh.access_log_partitioned DEFAULT;

---------------------------------------------------

CREATE TABLE dwh.access_log_2018_10 PARTITION OF dwh.access_log_partitioned 
FOR VALUES FROM ('2018-10-01') TO ('2018-11-01')
PARTITION BY LIST (status_code);

CREATE TABLE dwh.access_log_2018_10_200 PARTITION OF dwh.access_log_2018_10 FOR VALUES IN (200);

CREATE TABLE dwh.access_log_2018_10_400 PARTITION OF dwh.access_log_2018_10 FOR VALUES IN (400);

---------------------------------------------------

CREATE TABLE dwh.access_log_2018_11 PARTITION OF dwh.access_log_partitioned 
FOR VALUES FROM ('2018-11-01') TO ('2018-12-01')
PARTITION BY LIST (left(status_code::text, 1));

CREATE TABLE dwh.access_log_2018_11_2XX PARTITION OF dwh.access_log_2018_11 FOR VALUES IN ('2');

CREATE TABLE dwh.access_log_2018_11_4XX PARTITION OF dwh.access_log_2018_11 FOR VALUES IN ('4');

---------------------------------------------------

CREATE TABLE dwh.access_log_2018_12 PARTITION OF dwh.access_log_partitioned 
FOR VALUES FROM ('2018-12-01') TO ('2019-01-01')
PARTITION BY HASH (url);

CREATE TABLE dwh.access_log_2018_12_1 PARTITION OF dwh.access_log_2018_12 FOR VALUES WITH (MODULUS 3, REMAINDER 0);

CREATE TABLE dwh.access_log_2018_12_2 PARTITION OF dwh.access_log_2018_12 FOR VALUES WITH (MODULUS 3, REMAINDER 1);

CREATE TABLE dwh.access_log_2018_12_3 PARTITION OF dwh.access_log_2018_12 FOR VALUES WITH (MODULUS 3, REMAINDER 2);

---------------------------------------------------

ALTER TABLE dwh.access_log_partitioned DETACH PARTITION dwh.access_log_2018_11;

---------------------------------------------------

ALTER TABLE dwh.access_log_partitioned ATTACH PARTITION dwh.access_log_2018_11 
FOR VALUES FROM ('2018-11-01') TO ('2018-12-01');

---------------------------------------------------

CREATE TABLE dwh.access_log_not_partitioned (LIKE dwh.access_log_partitioned);

---------------------------------------------------

INSERT INTO dwh.access_log_not_partitioned SELECT ts, url, status_code FROM dwh.access_log, generate_series(1, 1000);
INSERT INTO dwh.access_log_partitioned SELECT ts, url, status_code FROM dwh.access_log, generate_series(1, 1000);

---------------------------------------------------

\timing
SELECT count(*) FROM dwh.access_log_not_partitioned WHERE ts >= '2018-08-22' AND ts < '2018-09-01';
SELECT count(*) FROM dwh.access_log_partitioned WHERE ts >= '2018-08-22' AND ts < '2018-09-01';

---------------------------------------------------

EXPLAIN SELECT count(*) FROM dwh.access_log_partitioned WHERE ts >= '2018-08-22' AND ts < '2018-09-01';

---------------------------------------------------

SET max_parallel_workers_per_gather = 0;

---------------------------------------------------

SELECT count(*) FROM dwh.access_log_not_partitioned WHERE url ~ 'car';

---------------------------------------------------

SET max_parallel_workers_per_gather = 1;

---------------------------------------------------

SELECT count(*) FROM dwh.access_log_not_partitioned WHERE url ~ 'car';

---------------------------------------------------

CREATE INDEX ON dwh.access_log_not_partitioned (ts, status_code);

---------------------------------------------------

SELECT min(ts) FROM dwh.access_log_not_partitioned WHERE ts BETWEEN '2018-08-01' AND '2018-08-02' AND status_code = '201';

---------------------------------------------------

EXPLAIN SELECT min(ts) FROM dwh.access_log_not_partitioned WHERE ts BETWEEN '2018-08-01' AND '2018-08-02' AND status_code = '201';

---------------------------------------------------

SET enable_indexonlyscan = off;

---------------------------------------------------

SELECT min(ts) FROM dwh.access_log_not_partitioned WHERE ts BETWEEN '2018-08-01' AND '2018-08-02' AND status_code = '201';

---------------------------------------------------

EXPLAIN SELECT min(ts) FROM dwh.access_log_not_partitioned WHERE ts BETWEEN '2018-08-01' AND '2018-08-02' AND status_code = '201';

---------------------------------------------------

CREATE INDEX ON dwh.access_log_not_partitioned (ts) WHERE status_code = 201;
EXPLAIN SELECT min(ts) FROM dwh.access_log_not_partitioned WHERE ts BETWEEN '2018-08-01' AND '2018-08-02' AND status_code = '201';

---------------------------------------------------

CREATE INDEX ON dwh.access_log_partitioned (ts) INCLUDE (url);
EXPLAIN SELECT DISTINCT url FROM dwh.access_log_partitioned WHERE ts BETWEEN '2018-07-15' AND '2018-08-15';