SELECT 'a'::CHAR(2) = 'a '::CHAR(2) AS "Trailing space is ignored" ,length('a '::CHAR(10));
