--
-- PostgreSQL database dump
--

-- Dumped from database version 11beta2 (Debian 11~beta2-1.pgdg90+1)
-- Dumped by pg_dump version 11beta2 (Debian 11~beta2-1.pgdg90+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: car_portal_app; Type: SCHEMA; Schema: -; Owner: car_portal_app
--

CREATE SCHEMA car_portal_app;


ALTER SCHEMA car_portal_app OWNER TO car_portal_app;

--
-- Name: dwh; Type: SCHEMA; Schema: -; Owner: car_portal_app
--

CREATE SCHEMA dwh;


ALTER SCHEMA dwh OWNER TO car_portal_app;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pgtap; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pgtap WITH SCHEMA dwh;


--
-- Name: EXTENSION pgtap; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgtap IS 'Unit testing for PostgreSQL';


SET search_path = dwh, pg_catalog;

--
-- Name: increment_counter(); Type: FUNCTION; Schema: dwh; Owner: car_portal_app
--

CREATE FUNCTION increment_counter() RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    INSERT INTO counter_table SELECT count(*), now() FROM counter_table;
  END;
$$;


ALTER FUNCTION dwh.increment_counter() OWNER TO car_portal_app;

--
-- Name: test_increment(); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.test_increment()
    LANGUAGE plpgsql
    AS $$
DECLARE
  c int; m int;
  msg_text text; exception_detail text; exception_hint text;
BEGIN
  RAISE NOTICE '1..3';
  -- Test 1. Call increment function
  BEGIN
    PERFORM increment_counter();
    RAISE NOTICE 'ok 1 - Call increment function';
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'not ok 1 - Call increment function';
    GET STACKED DIAGNOSTICS 
      msg_text = MESSAGE_TEXT,
      exception_detail = PG_EXCEPTION_DETAIL,
      exception_hint = PG_EXCEPTION_HINT;        
    RAISE NOTICE 'Exception: % % %', msg_text, exception_detail, exception_hint;
  END;
  -- Test 2. The results are correct for the first record
  BEGIN
    SELECT COUNT(*), MAX(counter) INTO c, m FROM counter_table;
    IF NOT (c = 1 AND m = 0) THEN
      RAISE EXCEPTION 'Test 2: wrong values in output data for the first record';
    END IF;
    RAISE NOTICE 'ok 2 - The results are correct for the first record';
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'not ok 2 - The results are correct for the first record';
    GET STACKED DIAGNOSTICS 
      msg_text = MESSAGE_TEXT,
      exception_detail = PG_EXCEPTION_DETAIL,
      exception_hint = PG_EXCEPTION_HINT;        
    RAISE NOTICE 'Exception: % % %', msg_text, exception_detail, exception_hint;
  END;
  -- Test 3. The results are correct for the second record
  BEGIN
    PERFORM increment_counter();
    SELECT COUNT(*), MAX(counter) INTO c, m FROM counter_table;
    IF NOT (c = 2 AND m = 1) THEN
      RAISE EXCEPTION 'Test 3: wrong values in output data for the second record';
    END IF;
    RAISE NOTICE 'ok 3 - The results are correct for the second record';
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'not ok 3 - The results are correct for the second record';
    GET STACKED DIAGNOSTICS 
      msg_text = MESSAGE_TEXT,
      exception_detail = PG_EXCEPTION_DETAIL,
      exception_hint = PG_EXCEPTION_HINT;        
    RAISE NOTICE 'Exception: % % %', msg_text, exception_detail, exception_hint;
  END;
  ROLLBACK;
END;
$$;


ALTER PROCEDURE public.test_increment() OWNER TO postgres;

SET search_path = car_portal_app, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: account; Type: TABLE; Schema: car_portal_app; Owner: car_portal_app
--

CREATE TABLE account (
    account_id integer NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    email text NOT NULL,
    password text NOT NULL,
    CONSTRAINT account_check CHECK (((first_name !~ '\s'::text) AND (last_name !~ '\s'::text))),
    CONSTRAINT account_email_check CHECK ((email ~* '^\w+@\w+[.]\w+$'::text)),
    CONSTRAINT account_password_check CHECK ((char_length(password) >= 8))
);


ALTER TABLE account OWNER TO car_portal_app;

--
-- Name: account_account_id_seq; Type: SEQUENCE; Schema: car_portal_app; Owner: car_portal_app
--

CREATE SEQUENCE account_account_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE account_account_id_seq OWNER TO car_portal_app;

--
-- Name: account_account_id_seq; Type: SEQUENCE OWNED BY; Schema: car_portal_app; Owner: car_portal_app
--

ALTER SEQUENCE account_account_id_seq OWNED BY account.account_id;


--
-- Name: account_history; Type: TABLE; Schema: car_portal_app; Owner: car_portal_app
--

CREATE TABLE account_history (
    account_history_id bigint NOT NULL,
    account_id integer NOT NULL,
    search_key text NOT NULL,
    search_date date NOT NULL
);


ALTER TABLE account_history OWNER TO car_portal_app;

--
-- Name: account_history_account_history_id_seq; Type: SEQUENCE; Schema: car_portal_app; Owner: car_portal_app
--

CREATE SEQUENCE account_history_account_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE account_history_account_history_id_seq OWNER TO car_portal_app;

--
-- Name: account_history_account_history_id_seq; Type: SEQUENCE OWNED BY; Schema: car_portal_app; Owner: car_portal_app
--

ALTER SEQUENCE account_history_account_history_id_seq OWNED BY account_history.account_history_id;


--
-- Name: advertisement; Type: TABLE; Schema: car_portal_app; Owner: car_portal_app
--

CREATE TABLE advertisement (
    advertisement_id integer NOT NULL,
    advertisement_date timestamp with time zone NOT NULL,
    car_id integer NOT NULL,
    seller_account_id integer NOT NULL
);


ALTER TABLE advertisement OWNER TO car_portal_app;

--
-- Name: advertisement_advertisement_id_seq; Type: SEQUENCE; Schema: car_portal_app; Owner: car_portal_app
--

CREATE SEQUENCE advertisement_advertisement_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE advertisement_advertisement_id_seq OWNER TO car_portal_app;

--
-- Name: advertisement_advertisement_id_seq; Type: SEQUENCE OWNED BY; Schema: car_portal_app; Owner: car_portal_app
--

ALTER SEQUENCE advertisement_advertisement_id_seq OWNED BY advertisement.advertisement_id;


--
-- Name: advertisement_picture; Type: TABLE; Schema: car_portal_app; Owner: car_portal_app
--

CREATE TABLE advertisement_picture (
    advertisement_picture_id integer NOT NULL,
    advertisement_id integer,
    picture_location text
);


ALTER TABLE advertisement_picture OWNER TO car_portal_app;

--
-- Name: advertisement_picture_advertisement_picture_id_seq; Type: SEQUENCE; Schema: car_portal_app; Owner: car_portal_app
--

CREATE SEQUENCE advertisement_picture_advertisement_picture_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE advertisement_picture_advertisement_picture_id_seq OWNER TO car_portal_app;

--
-- Name: advertisement_picture_advertisement_picture_id_seq; Type: SEQUENCE OWNED BY; Schema: car_portal_app; Owner: car_portal_app
--

ALTER SEQUENCE advertisement_picture_advertisement_picture_id_seq OWNED BY advertisement_picture.advertisement_picture_id;


--
-- Name: advertisement_rating; Type: TABLE; Schema: car_portal_app; Owner: car_portal_app
--

CREATE TABLE advertisement_rating (
    advertisement_rating_id integer NOT NULL,
    advertisement_id integer NOT NULL,
    account_id integer NOT NULL,
    advertisement_rating_date date NOT NULL,
    rank integer NOT NULL,
    review text NOT NULL,
    CONSTRAINT advertisement_rating_rank_check CHECK ((rank = ANY (ARRAY[1, 2, 3, 4, 5]))),
    CONSTRAINT advertisement_rating_review_check CHECK ((char_length(review) <= 200))
);


ALTER TABLE advertisement_rating OWNER TO car_portal_app;

--
-- Name: advertisement_rating_advertisement_rating_id_seq; Type: SEQUENCE; Schema: car_portal_app; Owner: car_portal_app
--

CREATE SEQUENCE advertisement_rating_advertisement_rating_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE advertisement_rating_advertisement_rating_id_seq OWNER TO car_portal_app;

--
-- Name: advertisement_rating_advertisement_rating_id_seq; Type: SEQUENCE OWNED BY; Schema: car_portal_app; Owner: car_portal_app
--

ALTER SEQUENCE advertisement_rating_advertisement_rating_id_seq OWNED BY advertisement_rating.advertisement_rating_id;


--
-- Name: car; Type: TABLE; Schema: car_portal_app; Owner: car_portal_app
--

CREATE TABLE car (
    car_id integer NOT NULL,
    number_of_owners integer NOT NULL,
    registration_number text NOT NULL,
    manufacture_year integer NOT NULL,
    number_of_doors integer DEFAULT 5 NOT NULL,
    car_model_id integer NOT NULL,
    mileage integer
);


ALTER TABLE car OWNER TO car_portal_app;

--
-- Name: car_car_id_seq; Type: SEQUENCE; Schema: car_portal_app; Owner: car_portal_app
--

CREATE SEQUENCE car_car_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE car_car_id_seq OWNER TO car_portal_app;

--
-- Name: car_car_id_seq; Type: SEQUENCE OWNED BY; Schema: car_portal_app; Owner: car_portal_app
--

ALTER SEQUENCE car_car_id_seq OWNED BY car.car_id;


--
-- Name: car_model; Type: TABLE; Schema: car_portal_app; Owner: car_portal_app
--

CREATE TABLE car_model (
    car_model_id integer NOT NULL,
    make text,
    model text
);


ALTER TABLE car_model OWNER TO car_portal_app;

--
-- Name: car_model_car_model_id_seq; Type: SEQUENCE; Schema: car_portal_app; Owner: car_portal_app
--

CREATE SEQUENCE car_model_car_model_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE car_model_car_model_id_seq OWNER TO car_portal_app;

--
-- Name: car_model_car_model_id_seq; Type: SEQUENCE OWNED BY; Schema: car_portal_app; Owner: car_portal_app
--

ALTER SEQUENCE car_model_car_model_id_seq OWNED BY car_model.car_model_id;


--
-- Name: favorite_ads; Type: TABLE; Schema: car_portal_app; Owner: car_portal_app
--

CREATE TABLE favorite_ads (
    account_id integer NOT NULL,
    advertisement_id integer NOT NULL
);


ALTER TABLE favorite_ads OWNER TO car_portal_app;

--
-- Name: seller_account; Type: TABLE; Schema: car_portal_app; Owner: car_portal_app
--

CREATE TABLE seller_account (
    seller_account_id integer NOT NULL,
    account_id integer NOT NULL,
    total_rank double precision,
    number_of_advertisement integer,
    street_name text NOT NULL,
    street_number text NOT NULL,
    zip_code text NOT NULL,
    city text NOT NULL
);


ALTER TABLE seller_account OWNER TO car_portal_app;

--
-- Name: seller_account_seller_account_id_seq; Type: SEQUENCE; Schema: car_portal_app; Owner: car_portal_app
--

CREATE SEQUENCE seller_account_seller_account_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE seller_account_seller_account_id_seq OWNER TO car_portal_app;

--
-- Name: seller_account_seller_account_id_seq; Type: SEQUENCE OWNED BY; Schema: car_portal_app; Owner: car_portal_app
--

ALTER SEQUENCE seller_account_seller_account_id_seq OWNED BY seller_account.seller_account_id;


SET search_path = dwh, pg_catalog;

--
-- Name: access_log; Type: TABLE; Schema: dwh; Owner: car_portal_app
--

CREATE TABLE access_log (
    ts timestamp with time zone,
    remote_address text,
    remote_user text,
    url text,
    status_code integer,
    body_size integer,
    http_referer text,
    http_user_agent text,
    car_id integer
);


ALTER TABLE access_log OWNER TO car_portal_app;

--
-- Name: access_log_partitioned; Type: TABLE; Schema: dwh; Owner: car_portal_app
--

CREATE TABLE access_log_partitioned (
    ts timestamp with time zone,
    url text,
    status_code integer
)
PARTITION BY RANGE (ts);


ALTER TABLE access_log_partitioned OWNER TO car_portal_app;

--
-- Name: access_log_2017_07; Type: TABLE; Schema: dwh; Owner: car_portal_app
--

CREATE TABLE access_log_2017_07 PARTITION OF access_log_partitioned
FOR VALUES FROM ('2017-07-01 00:00:00+00') TO ('2017-08-01 00:00:00+00');


ALTER TABLE access_log_2017_07 OWNER TO car_portal_app;

--
-- Name: access_log_2017_08; Type: TABLE; Schema: dwh; Owner: car_portal_app
--

CREATE TABLE access_log_2017_08 PARTITION OF access_log_partitioned
FOR VALUES FROM ('2017-08-01 00:00:00+00') TO ('2017-09-01 00:00:00+00');


ALTER TABLE access_log_2017_08 OWNER TO car_portal_app;

--
-- Name: access_log_2017_09; Type: TABLE; Schema: dwh; Owner: car_portal_app
--

CREATE TABLE access_log_2017_09 PARTITION OF access_log_partitioned
FOR VALUES FROM ('2017-09-01 00:00:00+00') TO ('2017-10-01 00:00:00+00');


ALTER TABLE access_log_2017_09 OWNER TO car_portal_app;

--
-- Name: access_log_2017_10; Type: TABLE; Schema: dwh; Owner: car_portal_app
--

CREATE TABLE access_log_2017_10 PARTITION OF access_log_partitioned
FOR VALUES FROM ('2017-10-01 00:00:00+00') TO ('2017-11-01 00:00:00+00')
PARTITION BY LIST (status_code);


ALTER TABLE access_log_2017_10 OWNER TO car_portal_app;

--
-- Name: access_log_2017_10_200; Type: TABLE; Schema: dwh; Owner: car_portal_app
--

CREATE TABLE access_log_2017_10_200 PARTITION OF access_log_2017_10
FOR VALUES IN (200);


ALTER TABLE access_log_2017_10_200 OWNER TO car_portal_app;

--
-- Name: access_log_2017_10_400; Type: TABLE; Schema: dwh; Owner: car_portal_app
--

CREATE TABLE access_log_2017_10_400 PARTITION OF access_log_2017_10
FOR VALUES IN (400);


ALTER TABLE access_log_2017_10_400 OWNER TO car_portal_app;

--
-- Name: access_log_2017_11; Type: TABLE; Schema: dwh; Owner: car_portal_app
--

CREATE TABLE access_log_2017_11 PARTITION OF access_log_partitioned
FOR VALUES FROM ('2017-11-01 00:00:00+00') TO ('2017-12-01 00:00:00+00')
PARTITION BY LIST ("left"((status_code)::text, 1));


ALTER TABLE access_log_2017_11 OWNER TO car_portal_app;

--
-- Name: access_log_2017_11_2xx; Type: TABLE; Schema: dwh; Owner: car_portal_app
--

CREATE TABLE access_log_2017_11_2xx PARTITION OF access_log_2017_11
FOR VALUES IN ('2');


ALTER TABLE access_log_2017_11_2xx OWNER TO car_portal_app;

--
-- Name: access_log_2017_11_4xx; Type: TABLE; Schema: dwh; Owner: car_portal_app
--

CREATE TABLE access_log_2017_11_4xx PARTITION OF access_log_2017_11
FOR VALUES IN ('4');


ALTER TABLE access_log_2017_11_4xx OWNER TO car_portal_app;

--
-- Name: access_log_min; Type: TABLE; Schema: dwh; Owner: car_portal_app
--

CREATE TABLE access_log_min PARTITION OF access_log_partitioned
FOR VALUES FROM (MINVALUE) TO ('2017-07-01 00:00:00+00');


ALTER TABLE access_log_min OWNER TO car_portal_app;

--
-- Name: access_log_not_partitioned; Type: TABLE; Schema: dwh; Owner: car_portal_app
--

CREATE TABLE access_log_not_partitioned (
    ts timestamp with time zone,
    url text,
    status_code integer
);


ALTER TABLE access_log_not_partitioned OWNER TO car_portal_app;

--
-- Name: counter_table; Type: TABLE; Schema: dwh; Owner: car_portal_app
--

CREATE TABLE counter_table (
    counter integer,
    insert_time timestamp with time zone NOT NULL
);


ALTER TABLE counter_table OWNER TO car_portal_app;

SET search_path = car_portal_app, pg_catalog;

--
-- Name: account account_id; Type: DEFAULT; Schema: car_portal_app; Owner: car_portal_app
--

ALTER TABLE ONLY account ALTER COLUMN account_id SET DEFAULT nextval('account_account_id_seq'::regclass);


--
-- Name: account_history account_history_id; Type: DEFAULT; Schema: car_portal_app; Owner: car_portal_app
--

ALTER TABLE ONLY account_history ALTER COLUMN account_history_id SET DEFAULT nextval('account_history_account_history_id_seq'::regclass);


--
-- Name: advertisement advertisement_id; Type: DEFAULT; Schema: car_portal_app; Owner: car_portal_app
--

ALTER TABLE ONLY advertisement ALTER COLUMN advertisement_id SET DEFAULT nextval('advertisement_advertisement_id_seq'::regclass);


--
-- Name: advertisement_picture advertisement_picture_id; Type: DEFAULT; Schema: car_portal_app; Owner: car_portal_app
--

ALTER TABLE ONLY advertisement_picture ALTER COLUMN advertisement_picture_id SET DEFAULT nextval('advertisement_picture_advertisement_picture_id_seq'::regclass);


--
-- Name: advertisement_rating advertisement_rating_id; Type: DEFAULT; Schema: car_portal_app; Owner: car_portal_app
--

ALTER TABLE ONLY advertisement_rating ALTER COLUMN advertisement_rating_id SET DEFAULT nextval('advertisement_rating_advertisement_rating_id_seq'::regclass);


--
-- Name: car car_id; Type: DEFAULT; Schema: car_portal_app; Owner: car_portal_app
--

ALTER TABLE ONLY car ALTER COLUMN car_id SET DEFAULT nextval('car_car_id_seq'::regclass);


--
-- Name: car_model car_model_id; Type: DEFAULT; Schema: car_portal_app; Owner: car_portal_app
--

ALTER TABLE ONLY car_model ALTER COLUMN car_model_id SET DEFAULT nextval('car_model_car_model_id_seq'::regclass);


--
-- Name: seller_account seller_account_id; Type: DEFAULT; Schema: car_portal_app; Owner: car_portal_app
--

ALTER TABLE ONLY seller_account ALTER COLUMN seller_account_id SET DEFAULT nextval('seller_account_seller_account_id_seq'::regclass);


--
-- Name: account account_email_key; Type: CONSTRAINT; Schema: car_portal_app; Owner: car_portal_app
--

ALTER TABLE ONLY account
    ADD CONSTRAINT account_email_key UNIQUE (email);


--
-- Name: account_history account_history_account_id_search_key_search_date_key; Type: CONSTRAINT; Schema: car_portal_app; Owner: car_portal_app
--

ALTER TABLE ONLY account_history
    ADD CONSTRAINT account_history_account_id_search_key_search_date_key UNIQUE (account_id, search_key, search_date);


--
-- Name: account_history account_history_pkey; Type: CONSTRAINT; Schema: car_portal_app; Owner: car_portal_app
--

ALTER TABLE ONLY account_history
    ADD CONSTRAINT account_history_pkey PRIMARY KEY (account_history_id);


--
-- Name: account account_pkey; Type: CONSTRAINT; Schema: car_portal_app; Owner: car_portal_app
--

ALTER TABLE ONLY account
    ADD CONSTRAINT account_pkey PRIMARY KEY (account_id);


--
-- Name: advertisement_picture advertisement_picture_picture_location_key; Type: CONSTRAINT; Schema: car_portal_app; Owner: car_portal_app
--

ALTER TABLE ONLY advertisement_picture
    ADD CONSTRAINT advertisement_picture_picture_location_key UNIQUE (picture_location);


--
-- Name: advertisement_picture advertisement_picture_pkey; Type: CONSTRAINT; Schema: car_portal_app; Owner: car_portal_app
--

ALTER TABLE ONLY advertisement_picture
    ADD CONSTRAINT advertisement_picture_pkey PRIMARY KEY (advertisement_picture_id);


--
-- Name: advertisement advertisement_pkey; Type: CONSTRAINT; Schema: car_portal_app; Owner: car_portal_app
--

ALTER TABLE ONLY advertisement
    ADD CONSTRAINT advertisement_pkey PRIMARY KEY (advertisement_id);


--
-- Name: advertisement_rating advertisement_rating_pkey; Type: CONSTRAINT; Schema: car_portal_app; Owner: car_portal_app
--

ALTER TABLE ONLY advertisement_rating
    ADD CONSTRAINT advertisement_rating_pkey PRIMARY KEY (advertisement_rating_id);


--
-- Name: car_model car_model_make_model_key; Type: CONSTRAINT; Schema: car_portal_app; Owner: car_portal_app
--

ALTER TABLE ONLY car_model
    ADD CONSTRAINT car_model_make_model_key UNIQUE (make, model);


--
-- Name: car_model car_model_pkey; Type: CONSTRAINT; Schema: car_portal_app; Owner: car_portal_app
--

ALTER TABLE ONLY car_model
    ADD CONSTRAINT car_model_pkey PRIMARY KEY (car_model_id);


--
-- Name: car car_pkey; Type: CONSTRAINT; Schema: car_portal_app; Owner: car_portal_app
--

ALTER TABLE ONLY car
    ADD CONSTRAINT car_pkey PRIMARY KEY (car_id);


--
-- Name: car car_registration_number_key; Type: CONSTRAINT; Schema: car_portal_app; Owner: car_portal_app
--

ALTER TABLE ONLY car
    ADD CONSTRAINT car_registration_number_key UNIQUE (registration_number);


--
-- Name: favorite_ads favorite_ads_pkey; Type: CONSTRAINT; Schema: car_portal_app; Owner: car_portal_app
--

ALTER TABLE ONLY favorite_ads
    ADD CONSTRAINT favorite_ads_pkey PRIMARY KEY (account_id, advertisement_id);


--
-- Name: seller_account seller_account_pkey; Type: CONSTRAINT; Schema: car_portal_app; Owner: car_portal_app
--

ALTER TABLE ONLY seller_account
    ADD CONSTRAINT seller_account_pkey PRIMARY KEY (seller_account_id);


SET search_path = dwh, pg_catalog;

--
-- Name: access_log_not_partitioned_ts_status_code_idx; Type: INDEX; Schema: dwh; Owner: car_portal_app
--

CREATE INDEX access_log_not_partitioned_ts_status_code_idx ON access_log_not_partitioned USING btree (ts, status_code);


SET search_path = car_portal_app, pg_catalog;

--
-- Name: account_history account_history_account_id_fkey; Type: FK CONSTRAINT; Schema: car_portal_app; Owner: car_portal_app
--

ALTER TABLE ONLY account_history
    ADD CONSTRAINT account_history_account_id_fkey FOREIGN KEY (account_id) REFERENCES account(account_id);


--
-- Name: advertisement advertisement_car_id_fkey; Type: FK CONSTRAINT; Schema: car_portal_app; Owner: car_portal_app
--

ALTER TABLE ONLY advertisement
    ADD CONSTRAINT advertisement_car_id_fkey FOREIGN KEY (car_id) REFERENCES car(car_id);


--
-- Name: advertisement_picture advertisement_picture_advertisement_id_fkey; Type: FK CONSTRAINT; Schema: car_portal_app; Owner: car_portal_app
--

ALTER TABLE ONLY advertisement_picture
    ADD CONSTRAINT advertisement_picture_advertisement_id_fkey FOREIGN KEY (advertisement_id) REFERENCES advertisement(advertisement_id);


--
-- Name: advertisement_rating advertisement_rating_account_id_fkey; Type: FK CONSTRAINT; Schema: car_portal_app; Owner: car_portal_app
--

ALTER TABLE ONLY advertisement_rating
    ADD CONSTRAINT advertisement_rating_account_id_fkey FOREIGN KEY (account_id) REFERENCES account(account_id);


--
-- Name: advertisement_rating advertisement_rating_advertisement_id_fkey; Type: FK CONSTRAINT; Schema: car_portal_app; Owner: car_portal_app
--

ALTER TABLE ONLY advertisement_rating
    ADD CONSTRAINT advertisement_rating_advertisement_id_fkey FOREIGN KEY (advertisement_id) REFERENCES advertisement(advertisement_id);


--
-- Name: advertisement advertisement_seller_account_id_fkey; Type: FK CONSTRAINT; Schema: car_portal_app; Owner: car_portal_app
--

ALTER TABLE ONLY advertisement
    ADD CONSTRAINT advertisement_seller_account_id_fkey FOREIGN KEY (seller_account_id) REFERENCES seller_account(seller_account_id);


--
-- Name: car car_car_model_id_fkey; Type: FK CONSTRAINT; Schema: car_portal_app; Owner: car_portal_app
--

ALTER TABLE ONLY car
    ADD CONSTRAINT car_car_model_id_fkey FOREIGN KEY (car_model_id) REFERENCES car_model(car_model_id);


--
-- Name: favorite_ads favorite_ads_account_id_fkey; Type: FK CONSTRAINT; Schema: car_portal_app; Owner: car_portal_app
--

ALTER TABLE ONLY favorite_ads
    ADD CONSTRAINT favorite_ads_account_id_fkey FOREIGN KEY (account_id) REFERENCES account(account_id);


--
-- Name: favorite_ads favorite_ads_advertisement_id_fkey; Type: FK CONSTRAINT; Schema: car_portal_app; Owner: car_portal_app
--

ALTER TABLE ONLY favorite_ads
    ADD CONSTRAINT favorite_ads_advertisement_id_fkey FOREIGN KEY (advertisement_id) REFERENCES advertisement(advertisement_id);


--
-- Name: seller_account seller_account_account_id_fkey; Type: FK CONSTRAINT; Schema: car_portal_app; Owner: car_portal_app
--

ALTER TABLE ONLY seller_account
    ADD CONSTRAINT seller_account_account_id_fkey FOREIGN KEY (account_id) REFERENCES account(account_id);


--
-- PostgreSQL database dump complete
--

