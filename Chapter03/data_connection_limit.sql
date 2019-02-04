-- We use rollback because we do not want to persist the change
BEGIN;
SELECT datconnlimit FROM pg_database WHERE datname='postgres';
ALTER DATABASE postgres CONNECTION LIMIT 1;
SELECT datconnlimit FROM pg_database WHERE datname='postgres';
ROLLBACK;
