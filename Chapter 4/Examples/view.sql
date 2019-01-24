CREATE VIEW test AS
	 SELECT 1 as v;

CREATE VIEW test2 AS 
	SELECT v FROM test;

CREATE OR REPLACE VIEW test AS 
	SELECT 1 as val;

CREATE VIEW car_portal_app.account_information AS 
	SELECT account_id, first_name, last_name, email FROM car_portal_app.account;
\d car_portal_app.account_information

CREATE OR REPLACE VIEW car_portal_app.account_information (account_id,first_name,last_name,email) AS 
	SELECT account_id, first_name, last_name, email FROM car_portal_app.account;

CREATE OR REPLACE VIEW car_portal_app.account_information AS 
	SELECT account_id, last_name, first_name, email FROM car_portal_app.account;

CREATE MATERIALIZED VIEW test_mat AS 
	SELECT 1 WITH NO DATA;
TABLE test_mat;
REFRESH MATERIALIZED VIEW test_mat;
TABLE test_mat;

CREATE OR REPLACE VIEW car_portal_app.user_account AS 
	SELECT account_id, first_name, last_name, email, password  
	FROM car_portal_app.account 
	WHERE account_id NOT IN (SELECT account_id FROM  car_portal_app.seller_account);

INSERT INTO car_portal_app.user_account VALUES (default,'first_name1','last_name1','test1@email.com','password');

WITH account_info AS ( 
		INSERT INTO car_portal_app.user_account VALUES (default,'first_name2','last_name2','test2@email.com','password') RETURNING account_id
	) INSERT INTO car_portal_app.seller_account (account_id, street_name, street_number, zip_code, city) SELECT account_id, 'street1', '555', '555', 'test_city' FROM account_info;

DELETE FROM user_account WHERE first_name = 'first_name2';

CREATE TABLE check_option (val INT);
CREATE VIEW test_check_option AS SELECT * FROM check_option WHERE val > 0 WITH CHECK OPTION;
INSERT INTO test_check_option VALUES (-1);

SELECT table_name, is_insertable_into FROM information_schema.tables WHERE table_name = 'user_account';

