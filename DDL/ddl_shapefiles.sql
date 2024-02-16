-- This table will contain every borough in NYC
CREATE TABLE IF NOT EXISTS boroughs (
	id CHAR(2),
	name VARCHAR(50),
	perimeter geometry(MultiPolygon, 4326)
);

-- This table will contain every neighborhoods
CREATE TABLE IF NOT EXISTS neighborhoods (
	id SERIAL,
	name VARCHAR(100),
	borough CHAR(2),
	perimeter geometry(MultiPolygon, 4326)
);

-- This tables will contain every POIs' types
CREATE TABLE IF NOT EXISTS poi_types (
	id INTEGER,
    type_desc VARCHAR(50)
);

-- This tables will contain every POI
CREATE TABLE IF NOT EXISTS poi (
	id SERIAL,
	name VARCHAR(100),
	domain VARCHAR(50),
	poi_type INTEGER,
	neighborhood INTEGER,
	coordinates geometry(Point, 4326)
);

-- This table will contain every bus stop
CREATE TABLE IF NOT EXISTS bus_stops (
	id SERIAL,
	name VARCHAR(50),
	corner VARCHAR(100),
	neighborhood INTEGER,
	coordinates geometry(Point, 4326)
);

-- This table will contain information about NYC roads
CREATE TABLE IF NOT EXISTS roads (
	id SERIAL, 
	traffic_direction CHAR(2),
	name VARCHAR(50),
	status VARCHAR(20),
	borough CHAR(2),
	path geometry(LineString, 4326)
);

CREATE INDEX roads_idx
	ON roads
	USING GIST(path);
	

-- This table will contain every NYC park
CREATE TABLE IF NOT EXISTS parks (
	id SERIAL,
	name VARCHAR(100),
	category VARCHAR(50),
	boroughs CHAR(2)[],
	perimeter geometry(MultiPolygon, 4326)
);

CREATE INDEX parks_idx
	ON parks
	USING GIST(perimeter);

-- This table will contain the boroughs where each park belongs
CREATE TABLE IF NOT EXISTS positionings (
	borough CHAR(2),
	park INTEGER
);