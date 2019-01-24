WITH test_data(pi) AS (SELECT '{"pi":"3.14", "pi":"3.14" }') SELECT pi::JSON, pi::JSONB FROM test_data;
SELECT '{"name":"John", "Address":{"Street":"Some street", "city":"Some city"}, "rank":[5,3,4,5,2,3,4,5]}'::JSONB;

CREATE TABLE json_doc ( doc jsonb );
INSERT INTO json_doc SELECT '{"name":"John", "Address":{"Street":"Some street", "city":"Some city"}, "rank":[5,3,4,5,2,3,4,5]}'::JSONB ;

SELECT doc->'Address'->>'city', doc#>>'{Address, city}' FROM json_doc WHERE doc->>'name' = 'John';


SELECT (regexp_replace(doc::text, '"rank":(.*)],',''))::jsonb FROM json_doc WHERE doc->>'name' = 'John';

update json_doc SET doc = jsonb_insert(doc, '{hobby}','["swim", "read"]', true) RETURNING * ;
update json_doc SET doc = jsonb_set(doc, '{hobby}','["read"]', true) RETURNING * ;
update json_doc SET doc = doc -'hobby' RETURNING * ;

CREATE INDEX ON json_doc(doc);
SET enable_seqscan = off;

EXPLAIN SELECT * FROM json_doc WHERE doc @> '{"name":"John"}';


SELECT to_json (row(account_id,first_name, last_name, email)) FROM car_portal_app.account LIMIT 1;
SELECT to_json (account) FROM car_portal_app.account LIMIT 1;

WITH account_info(account_id, first_name, last_name, email) AS ( SELECT account_id,first_name, last_name, email FROM car_portal_app. account LIMIT 1
) SELECT to_json(account_info) FROM account_info;