CREATE EXTENSION hstore;
SELECT 'tires=>"winter tires", seat=>leather'::hstore;
SELECT hstore('Hello', 'World');
SELECT 'a=>1, a=>2'::hstore;

ALTER TABLE car_portal_app.car ADD COLUMN features hstore;
SELECT 'color=>red, Color=>blue'::hstore;

CREATE TABLE features (
	features hstore
);


INSERT INTO features (features) VALUES ('Engine=>Diesel'::hstore) RETURNING *;
-- To add a new key
UPDATE features SET features = features || hstore ('Seat', 'Lethear') RETURNING *;
-- To update a key, this is similar to add a key
UPDATE features SET features = features || hstore ('Engine', 'Petrol') RETURNING *;
-- To delete a key
UPDATE features SET features = features - 'Seat'::TEXT  RETURNING *;
SELECT DISTINCT (each(features)).key FROM features;
SELECT (each(features)).* FROM features;


CREATE INDEX ON features USING GIN (features);
SET enable_seqscan to off;
EXPLAIN SELECT features->'Engine' FROM features WHERE features ? 'Engine';

CREATE INDEX ON features ((features->'Engine'));
EXPLAIN SELECT features->'Engine' FROM features WHERE features->'Engine'= 'Diesel';