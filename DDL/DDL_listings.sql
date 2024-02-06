ALTER TABLE listings RENAME COLUMN availability_365 TO availability_rate_365;

-- Table rental_units
CREATE TABLE rental_units AS (
	SELECT id, name, availability_rate_365, rate::DECIMAL, number_of_reviews, latitude, longitude, host_id as host, license AS old_license
	FROM listings
);

-- new_license attribute will be filled in the dml_bnb_houses.sql file, and in this file there are still
-- the renaming of the 'new_license' attribute to 'license' and the deletion of 'old_license' attribute.
ALTER TABLE rental_units ADD COLUMN new_license BOOLEAN DEFAULT false;

SELECT AddGeometryColumn ('rental_units','coordinates', 4326, 'POINT', 2);

-- Adds the neighborhood column that will be a foreign key
ALTER TABLE rental_units ADD COLUMN neighborhood INTEGER;

-- TABLE hosts
CREATE TABLE hosts AS (
	SELECT host_id AS id, host_name AS name
	FROM listings
	WHERE name IS NOT NULL
	GROUP BY host_id, host_name
);

-- TABLE room_configurations
CREATE TABLE room_configurations AS (
	SELECT room_type, n_beds::DECIMAL, n_baths::DECIMAL, is_bath_shared
	FROM listings
	GROUP BY room_type, n_beds, n_baths, is_bath_shared
);
	
ALTER TABLE room_configurations ADD COLUMN id SERIAL;
ALTER TABLE room_configurations ADD COLUMN n_rooms INTEGER DEFAULT NULL;

-- TABLE rental_fares
CREATE TABLE rental_fares AS (
	SELECT price, minimum_nights
	FROM listings
	GROUP BY price, minimum_nights
);	
	
ALTER TABLE rental_fares ADD COLUMN id SERIAL;

-- TABLE temporary TERNARIA
CREATE TABLE rental_resume AS (
	SELECT l.id AS rental_unit, rg.id AS room_configuration, rf.id AS rental_fare, CURRENT_DATE AS fare_import_date
	FROM listings l, room_configurations rg, rental_fares rf
	WHERE l.room_type = rg.room_type AND l.n_beds::DECIMAL = rg.n_beds AND l.n_baths::DECIMAL = rg.n_beds 
			AND l.is_bath_shared = rg.is_bath_shared
			AND l.price = rf.price AND l.minimum_nights = rf.minimum_nights
);

DROP TABLE listings;

select * from rental_resume;