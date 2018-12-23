SELECT 
	'a '::VARCHAR(2) = 'a '::TEXT AS "Text and varchar", 
	'a '::CHAR(2)    = 'a '::TEXT AS "Char and text", 
	'a '::CHAR(2)    = 'a '::VARCHAR(2) AS "Char and varchar";

SELECT length ('a '::CHAR(2)), length ('a '::VARCHAR(2));
