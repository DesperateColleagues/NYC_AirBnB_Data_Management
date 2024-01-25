-- This table will contain every borough
CREATE TABLE IF NOT EXISTS borough (
	id CHAR(2) NOT NULL PRIMARY KEY,
	name VARCHAR(15)
);

-- This table will contain every crime types
CREATE TABLE IF NOT EXISTS crime_types (
	id SMALLINT PRIMARY KEY,
	description VARCHAR(100) NOT NULL
);

-- This table will contain crimes made in NYC
CREATE TABLE IF NOT EXISTS crimes (
	id BIGINT PRIMARY KEY,
	arrest_date DATE,
	crime_type SMALLINT,
	latitude FLOAT, 
	longitude FLOAT
);

SELECT AddGeometryColumn ('crimes','coordinates', 4326, 'POINT', 2);

-- This table will contain the hosts
CREATE TABLE IF NOT EXISTS hosts (
	id BIGINT PRIMARY KEY,
	name TEXT NOT NULL
);

-- This table will contain every bnb house listed in new york city
CREATE TABLE IF NOT EXISTS bnb_house (
	id BIGINT PRIMARY KEY,
	name TEXT NOT NULL,
	availability_rate_365 FLOAT,
	rate FLOAT,
	number_of_reviews INTEGER,
	latitude FLOAT NOT NULL,
	longitude FLOAT NOT NULL,
	host BIGINT NOT NULL
);

SELECT AddGeometryColumn ('bnb_house','coordinates', 4326, 'POINT', 2);

-- This table will contain the room's rents associated to a particular bnb house
CREATE TABLE IF NOT EXISTS rent (
	id INTEGER PRIMARY KEY, 
	room_type TEXT,
	n_beds INTEGER, 
	n_baths FLOAT,
	is_bath_shared BOOLEAN, 
	bnb_house BIGINT
);

-- This table will contain every fare existed for a particular bnb rent
CREATE TABLE IF NOT EXISTS rent_fare (
	id INTEGER PRIMARY KEY,
	price FLOAT NOT NULL, 
	minimum_nights SMALLINT,
	rent INTEGER NOT NULL
);

-- This table will contain every house sales in NYC
CREATE TABLE IF NOT EXISTS house_sales (
	id BIGINT PRIMARY KEY,
	tax_class VARCHAR(2),
	sqft FLOAT NOT NULL, 
	price FLOAT NOT NULL, 
	construction_year INTEGER, 
	address TEXT, 
	latitude FLOAT, 
	longitude FLOAT
); 

SELECT AddGeometryColumn ('house_sales','coordinates', 4326, 'POINT', 2);

-- This table will contain every NYC subway stop
CREATE TABLE IF NOT EXISTS subway_stops (
	id VARCHAR(3) PRIMARY KEY,
	name TEXT NOT NULL,
	latitude FLOAT NOT NULL, 
	longitude FLOAT NOT NULL
);

SELECT AddGeometryColumn ('subway_stops','coordinates', 4326, 'POINT', 2);

-- This tables will contain every POIs and POIs' types
ALTER TABLE poi RENAME COLUMN gid TO id;
ALTER TABLE poi RENAME COLUMN faci_dom TO domain;
ALTER TABLE poi RENAME COLUMN geom TO coordinates;

CREATE TABLE poi_type AS (SELECT DISTINCT facility_t::INTEGER FROM poi);
ALTER TABLE poi_type RENAME COLUMN facility_t TO id;

ALTER TABLE poi_type ADD COLUMN type_desc VARCHAR(50);

CREATE TABLE POI_NEW AS (
	SELECT id, name, domain, facility_t::INTEGER as poi_type, coordinates FROM poi
);

DROP TABLE poi;

ALTER TABLE POI_NEW RENAME TO poi;

-- This table will contain every neighborhoods
ALTER TABLE neighborhoods RENAME COLUMN gid TO id;
ALTER TABLE neighborhoods RENAME COLUMN ntaname TO name;
ALTER TABLE neighborhoods RENAME COLUMN boroname TO borough;
ALTER TABLE neighborhoods RENAME COLUMN geom TO perimeter;

CREATE TABLE neighborhoods_new AS (
	SELECT id, name, borough, perimeter 
	FROM neighborhoods
);

DROP TABLE neighborhoods;

ALTER TABLE neighborhoods_new RENAME TO neighborhoods;

-- This table will contain every park
ALTER TABLE parks RENAME COLUMN gid TO id;
ALTER TABLE parks RENAME COLUMN signname TO name;
ALTER TABLE parks RENAME COLUMN typecatego TO category;

ALTER TABLE parks ADD COLUMN boroughs CHAR(2)[];

CREATE TABLE parks_new AS 
	SELECT id, name, category, geom AS perimeter 
	FROM parks;

DROP TABLE parks;

ALTER TABLE parks_new RENAME TO parks; 

-- This table will contain every bus stop
ALTER TABLE bus_stops RENAME COLUMN gid TO id;
ALTER TABLE bus_stops RENAME COLUMN shelter_id TO name;
ALTER TABLE bus_stops RENAME COLUMN geom TO coordinates;

ALTER TABLE bus_stops ADD COLUMN neighborhood INTEGER;

CREATE TABLE bus_stops_new AS 
	SELECT id, name, corner, neighborhood, coordinates 
	FROM bus_stops;

DROP TABLE bus_stops;

ALTER TABLE bus_stops_new RENAME TO bus_stops;

-- This table will contain information about NYC roads
ALTER TABLE roads RENAME COLUMN gid TO id;
ALTER TABLE roads RENAME COLUMN borocode TO borough;
ALTER TABLE roads RENAME COLUMN trafdir TO traffic_direction;
ALTER TABLE roads RENAME COLUMN st_label TO name;
ALTER TABLE roads RENAME COLUMN geom TO path;
 
CREATE TABLE roads_new AS 
	SELECT id, borough, traffic_direction, name, status, path
	FROM roads;
 
DROP TABLE roads;
 
ALTER TABLE roads_new RENAME TO roads;




