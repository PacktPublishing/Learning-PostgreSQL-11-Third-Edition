CREATE TABLE car_portal_app.car_log (LIKE car_portal_app.car);
ALTER TABLE car_portal_app.car_log ADD COLUMN car_log_action varchar (1) NOT NULL, ADD COLUMN car_log_time TIMESTAMP WITH TIME ZONE NOT NULL;
GRANT ALL ON car_portal_app.car_log to car_portal_app;

CREATE RULE car_log AS ON INSERT TO car_portal_app.car DO ALSO
INSERT INTO car_portal_app.car_log (car_id, car_model_id, number_of_owners, registration_number, number_of_doors, manufacture_year,car_log_action, car_log_time) 
	VALUES (new.car_id, new.car_model_id,new.number_of_owners, new.registration_number, new.number_of_doors, new.manufacture_year,'I', now());

INSERT INTO car_portal_app.car (car_id, car_model_id, number_of_owners, registration_number, number_of_doors, manufacture_year) VALUES (100000, 2, 2, 'x', 3, 2017);
SELECT to_json(car) FROM car_portal_app.car where registration_number ='x';
SELECT to_json(car_log) FROM car_portal_app.car_log where registration_number ='x';

INSERT INTO car_portal_app.car (car_id, car_model_id, number_of_owners, registration_number, number_of_doors, manufacture_year) VALUES (default, 2, 2, 'y', 3, 2017);
SELECT to_json(car) FROM car_portal_app.car where registration_number ='y';
SELECT to_json(car_log) FROM car_portal_app.car_log where registration_number ='y';