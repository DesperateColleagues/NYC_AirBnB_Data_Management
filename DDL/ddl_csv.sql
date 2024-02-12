-- This table will contain every Airbnb rental unit in NYC
CREATE TABLE IF NOT EXISTS rental_units (
	id BIGINT,
	name VARCHAR(50) NOT NULL,
	availability_rate_365 DECIMAL, 
	rate DECIMAL, 
	number_of_reviews INTEGER,
	latitude DECIMAL,
	longitude DECIMAL,
	host INTEGER NOT NULL,
	license BOOLEAN DEFAULT FALSE,
	neighborhood INTEGER,
	coordinates geometry(Point)
);

-- This table will contain every host for the renal units
CREATE TABLE IF NOT EXISTS hosts (
	id INTEGER,
	name VARCHAR(50)
);

-- This table will contain every possible room configuration for the rental units
CREATE TABLE IF NOT EXISTS room_configurations (
	id SERIAL,
	room_type VARCHAR(20),
	n_beds INTEGER,
	n_baths INTEGER,
	n_rooms INTEGER,
	is_bath_shared BOOLEAN
);

-- This table will contain every possible rental fare for the rental units
CREATE TABLE IF NOT EXISTS rental_fares (
	id SERIAL,
	minimum_nights INTEGER NOT NULL,
	price DECIMAL NOT NULL
);

-- This table resume the listing of a rental unit
CREATE TABLE IF NOT EXISTS rental_resumes (
	id SERIAL,
	rental_unit BIGINT NOT NULL,
	room_configuration INTEGER NOT NULL,
	rental_fare INTEGER NOT NULL,
	resume_date DATE
);

-- This table contains every type of crime
CREATE TABLE IF NOT EXISTS crimes (
	id SERIAL,
	description VARCHAR(100) NOT NULL
);

-- This table will contain the arrests made in NYC
CREATE TABLE IF NOT EXISTS arrests (
	id INTEGER,
	arrest_date DATE NOT NULL,
	latitude DECIMAL,
	longitude DECIMAL,
	neighborhood INTEGER,
	coordinates geometry(Point),
	crime INTEGER NOT NULL
);

-- This table will contain NYC subway stops
CREATE TABLE IF NOT EXISTS subway_stops (
	id VARCHAR(4),
	name VARCHAR(50) NOT NULL,
	latitude DECIMAL,
	longitude DECIMAL,
	neighborhood INTEGER, 
	coordinates geometry(Point)
 );
  
 -- This table will contain the house sales in NYC during 2023
 CREATE TABLE IF NOT EXISTS house_sales (
	 id SERIAL,
	 tax_class CHAR(2),
	 sqft DECIMAL NOT NULL,
	 price DECIMAL,
	 construction_year INTEGER,
	 address VARCHAR(100),
	 latitude DECIMAL,
	 longitude DECIMAL,
	 neighborhood INTEGER, 
	 coordinates geometry(Point)
 );
 