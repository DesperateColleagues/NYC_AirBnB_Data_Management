ALTER TABLE listings RENAME COLUMN availability_365 TO availability_rate_365;

CREATE TABLE bnb_houses AS (
	SELECT id, name, availability_rate_365, rate, number_of_reviews, latitude, longitude, host_id as host
	FROM listings
);

SELECT AddGeometryColumn ('bnb_houses','coordinates', 4326, 'POINT', 2);

-- Adds the neighborhood column that will be a foreign key
ALTER TABLE bnb_houses ADD COLUMN neighborhood INTEGER;

CREATE TABLE hosts AS (
	SELECT host_id AS id, host_name AS name
	FROM listings
	WHERE name IS NOT NULL
	GROUP BY host_id, host_name
);

CREATE TABLE rents AS (
	SELECT room_type, n_beds, n_baths, is_bath_shared, id AS bnb_house
	FROM listings
);
	
ALTER TABLE rents ADD COLUMN id SERIAL;

CREATE TABLE rent_fares AS (
	SELECT price, minimum_nights, r.id AS rent
	FROM rents AS r, listings AS l
	WHERE r.bnb_house = l.id
);	
	
ALTER TABLE rent_fares ADD COLUMN id SERIAL;

DROP TABLE listings;