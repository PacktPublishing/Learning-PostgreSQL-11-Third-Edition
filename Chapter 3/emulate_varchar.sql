BEGIN;

--CREATE TABLE emulate_varchar(
--    test VARCHAR(4)
--);
--semantically equivalent to
CREATE TABLE emulate_varchar (
    test TEXT,
    CONSTRAINT test_length CHECK (length(test) <= 4)
);
ROLLBACK;
