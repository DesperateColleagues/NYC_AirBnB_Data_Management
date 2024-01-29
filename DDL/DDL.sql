-- This table will contain every borough
CREATE TABLE IF NOT EXISTS boroughs (
	id CHAR(2) NOT NULL PRIMARY KEY,
	name VARCHAR(15)
);

-- This table will load CSV data about bnb listings
CREATE TABLE listings (
	id BIGINT,
    name VARCHAR(255),
    host_id INT,
    host_name VARCHAR(255),
    neighbourhood_group VARCHAR(255),
    neighbourhood VARCHAR(255),
    latitude FLOAT,
    longitude FLOAT,
    bnb_type VARCHAR(255),
    price INT,
    minimum_nights INT,
    number_of_reviews INT,
    last_review DATE,
    reviews_per_month FLOAT,
    calculated_host_listings_count INT,
    availability_365 DECIMAL,
    number_of_reviews_ltm INT,
    license VARCHAR(255),
	rate VARCHAR(10),
	room_type VARCHAR(255),
	n_beds VARCHAR(10),
	n_baths VARCHAR(10),
	is_bath_shared BOOLEAN
);

-- This table will load csv data about arrests in nyc
CREATE TABLE IF NOT EXISTS nypd_Arrests (
    ARREST_KEY INT,
    ARREST_DATE DATE,
    PD_CD INT,
    PD_DESC VARCHAR(255),
    KY_CD FLOAT,
    OFNS_DESC VARCHAR(255),
    LAW_CODE VARCHAR(50),
    LAW_CAT_CD VARCHAR(50),
    ARREST_BORO VARCHAR(50),
    ARREST_PRECINCT INT,
    JURISDICTION_CODE INT,
    AGE_GROUP VARCHAR(50),
    PERP_SEX VARCHAR(50),
    PERP_RACE VARCHAR(50),
    X_COORD_CD INT,
    Y_COORD_CD INT,
    Latitude FLOAT,
    Longitude FLOAT
);

-- This table will load subway stops in nyc
CREATE TABLE subway_stops (
    stop_id VARCHAR(50) PRIMARY KEY,
    stop_code FLOAT,
    stop_name VARCHAR(255),
    stop_desc FLOAT,
    stop_lat FLOAT,
    stop_lon FLOAT,
    zone_id FLOAT,
    stop_url FLOAT,
    location_type INT,
    parent_station VARCHAR(50)
);

-- TODO DA SPOSTARE NEL DDL DI house_sales
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

-- Adds the neighborhood column that will be a foreign key
ALTER TABLE house_sales ADD COLUMN neighborhood INTEGER;

SELECT AddGeometryColumn ('house_sales','coordinates', 4326, 'POINT', 2);

-- This tables will contain every POIs and POIs' types
ALTER TABLE poi RENAME COLUMN gid TO id;
ALTER TABLE poi RENAME COLUMN faci_dom TO domain;
ALTER TABLE poi RENAME COLUMN geom TO coordinates;

-- Adds the neighborhood column that will be a foreign key
ALTER TABLE poi ADD COLUMN neighborhood INTEGER;

CREATE TABLE poi_types AS (SELECT DISTINCT facility_t::INTEGER FROM poi);
ALTER TABLE poi_types RENAME COLUMN facility_t TO id;

ALTER TABLE poi_types ADD COLUMN type_desc VARCHAR(50);

CREATE TABLE poi_new AS (
	SELECT id, name, domain, facility_t::INTEGER as poi_type, neighborhood, coordinates FROM poi
);

DROP TABLE poi;

ALTER TABLE poi_new RENAME TO poi;

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
